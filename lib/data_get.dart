import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class Data_get extends StatefulWidget {
  const Data_get({super.key});

  @override
  State<Data_get> createState() => _Data_getState();
}

class _Data_getState extends State<Data_get> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text("data get"),
      ),
      body: Column(
        children: [
          Center(
            child: ElevatedButton(onPressed:() {
              FirebaseFirestore.instance.collection("Data").add({"Name":"Ammunition_project"});
            }, child: Text("send data")),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection("Data").snapshots(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return Column(
                    children: snapshot.data!.docs.map((e) {
                      return Text("Name:${e["Name"]}");
                    },).toList()
                );
              }
              return Text("No data found");
            },

          )

        ],
      ),
    );
  }
}
