import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:final_ammonation_project/setting%20page.dart';
import 'package:flutter/material.dart';

import 'api_ammunation_project.dart';
import 'chatbot.dart';
import 'nid_varification/qrcod_scanner.dart';
class Curve_page extends StatefulWidget {
  const Curve_page({super.key});

  @override
  State<Curve_page> createState() => _Curve_pageState();
}

class _Curve_pageState extends State<Curve_page> {
  final book = [Api_ammunation_project(),ScannerPage(),ChatScreen(),settings_page()];
  var page = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Colors.green,
        // title: Text("curve page"),
      ),
      bottomNavigationBar: CurvedNavigationBar(

          index: 3,
          onTap: (index) {
            setState(() {
              page = index;
            });
          },
          items: [
            Icon(Icons.home),
            Icon(Icons.qr_code),
            Icon(Icons.help_center),
            Icon(Icons.settings),

          ]
      ),
      body:
      book [page],
    );

  }
}