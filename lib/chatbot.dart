import 'package:flutter/material.dart';
class chatbot_page extends StatefulWidget {
  const chatbot_page({super.key});

  @override
  State<chatbot_page> createState() => _chatbot_pageState();
}

class _chatbot_pageState extends State<chatbot_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chatbot page"),
        backgroundColor: Colors.yellow,
        centerTitle: true,
      ),
      body: Center(
        child: Text("dekha baki"),
      ),
    );
  }
}
