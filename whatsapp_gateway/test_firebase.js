const { initializeApp } = require('firebase/app');
const { getFirestore, doc, setDoc } = require('firebase/firestore');

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
  console.log("Attempting to write direct configuration to Firestore settings/notification_config...");
  try {
    const docRef = doc(db, "settings", "notification_config");
    await setDoc(docRef, {
      whatsapp_api_url: "https://ihtiyajati-whatsapp.onrender.com/send-otp",
      whatsapp_token: "local_gateway",
      telegram_bot_token: "",
      telegram_chat_id: "",
      provider: "both"
    }, { merge: true });
    console.log("🎉 SUCCESS! Firestore successfully updated to: https://ihtiyajati-whatsapp.onrender.com/send-otp");
  } catch (error) {
    console.error("❌ Failed to update Firestore:", error);
  }
  process.exit(0);
}

run();
