import 'dart:convert';
import 'package:final_ammonation_project/details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'model_ammo_project.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Api_ammunation_project extends StatefulWidget {

  final String Ford = "Mustang";
  final String Ford2= "muscle";
  final User? user;
  const Api_ammunation_project({super.key, this.user });

  @override
  State<Api_ammunation_project> createState() => _Api_ammunation_projectState();
}

class _Api_ammunation_projectState extends State<Api_ammunation_project> {
  List<AmmoItem> data = [];

  Future<void> fetchdata() async {
    final response = await http.get(
      Uri.parse(
        "https://raw.githubusercontent.com/ShahedAhmed894/ammunation_project_api/refs/heads/main/ammunition_api_project",
      ),
    );

    if (response.statusCode == 200) {
      final body = utf8.decode(response.bodyBytes); // handles encoding
      List<dynamic> jsonlist = jsonDecode(body);
      setState(() {
        data = jsonlist.map((json) => AmmoItem.fromJson(json)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        centerTitle: true,
        title: const Text("Ammunition Shop"),
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Container(
            height: 450,
            width: 300,
            // color:Color(0xff16476A),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Details_page(output: data[index]), // পুরো object পাঠান
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    width: 300,
                    child: Column(
                      children: [
                        Image.network("${data[index].imageUrl}"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${data[index].name}'),
                            Text(
                              '${data[index].price.toStringAsFixed(0)} ${data[index].currency}',
                            )
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text("made in:germany"),
                        ),
                      ],
                    ),
                  ),
                )

              ],
            ),
          );

        },
      ),
    );
  }
}