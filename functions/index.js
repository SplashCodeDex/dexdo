const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");

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
