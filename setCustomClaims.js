const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK with your service account key file
admin.initializeApp({
  credential: admin.credential.cert('C:/Users/Ali-s/StudioProjects/flutter_techfusion_project/serviceAccountKey.json') // Update this path with the actual path to your service account key JSON file
});

// Array of admin user UIDs
const adminUIDs = [
  '4XCCIwDTthMttU8R6hJ2AqtaL1w2', // First admin UID
  'cHAkkBHLE9XUXKU2uFLYNxE3EBN2'  // Second admin UID
  // Add more UIDs here if you have more admin users
];

// Function to set custom claim for each admin user
const setCustomClaimForAdmins = async () => {
  for (const uid of adminUIDs) {
    try {
      // Fetch user data
      const userRecord = await admin.auth().getUser(uid);
      console.log('Successfully fetched user data:', userRecord.toJSON());

      // Set custom claim for each admin UID
      await admin.auth().setCustomUserClaims(uid, { role: 'admin' });
      console.log(`Custom claim set for admin UID: ${uid}`);

      // Fetch user data again to verify
      const updatedUserRecord = await admin.auth().getUser(uid);
      console.log('Updated Custom Claims:', updatedUserRecord.customClaims);

    } catch (error) {
      console.error(`Error setting custom claim for UID: ${uid}`, error);
    }
  }
};

// Call the function to set custom claims
setCustomClaimForAdmins();
