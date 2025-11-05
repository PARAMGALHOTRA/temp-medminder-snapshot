
const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// Medication Notifier
exports.scheduledMedicationNotifier = functions.pubsub
  .schedule("every 1 hours")
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const oneHourFromNow = admin.firestore.Timestamp.fromMillis(
      now.toMillis() + 60 * 60 * 1000
    );

    const usersSnapshot = await admin.firestore().collection("users").get();

    for (const userDoc of usersSnapshot.docs) {
      const userId = userDoc.id;
      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (fcmToken) {
        const medicinesSnapshot = await admin
          .firestore()
          .collection("users")
          .doc(userId)
          .collection("medicines")
          .where("nextDose", ">=", now)
          .where("nextDose", "<=", oneHourFromNow)
          .where("isCompleted", "==", false)
          .get();

        for (const medDoc of medicinesSnapshot.docs) {
          const medicine = medDoc.data();

          const payload = {
            notification: {
              title: "Time for your medication",
              body: `It's time to take your ${medicine.name}`,
            },
          };

          try {
            await admin.messaging().sendToDevice(fcmToken, payload);
            console.log("Successfully sent message:", payload);
          } catch (error) {
            console.log("Error sending message:", error);
          }
        }
      }
    }
  });

// Daily Reset
const dailyReset = require("./daily_reset_function");
exports.dailyReset = dailyReset.dailyReset;
