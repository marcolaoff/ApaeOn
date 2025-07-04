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
    apiKey: 'AIzaSyCXtdsbYxLI7NdnkfIpxltinmHzG5IPzM4',
    appId: '1:313216475573:web:451ad267065dfd1de7f9fc',
    messagingSenderId: '313216475573',
    projectId: 'apaeon-1775b',
    authDomain: 'apaeon-1775b.firebaseapp.com',
    storageBucket: 'apaeon-1775b.firebasestorage.app',
    measurementId: 'G-BKNEKW937Y',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_OzjYleW1-neaSYmEbQujPJgJmgdpNi0',
    appId: '1:313216475573:android:1128d4cba2c4973be7f9fc',
    messagingSenderId: '313216475573',
    projectId: 'apaeon-1775b',
    storageBucket: 'apaeon-1775b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvH4w7aJ-drxMDn15EINI7Ezvo38mGgiY',
    appId: '1:313216475573:ios:1fc311cadbe6710de7f9fc',
    messagingSenderId: '313216475573',
    projectId: 'apaeon-1775b',
    storageBucket: 'apaeon-1775b.firebasestorage.app',
    iosBundleId: 'com.example.pi5',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDvH4w7aJ-drxMDn15EINI7Ezvo38mGgiY',
    appId: '1:313216475573:ios:1fc311cadbe6710de7f9fc',
    messagingSenderId: '313216475573',
    projectId: 'apaeon-1775b',
    storageBucket: 'apaeon-1775b.firebasestorage.app',
    iosBundleId: 'com.example.pi5',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCXtdsbYxLI7NdnkfIpxltinmHzG5IPzM4',
    appId: '1:313216475573:web:1e74098f9fbb1158e7f9fc',
    messagingSenderId: '313216475573',
    projectId: 'apaeon-1775b',
    authDomain: 'apaeon-1775b.firebaseapp.com',
    storageBucket: 'apaeon-1775b.firebasestorage.app',
    measurementId: 'G-G3F0XM4XCJ',
  );
}
