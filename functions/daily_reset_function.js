
const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.dailyReset = functions.pubsub.schedule("every 24 hours").onRun(async (context) => {
  const usersSnapshot = await admin.firestore().collection("users").get();

  for (const userDoc of usersSnapshot.docs) {
    const userId = userDoc.id;
    const medicinesSnapshot = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .collection("medicines")
      .get();

    for (const medDoc of medicinesSnapshot.docs) {
      await medDoc.ref.update({ isCompleted: false });
    }
  }
});
