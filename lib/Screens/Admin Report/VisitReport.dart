import 'package:employee_tracker/Screens/Admin Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: AdminVisitreport()));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class AdminVisitreport extends StatefulWidget {
  const AdminVisitreport({Key? key}) : super(key: key);

  @override
  AdminVisitreportState createState() => AdminVisitreportState();
}

class AdminVisitreportState extends State<AdminVisitreport> {
  int? ComId;
  String day = '';
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    day = DateFormat('yyyy-MM-dd').format(now);
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        ComId = user['id'] ?? 0;
      });
      VisitDetail(); // Move here after ComId is set
    }
  }

  void VisitDetail() async {
  try {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/getEmployeeActivity.php',
    );

    final Map<String, dynamic> requestBody = {
      "company_id": ComId,
      "month": "",
      "date": day,
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    final responseData = jsonDecode(response.body);
    print("Response: $responseData");

    if (responseData['success'] == true) {
      List<dynamic> employees = responseData['data'];

      List<Map<String, dynamic>> allVisits = [];

      for (var emp in employees) {
        List<dynamic> visits = emp['data'];
        for (var visit in visits) {
          allVisits.add(Map<String, dynamic>.from(visit));
        }
      }

      setState(() {
        attendanceData = allVisits; // You now have a flat list of all visits
      });

      print("Total visits: ${attendanceData}");
    } else {
      print("Error: ${responseData['message']}");
    }
  } catch (e) {
    print("Error fetching data: $e");
  }
}

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        day = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      VisitDetail();
    }
  }

  double safeParseDouble(String input) {
    try {
      return double.parse(
        input
            .replaceAll('"', '')
            .replaceAll("'", '')
            .replaceAll('\n', '')
            .replaceAll('\r', '')
            .trim(),
      );
    } catch (e) {
      print("Error parsing double: $e");
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Visit Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: deviceWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: Colors.white,
              size: deviceWidth * 0.09,
            ),
            onPressed: _pickDate,
            tooltip: "Pick Date",
          ),
        ],
      ),
      body: attendanceData.isEmpty
          ? Center(
              child: Text(
                "Visit Not Found",
                style: TextStyle(fontSize: deviceWidth * 0.05),
              ),
            )
          : ListView.builder(
              itemCount: attendanceData.length,
              itemBuilder: (context, index) {
                final data = attendanceData[index];
                return Padding(
                  padding: EdgeInsets.all(devicePixelRatio * .5),
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      vertical: devicePixelRatio * 2,
                      horizontal: devicePixelRatio * 3.5,
                    ),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(deviceWidth * 0.03),
                      color: const Color.fromARGB(255, 247, 239, 230),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  data['image'] ?? '',
                                  width: devicePixelRatio * 35,
                                  height: devicePixelRatio * 30,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error),
                                ),
                              ),
                              Text(data['NameOfCustomer'] ?? ''),
                            ],
                          ),
                        ),
                        SizedBox(width: devicePixelRatio * 3),
                        Expanded(
                          child: Text(
                            "Address 1: ${data['address'] ?? ''}",
                            style: TextStyle(fontSize: deviceWidth * 0.04),
                          ),
                        ),
                        SizedBox(width: devicePixelRatio * 3),
                        Expanded(
                          child: Text(
                            "Address 2: ${data['address2'] ?? ''}",
                            style: TextStyle(fontSize: deviceWidth * 0.04),
                          ),
                        ),
                        SizedBox(width: devicePixelRatio * 3),
                        Expanded(
                          child: IconButton(
                            onPressed: () {
                              final startString = data['start_Location'];
                              final endString = data['end_Location'];

                              if (startString != null &&
                                  endString != null &&
                                  startString.isNotEmpty &&
                                  endString.isNotEmpty) {
                                try {
                                  final startParts = startString
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList();
                                  final endParts = endString
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList();

                                  if (startParts.length == 2 &&
                                      endParts.length == 2) {
                                    final start = LatLng(
                                      safeParseDouble(startParts[0]),
                                      safeParseDouble(startParts[1]),
                                    );
                                    final end = LatLng(
                                      safeParseDouble(endParts[0]),
                                      safeParseDouble(endParts[1]),
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SimpleMapScreen({
                                          'start': start,
                                          'end': end,
                                        }),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Invalid coordinate format'),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error parsing coordinates'),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Location data not available'),
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              FontAwesomeIcons.mapLocationDot,
                              color: Color(0xFF03a9f4),
                              size: devicePixelRatio * 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
