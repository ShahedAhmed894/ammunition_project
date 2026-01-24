import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:final_ammonation_project/setting%20page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'api_ammunation_project.dart';
import 'chatbot.dart';
import 'nid_varification/qrcod_scanner.dart';

class Curve_page extends StatefulWidget {
  const Curve_page({super.key});

  @override
  State<Curve_page> createState() => _Curve_pageState();
}

class _Curve_pageState extends State<Curve_page> {
  late List<Widget> book;
  int page = 0;
  bool _isFirebaseReady = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  Future<void> _initializePages() async {
    try {
      // Verify Firebase is initialized
      await Firebase.app();
      print('✅ Firebase verified in Curve_page');

      setState(() {
        book = [
          Api_ammunation_project(),
          ScannerPage(),
          ChatScreen(),
          settings_page()
        ];
        _isFirebaseReady = true;
        page = 0;
      });
    } catch (e) {
      print('❌ Firebase not ready in Curve_page: $e');
      setState(() {
        _errorMessage = 'Firebase initialization error: $e';
        _isFirebaseReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFirebaseReady) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                _errorMessage ?? 'Initializing app...',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.green,
        // title: Text("curve page"),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: page,
        onTap: (index) {
          setState(() {
            page = index;
          });
        },
        items: const [
          Icon(Icons.home),
          Icon(Icons.qr_code),
          Icon(Icons.help_center),
          Icon(Icons.settings),
        ],
      ),
      body: book[page],
    );

  }
}