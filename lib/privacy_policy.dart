import 'package:flutter/material.dart';

class privacy_page extends StatefulWidget {
  const privacy_page({super.key});

  @override
  State<privacy_page> createState() => _privacy_pageState();
}

class _privacy_pageState extends State<privacy_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Privacy Policy"),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            """Ammunition Store Privacy Policy

Your personal information is treated as strictly confidential.

When you sign up, or make a purchase, with Ammunitionstore.com none of your information leaves our servers. You are not put on any lists, or submitted to any databank.

Accordingly, we have developed this Policy in order for you to understand how we collect, use, communicate, disclose and make use of personal information. We will safeguard any personal information unless sharing that information is required to comply with a criminal investigation.

The following outlines our privacy policy.

Before or at the time of collecting personal information, we will identify the purposes for which information is being collected.

We will collect and use personal information solely with the objective of fulfilling those purposes specified by us and agreed to by the customer.

We will collect personal information by lawful and fair means and, where appropriate, with the knowledge or consent of the individual concerned.

Personal data should be relevant to the purposes for which it is to be used, and, to the extent necessary for those purposes, all records should be accurate, complete, and up-to-date.

We will protect personal information by reasonable and proven security safeguards against loss or theft, as well as unauthorized access, disclosure, copying, use or modification.

We will make readily available to customers information about our policies and practices relating to the management of personal information.

Bullet Hole Advertising Privacy

We do not share or disclose any of our customer information. We do not use any customer information for 3rd party marketing. We do not participate in any spam mailing or bulk mailing. All email lists generated are on an opt-in basis, such as our newsletter or promotional opt-ins.

Bullet Hole Credit Card Privacy

We do not store credit card information on our web servers. This is for your safety and protection. We do not offer any marketable information to any third party contractor or group. All transactions are done through encrypted https services and are secured with SSL (secure sockets layer) technology.""",
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}