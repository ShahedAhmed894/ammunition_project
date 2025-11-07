import 'package:final_ammonation_project/data_get.dart';
import 'package:final_ammonation_project/nid_varification/qrcod_scanner.dart';
import 'package:final_ammonation_project/payment_gateway/payment_gateway.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'api_ammunation_project.dart';
import 'auth/login_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  try {
    if (kIsWeb) {
      print('📱 Initializing Firebase for WEB...');
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBc8iNDNOEvYkVk-JleOv4_Qe-EeZvj9Ok",
          authDomain: "ammonition-project.firebaseapp.com",
          projectId: "ammonition-project",
          storageBucket: "ammonition-project.firebasestorage.app",
          messagingSenderId: "791535158783",
          appId: "1:791535158783:web:45e402e9c6213597d553ca",
          measurementId: "G-8B2ER9JQ7L",
        ),
      );
      print('✅ Firebase initialized successfully for WEB');
    } else {
      print('📱 Initializing Firebase for MOBILE...');
      await Firebase.initializeApp();
      print('✅ Firebase initialized successfully for MOBILE');
    }
  } catch (e, stackTrace) {
    print('❌ Firebase initialization ERROR:');
    print('Error: $e');
    print('Stack trace: $stackTrace');
  }


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('🏗️  Building MyApp widget');
    return MaterialApp(
      title: 'Ammonition Project',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const Api_ammunation_project(),
    );
  }
}

// Simple check screen to verify app is running
class AppCheckScreen extends StatefulWidget {
  const AppCheckScreen({super.key});

  @override
  State<AppCheckScreen> createState() => _AppCheckScreenState();
}

class _AppCheckScreenState extends State<AppCheckScreen> {
  bool _isLoading = true;
  String _status = 'Checking...';

  @override
  void initState() {
    super.initState();
    print('🔍 AppCheckScreen initialized');
    _checkApp();
  }

  Future<void> _checkApp() async {
    print('🔍 Checking app status...');

    await Future.delayed(const Duration(seconds: 1));

    try {
      // Check if Firebase is initialized
      final app = Firebase.app();
      print('✅ Firebase app found: ${app.name}');

      setState(() {
        _status = 'Firebase OK! Navigating...';
      });

      await Future.delayed(const Duration(seconds: 1));

      // Navigate to sign in screen
      if (mounted) {
        print('🚀 Navigating to SignInScreen...');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }

    } catch (e) {
      print('❌ Firebase check error: $e');
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️  Building AppCheckScreen');

    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.rocket_launch,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            Text(
              _status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Platform: ${kIsWeb ? "WEB 🌐" : "MOBILE 📱"}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Check console for detailed logs',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}