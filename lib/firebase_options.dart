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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDEK0IlFriqHzXglwWNEwaEMylUEIQXosw',
    appId: '1:413695432853:web:3567b44ccb890aee8ae39c',
    messagingSenderId: '413695432853',
    projectId: 'smart-farming-d51aa',
    authDomain: 'smart-farming-d51aa.firebaseapp.com',
    storageBucket: 'smart-farming-d51aa.firebasestorage.app',
    measurementId: 'G-6DPQNNFQ4Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA55ZTmV7b4LxxeZ36kJAmTK7Azo4CILg4',
    appId: '1:413695432853:android:2f2e9374aa721d708ae39c',
    messagingSenderId: '413695432853',
    projectId: 'smart-farming-d51aa',
    storageBucket: 'smart-farming-d51aa.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAuP9E1KuirN8S0Vsi0eg2IfTlwkXH5yx8',
    appId: '1:413695432853:ios:57239c230a4a80408ae39c',
    messagingSenderId: '413695432853',
    projectId: 'smart-farming-d51aa',
    storageBucket: 'smart-farming-d51aa.firebasestorage.app',
    iosClientId: '413695432853-ge9qr8oj2te0iacpjoimind6f0t88rqk.apps.googleusercontent.com',
    iosBundleId: 'com.farmtrack.samarFarming',
  );
}
