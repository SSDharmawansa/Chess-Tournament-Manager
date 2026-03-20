import 'package:chess_tournament/auth/app_session.dart';
import 'package:chess_tournament/auth/google_auth_service.dart';
import 'package:chess_tournament/core/theme/app_theme.dart';
import 'package:chess_tournament/firebase_options.dart';
import 'package:chess_tournament/screens/home/home_screen.dart';
import 'package:chess_tournament/screens/splash_screen.dart';
import 'package:chess_tournament/state/tournament_controller.dart';
import 'package:chess_tournament/storage/firestore_tournament_repository.dart';
import 'package:chess_tournament/storage/local_storage_service.dart';
import 'package:chess_tournament/storage/local_tournament_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localStorageService = LocalStorageService();
  await localStorageService.init();

  var firebaseAvailable = false;
  Object? firebaseError;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseAvailable = true;
  } catch (error) {
    firebaseError = error;
  }

  runApp(
    ChessTournamentBootstrapApp(
      localStorageService: localStorageService,
      firebaseAvailable: firebaseAvailable,
      firebaseError: firebaseError,
    ),
  );
}

class ChessTournamentBootstrapApp extends StatefulWidget {
  const ChessTournamentBootstrapApp({
    super.key,
    required this.localStorageService,
    required this.firebaseAvailable,
    this.firebaseError,
  });

  final LocalStorageService localStorageService;
  final bool firebaseAvailable;
  final Object? firebaseError;

  @override
  State<ChessTournamentBootstrapApp> createState() =>
      _ChessTournamentBootstrapAppState();
}

class _ChessTournamentBootstrapAppState
    extends State<ChessTournamentBootstrapApp> {
  GoogleAuthService? _googleAuthService;
  AppSession? _session;
  String? _statusMessage;
  bool _isInitializing = true;
  bool _isSigningIn = false;
  bool _isStartingGuest = false;
  int _sessionRevision = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!widget.firebaseAvailable) {
      if (!mounted) return;

      setState(() {
        _isInitializing = false;
        _statusMessage = widget.firebaseError == null
            ? 'Google Sign-In is unavailable right now. Guest mode is still available.'
            : 'Google Sign-In is unavailable right now. Guest mode is still available.\n\n${widget.firebaseError}';
      });
      return;
    }

    final authService = GoogleAuthService();

    try {
      await authService.initialize();
      final user = await authService.restorePreviousSignIn();
      if (!mounted) return;

      setState(() {
        _googleAuthService = authService;
        _session = user == null ? null : _googleSessionFor(user);
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _googleAuthService = authService;
        _session = authService.currentUser == null
            ? null
            : _googleSessionFor(authService.currentUser!);
        _isInitializing = false;
        _statusMessage = authService.currentUser == null
            ? 'Google Sign-In could not be prepared. Guest mode is still available.\n\n$error'
            : null;
      });
    }
  }

  AppSession _googleSessionFor(User user) {
    return AppSession.google(
      repository: FirestoreTournamentRepository(),
      displayName: user.displayName,
      email: user.email,
    );
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = _googleAuthService;
    if (authService == null || !widget.firebaseAvailable) {
      setState(() {
        _statusMessage =
            'Google Sign-In is not ready yet. Continue as guest or verify Firebase setup.';
      });
      return;
    }

    setState(() {
      _statusMessage = null;
      _isSigningIn = true;
    });

    try {
      final credential = await authService.signInWithGoogle();
      final user = credential.user;

      if (!mounted) return;

      if (user == null) {
        setState(() {
          _statusMessage = 'Google Sign-In completed without a Firebase user.';
          _isSigningIn = false;
        });
        return;
      }

      setState(() {
        _session = _googleSessionFor(user);
        _sessionRevision++;
        _isSigningIn = false;
      });
    } on GoogleSignInException catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage = error.code == GoogleSignInExceptionCode.canceled
            ? 'Google Sign-In was canceled.'
            : 'Google Sign-In failed: ${error.description ?? error.code.name}';
        _isSigningIn = false;
      });
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage =
            'Firebase authentication failed: ${error.message ?? error.code}';
        _isSigningIn = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Google Sign-In failed: $error';
        _isSigningIn = false;
      });
    }
  }

  Future<void> _handleGuestLaunch() async {
    setState(() {
      _statusMessage = null;
      _isStartingGuest = true;
    });

    try {
      if (!mounted) return;

      setState(() {
        _session = AppSession.guest(
          repository: LocalTournamentRepository(
            storageService: widget.localStorageService,
          ),
        );
        _sessionRevision++;
        _isStartingGuest = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _statusMessage = 'Guest mode could not start: $error';
        _isStartingGuest = false;
      });
    }
  }

  Future<void> _handleExitSession() async {
    final currentSession = _session;
    if (currentSession == null) return;

    if (!currentSession.isGuest) {
      try {
        await _googleAuthService?.signOut();
      } catch (error) {
        if (!mounted) return;

        setState(() {
          _statusMessage =
              'Signed out locally, but Google session cleanup failed: $error';
        });
      }
    }

    if (!mounted) return;

    setState(() {
      _session = null;
      _sessionRevision++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;

    if (session == null) {
      return ChessTournamentApp(
        home: SplashScreen(
          onGoogleSignIn: _handleGoogleSignIn,
          onContinueAsGuest: _handleGuestLaunch,
          isGoogleSignInAvailable:
              widget.firebaseAvailable &&
              (_googleAuthService?.supportsGoogleSignIn() ?? false),
          isBusy: _isInitializing || _isSigningIn || _isStartingGuest,
          activityLabel: _isInitializing
              ? 'Checking sign-in status...'
              : _isSigningIn
              ? 'Signing in with Google...'
              : _isStartingGuest
              ? 'Opening guest workspace...'
              : null,
          statusMessage: _statusMessage,
        ),
      );
    }

    return ProviderScope(
      key: ValueKey(_sessionRevision),
      overrides: [
        tournamentRepositoryProvider.overrideWithValue(session.repository),
      ],
      child: ChessTournamentApp(
        home: HomeScreen(session: session, onExitSession: _handleExitSession),
      ),
    );
  }
}

class ChessTournamentApp extends StatelessWidget {
  const ChessTournamentApp({super.key, required this.home});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Team Director',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: home,
    );
  }
}
