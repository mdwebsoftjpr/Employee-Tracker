import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(AttendanceDetail());
}
Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');
class AttendanceDetail extends StatefulWidget{
  AttendanceDetailState createState()=>AttendanceDetailState();
}

class AttendanceDetailState extends State<AttendanceDetail>{
String name = "key_person";
  String comName = 'Company';
  String username = "";
  @override
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
        name = user['name'] ?? 'Default User';
        username = user['username'] ?? 'Default User';
      });
    }
    var visit = localStorage.getItem('visitout') ?? false;
    if (visit == true) {
      print("Visit out status: $visit");
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}