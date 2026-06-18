const { onSchedule } = require("firebase-functions/v2/scheduler");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const crypto = require("crypto");
const { createRemoteJWKSet, jwtVerify } = require("jose");
const admin = require("firebase-admin");

const GOOGLE_VC_JWKS_URL = 'https://verifiablecredentials-pa.googleapis.com/.well-known/vc-public-jwks';
const JWKS = createRemoteJWKSet(new URL(GOOGLE_VC_JWKS_URL));

admin.initializeApp();
const db = admin.firestore();

/**
 * Runs every day at 2:00 AM (Server Time zone)
 * Scans all DeXDo users' collections for completed tasks older than 30 days
 * and moves them to an 'archived_tasks' sub-collection to save client bandwidth.
 */
exports.autoArchiveOldTasks = onSchedule("every day 02:00", async (event) => {
  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
  const thirtyDaysAgoISO = thirtyDaysAgo.toISOString();

  console.log(`Starting auto-archival for tasks completed before: ${thirtyDaysAgoISO}`);

  // CRITICAL ENHANCEMENT: Use collectionGroup to query all tasks across the entire database at once.
  // Warning: This requires a composite index in Firestore on ['isCompleted' ASC, 'completionDate' ASC] for the 'tasks' collectionGroup.
  const oldTasksQuery = db.collectionGroup("tasks")
      .where("isCompleted", "==", 1)
      .where("completionDate", "<", thirtyDaysAgoISO);
  
  try {
    const oldTasksSnapshot = await oldTasksQuery.get();
    
    if (oldTasksSnapshot.empty) {
      console.log("No old tasks to archive today.");
      return;
    }

    // Prepare Batched Writes (Limit: 500 ops per batch)
    let batch = db.batch();
    let opsCount = 0; // 1 move = 2 ops (set + delete)
    let totalArchived = 0;
    
    for (const doc of oldTasksSnapshot.docs) {
      // doc.ref.path format: users/{userId}/tasks/{taskId}
      const pathSegments = doc.ref.path.split('/');
      if (pathSegments.length >= 4 && pathSegments[0] === 'users') {
        const userId = pathSegments[1];
        const taskId = pathSegments[3];
        const archiveRef = db.collection("users").doc(userId).collection("archived_tasks").doc(taskId);

        batch.set(archiveRef, doc.data());
        batch.delete(doc.ref);
        opsCount += 2;
        totalArchived++;

        if (opsCount >= 490) { // Safety margin
          await batch.commit();
          batch = db.batch();
          opsCount = 0;
        }
      }
    }
    
    // Commit remnants
    if (opsCount > 0) {
      await batch.commit();
    }
    
    console.log(`Job Completed. Total tasks archived across all users: ${totalArchived}`);
  } catch (err) {
    console.error(`Error processing archival:`, err);
  }
});

exports.verifyDigitalCredential = onCall(async (request) => {
  const { responseJsonString, nonce: clientNonce, linkToUid } = request.data;

  if (!responseJsonString || !clientNonce) {
    throw new HttpsError('invalid-argument', 'Missing responseJsonString or nonce');
  }

  try {
    const responseData = JSON.parse(responseJsonString);
    const vpToken = responseData.vp_token;
    if (!vpToken) {
      throw new HttpsError('invalid-argument', 'Invalid credential format: missing vp_token');
    }

    const credentialId = Object.keys(vpToken)[0];
    const rawSdJwt = vpToken[credentialId][0];

    // rawSdJwt format: <Issuer JWT>~<Disclosure 1>~...~<Key Binding JWT>
    const parts = rawSdJwt.split('~');
    const issuerJwt = parts[0];

    // 1. Verify Issuer JWT signature and claims
    const { payload } = await jwtVerify(issuerJwt, JWKS, {
      issuer: 'https://verifiablecredentials-pa.googleapis.com'
    });

    // Check nonce from the payload matches the client's nonce to prevent replay attacks
    if (payload.nonce !== clientNonce) {
      throw new HttpsError('permission-denied', 'Nonce mismatch - potential replay attack');
    }

    // 2. Parse disclosures and verify hashes
    const expectedDisclosures = new Set(payload._sd || []);
    let verifiedEmail = null;
    let verifiedName = null;

    for (let i = 1; i < parts.length; i++) {
      const part = parts[i];
      if (!part) continue;

      try {
        // Calculate the SD-JWT disclosure hash (SHA-256 base64url)
        const hash = crypto.createHash('sha256').update(part, 'ascii').digest('base64url');
        
        // Verify this hash exists in the JWT's _sd array
        if (expectedDisclosures.has(hash)) {
          // Decode the disclosure to find the claim
          const decodedStr = Buffer.from(part, 'base64url').toString('utf8');
          const json = JSON.parse(decodedStr);
          
          if (Array.isArray(json) && json.length >= 3) {
            const claimName = json[1];
            const claimValue = json[2];
            
            if (claimName === 'email') verifiedEmail = claimValue;
            if (claimName === 'name') verifiedName = claimValue;
          }
        }
      } catch (e) {
        // Not a valid disclosure or parse error
      }
    }

    if (!verifiedEmail) {
      throw new HttpsError('permission-denied', 'Verified email not found in credential disclosures');
    }

    // 3. Find or Create User in Firebase Auth
    let userRecord;
    try {
      userRecord = await admin.auth().getUserByEmail(verifiedEmail);
    } catch (error) {
      if (error.code === 'auth/user-not-found') {
        if (linkToUid) {
          try {
            userRecord = await admin.auth().updateUser(linkToUid, {
              email: verifiedEmail,
              emailVerified: true,
              displayName: verifiedName || verifiedEmail
            });
          } catch (e) {
            userRecord = await admin.auth().createUser({
              email: verifiedEmail,
              emailVerified: true,
              displayName: verifiedName || verifiedEmail
            });
          }
        } else {
          userRecord = await admin.auth().createUser({
            email: verifiedEmail,
            emailVerified: true,
            displayName: verifiedName || verifiedEmail
          });
        }
      } else {
        throw error;
      }
    }

    // 4. Mint Custom Token
    const customToken = await admin.auth().createCustomToken(userRecord.uid);

    return {
      customToken,
      user: {
        email: verifiedEmail,
        name: verifiedName
      }
    };

  } catch (error) {
    console.error("Error verifying digital credential:", error);
    throw new HttpsError('internal', `Verification failed: ${error.message}`);
  }
});
