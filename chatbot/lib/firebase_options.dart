import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;


class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyASn6zzfveFyNQmTIRSJRFVrpVPv8Shqcg',
    appId: '1:94909927588:web:8c0514a0d2faf5b4e39631',
    messagingSenderId: '94909927588',
    projectId: 'soulspeakchat',
    authDomain: 'soulspeakchat.firebaseapp.com',
    storageBucket: 'soulspeakchat.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGlMn-wJGtoNMnj9i-HPGAET18NyvO4sU',
    appId: '1:94909927588:android:0781032b23dd71ffe39631',
    messagingSenderId: '94909927588',
    projectId: 'soulspeakchat',
    storageBucket: 'soulspeakchat.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD2Wy5P-d_kEQmhn72WWxa1IdEsZXF8C1Y',
    appId: '1:94909927588:ios:48e4f405efb12544e39631',
    messagingSenderId: '94909927588',
    projectId: 'soulspeakchat',
    storageBucket: 'soulspeakchat.firebasestorage.app',
    iosBundleId: 'com.example.soulspeak',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD2Wy5P-d_kEQmhn72WWxa1IdEsZXF8C1Y',
    appId: '1:94909927588:ios:48e4f405efb12544e39631',
    messagingSenderId: '94909927588',
    projectId: 'soulspeakchat',
    storageBucket: 'soulspeakchat.firebasestorage.app',
    iosBundleId: 'com.example.soulspeak',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyASn6zzfveFyNQmTIRSJRFVrpVPv8Shqcg',
    appId: '1:94909927588:web:fd05db6dd3c8e3d8e39631',
    messagingSenderId: '94909927588',
    projectId: 'soulspeakchat',
    authDomain: 'soulspeakchat.firebaseapp.com',
    storageBucket: 'soulspeakchat.firebasestorage.app',
  );

}