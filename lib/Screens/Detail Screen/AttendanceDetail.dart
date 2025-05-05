import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
}
Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');
class AttendanceDetail extends StatefulWidget{
  AttendanceDetailState createState()=>AttendanceDetailState();
  final int id;

   const AttendanceDetail(this.id);
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
    print(widget.id);
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
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title:Text(
              'Attendance  Detail',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      body: Padding(padding: EdgeInsets.all(10),
      child: Container(
        child: Text("Attendance Detail"),
      ),
      ),
    );
  }
}