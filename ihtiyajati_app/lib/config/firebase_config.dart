// ============================================================================
// إعدادات اتصال فايربيس - Firebase Configuration
// ============================================================================

import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static const String apiKey = "AIzaSyACIotXWShfNsDwcoObmmInxYF4qTyn7yo";
  static const String appId = "1:441184469522:web:cb4b997807170d06958ecb";
  static const String messagingSenderId = "441184469522";
  static const String projectId = "ehtyagat-513cb";
  static const String storageBucket = "ehtyagat-513cb.firebasestorage.app";

  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: storageBucket,
    );
  }
}
