const { initializeApp } = require('firebase/app');
const { getFirestore, doc, updateDoc, getDoc } = require('firebase/firestore');

const firebaseConfig = {
  apiKey: "AIzaSyACIotXWShfNsDwcoObmmInxYF4qTyn7yo",
  appId: "1:441184469522:web:cb4b997807170d06958ecb",
  messagingSenderId: "441184469522",
  projectId: "ehtyagat-513cb",
  storageBucket: "ehtyagat-513cb.firebasestorage.app"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

async function run() {
  const newUrl = process.argv[2];
  if (!newUrl) {
    console.error("Please provide the new URL as an argument.");
    process.exit(1);
  }
  
  console.log(`Updating Firestore whatsapp_api_url to: ${newUrl}`);
  
  try {
    const docRef = doc(db, "settings", "notification_config");
    const docSnap = await getDoc(docRef);
    if (docSnap.exists()) {
      await updateDoc(docRef, {
        whatsapp_api_url: newUrl
      });
      console.log("✅ Firestore updated successfully!");
    } else {
      console.error("❌ Document settings/notification_config does not exist!");
    }
  } catch (error) {
    console.error("❌ Error updating Firestore:", error);
  }
  process.exit(0);
}

run();
