import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(Attendancerep());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Attendancerep extends StatefulWidget {
  @override
  AttendancerepState createState() => AttendancerepState();
}

class AttendancerepState extends State<Attendancerep> {
  DateTime? selectedDate;
  String name = "key_person";
  String comName = 'Company';
  String username = "";
  String formattedDate = '';
  List<Map<String, dynamic>> attendanceDeta = [];

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

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
      attendance();
    }
  }

  void attendance() async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/attendence_report.php',
    );
    try {
      final Map<String, dynamic> requestBody = {
        "date": formattedDate,
        "username": name,
        "company_name": comName,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);
      var success = responseData['success'];
      var message = responseData['message'];
      var data = responseData['data'];

      if (success == true) {
        setState(() {
          attendanceDeta = List<Map<String, dynamic>>.from(data);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Row(
          children: [
            Text(
              'Attendance Report',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            TextButton(
              onPressed: () => _pickDate(context),
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              child: Text('Pick a Date'),
            ),
          ],
        ),
      ),
      body: selectedDate != null
    ? attendanceDeta.isEmpty
        ? Center(
            child: Text(
              "No Data found",
              style: TextStyle(fontFamily: 'MyFont', fontSize: 15),
            ),
          )
        : ListView.builder(
            itemCount: attendanceDeta.length,
            itemBuilder: (context, index) {
              final item = attendanceDeta[index];
              return Container(
                margin: EdgeInsets.only(top: 10,left:MediaQuery.of(context).size.width * 0.05,right: MediaQuery.of(context).size.width * 0.05 ),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 215, 229, 241),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text("Date: ${item['date']}"),
                  subtitle: Text(
                    "Time In: ${item['time']} | Time Out: ${item['time_out']} | Total Time: ${item['total_time']}",
                  ),
                ),
              );
            },
          )
    : Center(
        child: Text(
          "Please Select Date",
          style: TextStyle(fontFamily: 'MyFont', fontSize: 15),
        ),
      )
    );
  }
}
