import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
}

final LocalStorage localStorage = LocalStorage('employee_tracker');
Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class Empvisitrep extends StatefulWidget {
  EmpvisitrepSate createState() => EmpvisitrepSate();
}

class EmpvisitrepSate extends State<Empvisitrep> {
  int? ComId;
  String day = '';
  String month = '';
  int? empId;
  List<Map<String, dynamic>> attendanceData = [];
  List<String> StartLoc = [];
  List<String> EndLoc = [];

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
        empId = user['id'] ?? 0;
        ComId = user['company_id'] ?? 0;
      });
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
        month = '';
      });
      VisitDetail();
    }
  }

  void _pickMonth() async {
    DateTime? selected = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        // Format month as yyyy-MM
        month = DateFormat('MM').format(selected);
        day = '';
      });
      VisitDetail();
    }
  }

  void VisitDetail() async {
    try {
      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/getSingleEmployeeActivity.php',
      );
      final Map<String, dynamic> requestBody = {
        "company_id": ComId,
        "month": month,
        "date": day,
        "emp_id": empId,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(
            responseData['data'],
          );
        });
        if (attendanceData.isNotEmpty && attendanceData[0]['data'] != null) {
          List<dynamic> visits = attendanceData[0]['data'];
          for (var visit in visits) {
            StartLoc.add(visit['start_Location']);
            EndLoc.add(visit['end_Location']);
          }
          print(StartLoc);
          print(EndLoc);
        } else {
          print("No data found");
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${responseData['message']}')));
      }
    } catch (e) {
      print("Error fetching data: $e");
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

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee Visit',
          style: TextStyle(
            color: Colors.white,
            fontSize: devicePixelRatio * 7, // Reduced font size for the title
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: deviceWidth * 0.02,
            ), // Reduced padding to avoid overflow
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Column for Date selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Date",
                      style: TextStyle(
                        fontSize:
                            devicePixelRatio *
                            5, // Reduced font size for the label
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 3),
                    IconButton(
                      icon: Icon(
                        Icons.date_range,
                        color: Colors.white,
                        size: deviceWidth * 0.07, // Reduced icon size
                      ),
                      onPressed: _pickDate,
                      tooltip: "Pick Date",
                    ),
                  ],
                ),
                SizedBox(
                  width: deviceWidth * 0.01,
                ), // Spacing between Date and Month
                // Column for Month selection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Month",
                      style: TextStyle(
                        fontSize:
                            devicePixelRatio *
                            5, // Reduced font size for the label
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 3),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: deviceWidth * 0.07, // Reduced icon size
                      ),
                      onPressed: _pickMonth,
                      tooltip: "Pick Month",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      body: Container(
        child: Column(
          children: [
            SizedBox(height: 10),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Set radius here
                child: Image.network(
                  '${attendanceData[0]['image'] ?? ''}',
                  width: deviceWidth * 0.50, // Set width
                  height: deviceWidth * 0.50, // Set height
                  fit: BoxFit.cover, // To fill the container without distortion
                  errorBuilder:
                      (context, error, stackTrace) => Icon(Icons.error),
                ),
              ),
            ),
            SizedBox(height: 10),
            IconButton(
              onPressed: () {
                if (StartLoc.isNotEmpty && EndLoc.isNotEmpty) {
                  try {
                    List<LatLng> points = [];

                    for (int i = 0; i < StartLoc.length; i++) {
                      final startCoord =
                          StartLoc[i].split(',').map((e) => e.trim()).toList();
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
                          EndLoc[i].split(',').map((e) => e.trim()).toList();
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
                          builder: (context) => SimpleMapScreen(points: points),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No valid coordinates found')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error parsing coordinates: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Location data is empty')),
                  );
                }
              },
              icon: Icon(
                FontAwesomeIcons.mapLocationDot,
                color: Color(0xFF03a9f4),
                size: devicePixelRatio * 10,
              ),
            ),
            Text("Go To Map")
          ],
        ),
      ),
    );
  }
}



/*  final List<LatLng> points;
  const SimpleMapScreen({Key? key, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(points);
    return Scaffold(
      appBar: AppBar(title: Text('Visit Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: points.isNotEmpty ? points.first : LatLng(0, 0),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: points.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;

              return Marker(
                width: 40,
                height: 40,
                point: point,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
                    Positioned(
                      top: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}', // Serial number starts at 1
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
 */