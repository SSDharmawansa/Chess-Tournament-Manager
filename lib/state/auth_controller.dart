import 'dart:async';

import 'package:chess_tournament/services/google_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

final googleAuthServiceProvider = Provider((ref) => GoogleAuthService());
final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final controller = AuthController(
    ref.watch(googleAuthServiceProvider),
    ref.watch(firebaseAuthProvider),
  );
  controller.initialize();
  return controller;
});

class AuthState {
  const AuthState({
    this.isLoading = true,
    this.user,
    this.errorMessage,
  });

  final bool isLoading;
  final User? user;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    User? user,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : user ?? this.user,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._googleAuthService, this._firebaseAuth)
    : super(const AuthState());

  final GoogleAuthService _googleAuthService;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription<User?>? _authSubscription;

  bool get supportsAuthenticate => _googleAuthService.supportsAuthenticate;

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _googleAuthService.initialize();
      _authSubscription ??= _firebaseAuth.authStateChanges().listen((user) {
        state = state.copyWith(
          isLoading: false,
          user: user,
          clearError: true,
          clearUser: user == null,
        );
      });
      await _googleAuthService.restorePreviousSignIn();
      state = state.copyWith(
        isLoading: false,
        user: _firebaseAuth.currentUser,
        clearError: true,
      );
    } catch (error) {
      _handleAuthenticationError(error);
    }
  }

  Future<void> signIn() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final GoogleSignInAccount? googleUser = await _googleAuthService.signIn();
      if (googleUser == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      state = state.copyWith(
        isLoading: false,
        user: _firebaseAuth.currentUser,
        clearError: true,
      );
    } catch (error) {
      _handleAuthenticationError(error);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _firebaseAuth.signOut();
      await _googleAuthService.signOut();
      state = state.copyWith(
        isLoading: false,
        clearUser: true,
        clearError: true,
      );
    } catch (error) {
      _handleAuthenticationError(error);
    }
  }

  void _handleAuthenticationError(Object error) {
    final message = switch (error) {
      FirebaseAuthException() => 'Firebase auth failed: ${error.message ?? error.code}',
      GoogleSignInException() => switch (error.code) {
          GoogleSignInExceptionCode.canceled => 'Google sign-in was canceled.',
          _ => 'Google sign-in failed: ${error.description ?? error.code.name}',
        },
      _ => 'Authentication error: $error',
    };

    state = state.copyWith(
      isLoading: false,
      errorMessage: message,
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
