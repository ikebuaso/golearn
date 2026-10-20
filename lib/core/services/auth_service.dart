import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Authentication service for Go Learn.
///
/// Handles email/password sign-up, sign-in, Google OAuth sign-in, and
/// session management.  All auth state changes are exposed via the
/// [authStateChanges] stream, which the UI listens to for routing.
///
/// ## Why two code paths for Google?
/// On **web**, `google_sign_in`'s mobile flow does not work. Instead we call
/// `FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider())` which opens
/// the native browser pop-up and returns a [UserCredential] directly.
/// On **Android / iOS**, we use the `google_sign_in` package to get an
/// access + id token pair and exchange them for a Firebase credential.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Only instantiated on mobile – never used on web.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Current signed-in Firebase user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Stream that emits every time the auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------------------------------------------------------
  // Email / Password
  // ---------------------------------------------------------------------------

  /// Creates a new account with [email] and [password].
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  /// Signs in an existing account with [email] and [password].
  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  // ---------------------------------------------------------------------------
  // Google
  // ---------------------------------------------------------------------------

  /// Triggers the Google OAuth flow and signs the user into Firebase.
  ///
  /// - **Web**: opens a browser pop-up via [FirebaseAuth.signInWithPopup].
  /// - **Android / iOS**: uses the `google_sign_in` package to get a token
  ///   pair and exchanges it for a Firebase credential.
  ///
  /// Returns the Firebase [User] on success, or null if cancelled.
  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      return _signInWithGoogleWeb();
    }
    return _signInWithGoogleNative();
  }

  Future<User?> _signInWithGoogleWeb() async {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    // signInWithPopup opens the Google account chooser in a browser pop-up.
    // signInWithRedirect is the alternative if pop-ups are blocked, but
    // pop-up is better UX for Flutter web apps running in a tab.
    final result = await _auth.signInWithPopup(provider);
    return result.user;
  }

  Future<User?> _signInWithGoogleNative() async {
    // Trigger the Google sign-in flow.
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled the dialog.

    // Obtain auth details from the request.
    final googleAuth = await googleUser.authentication;

    // Create a new credential from the token pair.
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the credential.
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential.user;
  }

  // ---------------------------------------------------------------------------
  // Sign out
  // ---------------------------------------------------------------------------

  /// Signs out from Firebase (and Google on mobile).
  Future<void> signOut() async {
    await _auth.signOut();
    // Only call GoogleSignIn.signOut on mobile – it throws on web.
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }

  // ---------------------------------------------------------------------------
  // Password reset
  // ---------------------------------------------------------------------------

  /// Sends a password-reset email to [email].
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
