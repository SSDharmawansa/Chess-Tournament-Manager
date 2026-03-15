import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService() : _signIn = GoogleSignIn.instance;

  final GoogleSignIn _signIn;
  bool _initialized = false;

  Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _signIn.authenticationEvents;

  bool get supportsAuthenticate => _signIn.supportsAuthenticate();

  Future<void> initialize() async {
    if (_initialized) return;
    await _signIn.initialize();
    _initialized = true;
  }

  Future<GoogleSignInAccount?> restorePreviousSignIn() {
    final result = _signIn.attemptLightweightAuthentication();
    return result ?? Future<GoogleSignInAccount?>.value();
  }

  Future<GoogleSignInAccount?> signIn() async {
    if (_signIn.supportsAuthenticate()) {
      return _signIn.authenticate();
    }
    return _signIn.attemptLightweightAuthentication();
  }

  Future<void> signOut() {
    return _signIn.disconnect();
  }
}
