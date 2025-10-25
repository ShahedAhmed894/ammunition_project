import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api_ammunation_project.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign-In Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Web এর জন্য Sign-In
  Future<User?> _signInWithGoogleWeb() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Optional: Add scopes
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Sign in with popup
      final UserCredential userCredential =
      await _auth.signInWithPopup(googleProvider);

      return userCredential.user;
    } catch (e) {
      print("Web sign-in error: $e");
      rethrow;
    }
  }

  // Mobile/Desktop এর জন্য Sign-In
  Future<User?> _signInWithGoogleMobile() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        return null; // User cancelled
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      return userCredential.user;
    } catch (e) {
      print("Mobile sign-in error: $e");
      rethrow;
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print("Starting Google Sign-In... Platform: ${kIsWeb ? 'Web' : 'Mobile'}");

      User? user;

      // Platform অনুযায়ী sign-in method select করা
      if (kIsWeb) {
        user = await _signInWithGoogleWeb();
      } else {
        user = await _signInWithGoogleMobile();
      }

      if (user != null) {
        print("Sign-in successful for user: ${user.email}");
        _showSuccessSnackBar(
            "Successfully signed in as ${user.displayName ?? user.email}"
        );

        // Navigate to home screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => Api_ammunation_project(user: user!),
            ),
          );
        }
      } else {
        print("Sign-in was cancelled by user");
        _showErrorDialog("Sign-in was cancelled. Please try again.");
      }
    } catch (e) {
      print("Sign-in error: $e");
      String errorMessage = e.toString();

      // Common error messages কে user-friendly করা
      if (errorMessage.contains('popup-closed-by-user')) {
        errorMessage = 'Sign-in popup was closed. Please try again.';
      } else if (errorMessage.contains('network-request-failed')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      _showErrorDialog(errorMessage.replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Sign In"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sign in with your Google account to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : const Icon(Icons.login),
                  label: Text(
                    _isLoading ? "Signing In..." : "Sign in with Google",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                Text(
                  kIsWeb
                      ? 'Please complete sign-in in the popup window'
                      : 'Please check the console for detailed logs',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}