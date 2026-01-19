import 'package:flutter/material.dart';

class employeelist_page extends StatefulWidget {
  const employeelist_page({super.key});

  @override
  State<employeelist_page> createState() => _employeelist_pageState();
}

class _employeelist_pageState extends State<employeelist_page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Employee Details"),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://imgs.search.brave.com/hIegl9WvJsucoTTOlwZjRDsgRZRUG51A1uSp6NwxwuA/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly91cGxv/YWQud2lraW1lZGlh/Lm9yZy93aWtpcGVk/aWEvY29tbW9ucy84/Lzg0L0pvaG5fQ2Vu/YV8wNDIwMjVfKGNy/b3BwZWQpLmpwZw'),
                          backgroundColor: Colors.grey[200],
                        ),
                        SizedBox(height: 20),
                        Text("Name: John Cena"),
                        SizedBox(height: 10),
                        Text("Designation: Manager"),
                        SizedBox(height: 10),
                        Text("Email: johncena@gmail.com"),
                        SizedBox(height: 10),
                        Text("Phone Number: 01726156350"),
                        SizedBox(height: 10),
                        Text("Address: Dhaka, Bangladesh"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://imgs.search.brave.com/1Wi4AcnM16XawOHRhBisNKsv9BL1u4AfozzbCWFNEGE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly91cGxv/YWQud2lraW1lZGlh/Lm9yZy93aWtpcGVk/aWEvY29tbW9ucy81/LzVkL1NoZWFtdXNf/QXByaWxfMjAxNC5q/cGc'),
                          backgroundColor: Colors.grey[200],
                        ),
                        SizedBox(height: 20),
                        Text("Name: Sheamus"),
                        SizedBox(height: 10),
                        Text("Designation: Salesman"),
                        SizedBox(height: 10),
                        Text("Email: sheamus@gamil.com"),
                        SizedBox(height: 10),
                        Text("Phone Number: 01726156380"),
                        SizedBox(height: 10),
                        Text("Address: Dhaka, Bangladesh"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://imgs.search.brave.com/eiZ16_f3p6Uc6qHK8DmPpZrrK5QeDDbfqKDTk0QFdTo/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9tZWRp/YS53YmlyLmNvbS9h/c3NldHMvV0JJUi9p/bWFnZXMvMTZkMjZj/YTEtOTcyYy00OWYw/LTkzMWMtNDQyNmEz/MGE5OWFjLzE2ZDI2/Y2ExLTk3MmMtNDlm/MC05MzFjLTQ0MjZh/MzBhOTlhY18xOTIw/eDEwODAuanBn'),
                          backgroundColor: Colors.grey[200],
                        ),
                        SizedBox(height: 20),
                        Text("Name: Kane"),
                        SizedBox(height: 10),
                        Text("Designation: Salesman"),
                        SizedBox(height: 10),
                        Text("Email: kane@gmail.com"),
                        SizedBox(height: 10),
                        Text("Phone Number: 01726156370"),
                        SizedBox(height: 10),
                        Text("Address: Dhaka, Bangladesh"),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage('https://imgs.search.brave.com/z3wZQlXwXjFPxcmN9rD5YPjQmNPL8qYXDiYKPBPvFEE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly91cGxv/YWQud2lraW1lZGlh/Lm9yZy93aWtpcGVk/aWEvY29tbW9ucy9h/L2E2L1JhbmR5X09y/dG9uX0FwcmlsXzIw/MTQuanBn'),
                          backgroundColor: Colors.grey[200],
                        ),
                        SizedBox(height: 20),
                        Text("Name: Randy Orton"),
                        SizedBox(height: 10),
                        Text("Designation: Assistant Manager"),
                        SizedBox(height: 10),
                        Text("Email: randyorton@gmail.com"),
                        SizedBox(height: 10),
                        Text("Phone Number: 01726156360"),
                        SizedBox(height: 10),
                        Text("Address: Dhaka, Bangladesh"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}