import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: Master()));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Master extends StatefulWidget {
  @override
  MasterState createState() => MasterState();
}

class MasterState extends State<Master> {
  String comName = 'Compamy';
  int? comId;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController designation = TextEditingController();

  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);

      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        comId = user['id'] ?? 0;
        print("comId $comId");
      });
    }
  }

  void AddMaster() async {
    String Designation = designation.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        elevation: 0,
        title: Text(
          'Create Company',
          style: TextStyle(
            color: Color.fromARGB(255, 254, 255, 255),
            fontSize: 8 * MediaQuery.of(context).devicePixelRatio,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
      Container(
        padding: EdgeInsets.only(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.07,
          right: MediaQuery.of(context).size.width * 0.07,
          bottom: 0,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
          'Add Designation',
          style: TextStyle(
            color: Colors.black,
            fontSize: 8 * MediaQuery.of(context).devicePixelRatio,
            fontWeight: FontWeight.bold,
          ),),
                SizedBox(height: 10),
                 TextFormField(
                  controller: designation,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Designation',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.person),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Designayion';
                    }
                    return null;
                  },
                ),
               
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => {},
                  child: Text(
                    "Create Designation",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
      );
  }
}
