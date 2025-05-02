import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(Attendance());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Attendance extends StatefulWidget {
  @override
  AttendanceState createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
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

      print("Status Code: ${response.statusCode}");
      print("Raw Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body.isNotEmpty) {
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid or empty response from server")),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
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
                fontSize: MediaQuery.of(context).size.width * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.075),
            TextButton(
              onPressed: () => _pickDate(context),
              style: TextButton.styleFrom(backgroundColor: Colors.white),
              child: Text('Pick a Date'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
               SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 215, 229, 241),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                        'assets/images/bird.jpg',width: 60,
                      ),
                          ),
                         SizedBox(height: 5,),
                      Text("Sahil Nawariya")
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Time In:11:00"),
                          SizedBox(height: 10,),
                          Text("Time Out:20:00"),
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.green, // Background color
                              width: 30,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'P',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Text("Totel Hours:20:00"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
               SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 215, 229, 241),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                        'assets/images/bird.jpg',width: 60,
                      ),
                          ),
                         SizedBox(height: 5,),
                      Text("Sahil Nawariya")
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Time In:11:00"),
                          SizedBox(height: 10,),
                          Text("Time Out:20:00"),
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.green, // Background color
                              width: 30,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'P',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Text("Totel Hours:20:00"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
               SizedBox(height: 10),
              Container(
                width: MediaQuery.of(context).size.width * 0.95,
                height: 80,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 215, 229, 241),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    children: [
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                        'assets/images/bird.jpg',width: 60,
                      ),
                          ),
                         SizedBox(height: 5,),
                      Text("Sahil Nawariya")
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Time In:11:00"),
                          SizedBox(height: 10,),
                          Text("Time Out:20:00"),
                        ],
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              color: Colors.green, // Background color
                              width: 30,
                              height: 30,
                              child: Center(
                                child: Text(
                                  'P',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          Text("Totel Hours:20:00"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
/*  attendanceDeta.isNotEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Please Select Date",
                        style: TextStyle(
                          fontFamily: 'Myfont',
                          fontSize: MediaQuery.of(context).size.width * 0.075,
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : ListView.builder(
                itemCount: attendanceDeta.length,
                itemBuilder: (context, index) {
                  final item = attendanceDeta[index];
                  return Container(
                    margin: EdgeInsets.only(
                      top: 10,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                    ),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 215, 229, 241),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text("Date: ${item['date']}"),
                      subtitle: Text(
                        "Time In:masmd /* ${item['time']} */ | Time Out:sfs/*  ${item['time_out']} */ | Total Time: nbadia/* ${item['total_time']} */",
                      ),
                    ),
                  );
                },
              ), */