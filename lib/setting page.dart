import 'package:final_ammonation_project/privacy_policy.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notification_page.dart';

class settings_page extends StatefulWidget {
  const settings_page({super.key});

  @override
  State<settings_page> createState() => _settings_pageState();
}

class _settings_pageState extends State<settings_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("settings"),
          backgroundColor: Colors.red,
          centerTitle: true,
        ),
        body: Column(
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
              },
              child: Card(
                child: ListTile(
                  title: Text("Notifications"),
                  leading: Icon(Icons.notifications),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => privacy_page()));
              },
              child: Card(
                child: ListTile(
                  title: Text("Privacy policy"),
                  leading: Icon(Icons.privacy_tip),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse('tel:01726156318');
                await launchUrl(url);
              },
              child: Card(
                child: ListTile(
                  title: Text("Helpline"),
                  leading: Icon(Icons.call),
                  subtitle: Text("01726156318"),
                ),
              ),
            ),
          ],
        ));
  }
}