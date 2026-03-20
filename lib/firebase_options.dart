import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Firebase has not been configured for web in this workspace.',
      );
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => android,
      TargetPlatform.iOS => ios,
      TargetPlatform.macOS => macos,
      TargetPlatform.windows => throw UnsupportedError(
        'Firebase has not been configured for Windows in this workspace.',
      ),
      TargetPlatform.linux => throw UnsupportedError(
        'Firebase has not been configured for Linux in this workspace.',
      ),
      TargetPlatform.fuchsia => throw UnsupportedError(
        'Firebase has not been configured for Fuchsia in this workspace.',
      ),
    };
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDWZ7wGeuGMbefOdZFw11IM2P3Og4wsbzE',
    appId: '1:217472311902:android:c6066ab18022ad118e4acf',
    messagingSenderId: '217472311902',
    projectId: 'chess-tournament-manager-70540',
    storageBucket: 'chess-tournament-manager-70540.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBohGSkDyiqXrNZeyZQSKqxhVgSIEr_ET0',
    appId: '1:217472311902:ios:e6a7182be55b2bd78e4acf',
    messagingSenderId: '217472311902',
    projectId: 'chess-tournament-manager-70540',
    storageBucket: 'chess-tournament-manager-70540.firebasestorage.app',
    iosBundleId: 'com.ssddharmawansa.chesstournamentmanager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBohGSkDyiqXrNZeyZQSKqxhVgSIEr_ET0',
    appId: '1:217472311902:ios:743b3edee7e5dbe28e4acf',
    messagingSenderId: '217472311902',
    projectId: 'chess-tournament-manager-70540',
    storageBucket: 'chess-tournament-manager-70540.firebasestorage.app',
    iosBundleId: 'com.ssddharmawansa.chesstournamentmanager.macos',
  );
}
