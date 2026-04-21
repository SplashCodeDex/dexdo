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
  // Firestore stores dates as ISO Strings or Timestamps. 
  // Based on task.dart (completionDate?.toIso8601String()), it's stored as an ISO String.
  const thirtyDaysAgoISO = thirtyDaysAgo.toISOString();

  console.log(`Starting auto-archival for tasks completed before: ${thirtyDaysAgoISO}`);

  // We need to fetch all users first
  const usersSnapshot = await db.collection("users").get();
  
  if (usersSnapshot.empty) {
    console.log("No users found.");
    return;
  }

  let totalArchived = 0;

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;
    const tasksRef = db.collection("users").doc(userId).collection("tasks");
    const archiveRef = db.collection("users").doc(userId).collection("archived_tasks");

    // Strategy 1: Since we don't have indexes explicitly defined for this combination yet, 
    // and querying across all users could be huge, we might need a composite index on [isCompleted, completionDate].
    // Assuming the user has potentially hundreds of tasks, we do a basic query for isCompleted=1.
    // In task.dart: toJson() -> 'isCompleted': isCompleted ? 1 : 0
    const oldTasksQuery = tasksRef
        .where("isCompleted", "==", 1)
        .where("completionDate", "<", thirtyDaysAgoISO);
    
    try {
      const oldTasksSnapshot = await oldTasksQuery.get();
      
      if (!oldTasksSnapshot.empty) {
        // Prepare Batched Writes (Limit: 500 ops per batch)
        let batch = db.batch();
        let opsCount = 0; // 1 move = 2 ops (set + delete)
        
        for (const doc of oldTasksSnapshot.docs) {
          batch.set(archiveRef.doc(doc.id), doc.data());
          batch.delete(tasksRef.doc(doc.id));
          opsCount += 2;
          totalArchived++;

          if (opsCount >= 490) { // Safety margin
            await batch.commit();
            batch = db.batch();
            opsCount = 0;
          }
        }
        
        // Commit remnants
        if (opsCount > 0) {
          await batch.commit();
        }
        
        console.log(`Archived ${oldTasksSnapshot.size} tasks for user: ${userId}`);
      }
    } catch (err) {
      console.error(`Error processing archival for user ${userId}:`, err);
      // Fails gracefully per user if index doesn't exist yet, instructing developer to build it.
    }
  }

  console.log(`Job Completed. Total tasks archived across all users: ${totalArchived}`);
});
