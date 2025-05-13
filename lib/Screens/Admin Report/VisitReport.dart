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
  List<String> StartLoc = [];
  List<String> EndLoc = [];
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
      VisitDetail();
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
        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(
            responseData['data'],
          );
        });
        if (responseData['success'] == true && responseData['data'] != null) {
          List<dynamic> outerData = responseData['data'];

          for (var employee in outerData) {
            List<dynamic> visits = employee['data'];
            for (var visit in visits) {
              StartLoc.add(visit['start_Location']);
              EndLoc.add(visit['end_Location']);
            }
            // Optional: Print them
            print("Start Points: $StartLoc");
            print("End Points: $EndLoc");
          }
        } else {
          print("No data found or response unsuccessful.");
        }
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
      return double.parse(input.replaceAll('"', '').replaceAll("'", '').trim());
    } catch (e) {
      print("Error parsing double: $e");
      return 0.0;
    }
  }

  /* void VisitPerson(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        final dpi = MediaQuery.of(context).devicePixelRatio;

      Text("dsioa");
      },
    );
  } */

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
      body:
          attendanceData.isEmpty
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
                  dynamic userDataRaw = data['data'];
                  Map<String, dynamic>? userData;

                  if (userDataRaw is Map<String, dynamic>) {
                    userData = userDataRaw;
                  } else if (userDataRaw is String) {
                    try {
                      userData = jsonDecode(userDataRaw);
                    } catch (e) {
                      print("Could not parse userData string: $e");
                    }
                  } else if (userDataRaw is List && userDataRaw.isNotEmpty) {
                    userData = Map<String, dynamic>.from(userDataRaw[0]);
                  }

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
                          // Image and Name
                          Expanded(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    data['image'] ?? '',
                                    width: devicePixelRatio * 25,
                                    height: devicePixelRatio * 25,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Icon(Icons.error),
                                  ),
                                ),
                                Text(data['name'] ?? ''),
                              ],
                            ),
                          ),
                          SizedBox(width: devicePixelRatio * 3),
                          // Visit count
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  "Total Visit:- ",
                                  style: TextStyle(
                                    fontSize: devicePixelRatio * 4,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: devicePixelRatio * 4,
                                    vertical: devicePixelRatio * 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF03a9f4),
                                    borderRadius: BorderRadius.circular(
                                      devicePixelRatio * 6,
                                    ),
                                  ),
                                  child: Text(
                                    "${data['total_visit'] ?? 0}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: devicePixelRatio * 3),
                          // Buttons
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (userData != null && userData.isNotEmpty) {
                                    /* VisitPerson(context, userData); */
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "No detailed data available",
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF03a9f4),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "More",
                                  style: TextStyle(
                                    fontSize: devicePixelRatio * 4,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: devicePixelRatio * 2),
                              IconButton(
                                onPressed: () {
                                  if (StartLoc.isNotEmpty &&
                                      EndLoc.isNotEmpty) {
                                    try {
                                      List<LatLng> points = [];

                                      for (
                                        int i = 0;
                                        i < StartLoc.length;
                                        i++
                                      ) {
                                        final startCoord =
                                            StartLoc[i]
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList();
                                        if (startCoord.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(startCoord[0]),
                                              safeParseDouble(startCoord[1]),
                                            ),
                                          );
                                        }
                                      }

                                      for (int i = 0; i < EndLoc.length; i++) {
                                        final endCoord =
                                            EndLoc[i]
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList();
                                        if (endCoord.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(endCoord[0]),
                                              safeParseDouble(endCoord[1]),
                                            ),
                                          );
                                        }
                                      }

                                      if (points.isNotEmpty) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => SimpleMapScreen(
                                                  points: points,
                                                ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'No valid coordinates found',
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error parsing coordinates: $e',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Location data is empty'),
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
                            ],
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
