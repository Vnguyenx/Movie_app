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
    apiKey: 'AIzaSyDHrXScESJfO9hD5pI17qYO6ClglvxZw4c',
    appId: '1:485055435777:web:45d9e96a8cbb9c0a159c00',
    messagingSenderId: '485055435777',
    projectId: 'trailer-movie-app-f01ab',
    authDomain: 'trailer-movie-app-f01ab.firebaseapp.com',
    storageBucket: 'trailer-movie-app-f01ab.firebasestorage.app',
  );

  // CẤU HÌNH ANDROID
  // (Lưu ý: Nếu bạn build APK, hãy vào Firebase Console -> Project Settings
  // -> Kéo xuống Android App để lấy apiKey và appId chính xác)

  static const FirebaseOptions android = FirebaseOptions(
    apiKey:
        'AIzaSyDHrXScESJfO9hD5pI17qYO6ClglvxZw4c', // Thường dùng chung với Web ok
    appId: 'CẦN_LẤY_APP_ID_CỦA_ANDROID_TỪ_FIREBASE_CONSOLE',
    messagingSenderId: '485055435777',
    projectId: 'trailer-movie-app-f01ab',
    storageBucket: 'trailer-movie-app-f01ab.firebasestorage.app',
  );
  // CẤU HÌNH IOS
  // (Tương tự Android, cần lấy Bundle ID và App ID riêng)

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDHrXScESJfO9hD5pI17qYO6ClglvxZw4c',
    appId: 'CẦN_LẤY_APP_ID_CỦA_IOS_TỪ_FIREBASE_CONSOLE',
    messagingSenderId: '485055435777',
    projectId: 'trailer-movie-app-f01ab',
    storageBucket: 'trailer-movie-app-f01ab.firebasestorage.app',
    iosBundleId: 'com.example.yourappname', // Thay bằng Bundle ID của bạn
  );
}
