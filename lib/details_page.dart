import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'model_ammo_project.dart';

class Details_page extends StatelessWidget {
  final AmmoItem output; // AmmoItem type দিন

  const Details_page({Key? key, required this.output}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(output.name ?? ""),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(output.imageUrl),
            SizedBox(height: 16),
            Text(
              'Name: ${output.name}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Price: ${output.price.toStringAsFixed(0)} ${output.currency}',
              style: TextStyle(fontSize: 18),
            ),
            // অন্যান্য data দেখান
          ],
        ),
      ),
    );
  }
}