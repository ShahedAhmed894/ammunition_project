import 'package:flutter/material.dart';
class Design_hw extends StatefulWidget {
  const Design_hw({super.key});

  @override
  State<Design_hw> createState() => _Design_hwState();
}

class _Design_hwState extends State<Design_hw> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text("design"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            child: Image.network("https://upload.wikimedia.org/wikipedia/commons/8/8f/M1_Garand_Rifle.jpg"),
          )
        ],

      ),
    );
  }
}
