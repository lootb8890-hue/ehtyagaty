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
  try {
    const docRef = doc(db, "settings", "notification_config");
    const snap = await getDoc(docRef);
    if (snap.exists()) {
      console.log("Current notification_config in Firestore:", snap.data());
    } else {
      console.log("Document settings/notification_config does not exist!");
    }
  } catch (error) {
    console.error("Failed to read Firestore:", error);
  }
  process.exit(0);
}

run();
