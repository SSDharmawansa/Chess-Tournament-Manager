import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  bool _isInitialized = false;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _googleSignIn.initialize();
    _isInitialized = true;
  }

  bool supportsGoogleSignIn() =>
      _isInitialized && _googleSignIn.supportsAuthenticate();

  Future<User?> restorePreviousSignIn() async {
    await initialize();

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      return currentUser;
    }

    final restoredUser = await _googleSignIn.attemptLightweightAuthentication();
    if (restoredUser == null) {
      return null;
    }

    final idToken = restoredUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google Sign-In did not return a valid ID token.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final result = await _firebaseAuth.signInWithCredential(credential);
    return result.user;
  }

  Future<UserCredential> signInWithGoogle() async {
    await initialize();

    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'This platform does not support the Google Sign-In flow used by this app.',
      );
    }

    final googleUser = await _googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw StateError('Google Sign-In did not return a valid ID token.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();

    if (_isInitialized) {
      await _googleSignIn.signOut();
    }
  }
}
