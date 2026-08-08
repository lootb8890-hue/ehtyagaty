const { initializeApp } = require('firebase/app');
const { getFirestore, doc, getDoc } = require('firebase/firestore');

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
  console.log("Checking Firestore settings/notification_config content...");
  try {
    const docRef = doc(db, "settings", "notification_config");
    const snap = await getDoc(docRef);
    if (snap.exists()) {
      console.log("✅ FIRESTORE DATA:", JSON.stringify(snap.data(), null, 2));
    } else {
      console.log("❌ DOCUMENT DOES NOT EXIST!");
    }
  } catch (error) {
    console.error("❌ Failed to read Firestore:", error);
  }
  process.exit(0);
}

run();
