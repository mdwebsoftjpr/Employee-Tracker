import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:employee_tracker/Screens/image FullScreen/fullScreenImage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
}

final LocalStorage localStorage = LocalStorage('employee_tracker');
Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class Empvisitrep extends StatefulWidget {
  @override
  EmpvisitrepState createState() => EmpvisitrepState();
}

class EmpvisitrepState extends State<Empvisitrep> {
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
      } else {
        setState(() {
          attendanceData.clear(); // clears the list in place
        });
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

Future<void> showDetail(
  BuildContext context,
  Map<String, dynamic> visit,
) async {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(child: Text(
              "Visit Details:-",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),),
            SizedBox(height: 10),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImageViewer(imageUrl: visit['imagev']),
                        ),
                      );
                    },
                    child: Container(
                       width: MediaQuery.of(context).devicePixelRatio*30,
                      height: MediaQuery.of(context).devicePixelRatio*55,
                      child: Image.network(
                      visit['imagev'] ?? '',
                     
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.broken_image),
                    ),
                    )
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name Of Customer: ${visit['NameOfCustomer'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).devicePixelRatio*5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Concerned Person: ${visit['concernedperson'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).devicePixelRatio*5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Start Time: ${visit['time'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).devicePixelRatio*5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "End Time: ${visit['end'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).devicePixelRatio*5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Address: ${visit['address'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).devicePixelRatio*5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Location Address: ${visit['address2'] ?? 'N/A'}",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).devicePixelRatio*5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      );
    },
  );
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
            fontSize: devicePixelRatio * 7,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.02),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Date",
                      style: TextStyle(
                        fontSize: devicePixelRatio * 5,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 3),
                    IconButton(
                      icon: Icon(
                        Icons.date_range,
                        color: Colors.white,
                        size: deviceWidth * 0.07,
                      ),
                      onPressed: _pickDate,
                      tooltip: "Pick Date",
                    ),
                  ],
                ),
                SizedBox(width: deviceWidth * 0.01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Month",
                      style: TextStyle(
                        fontSize: devicePixelRatio * 5,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 3),
                    IconButton(
                      icon: Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                        size: deviceWidth * 0.07,
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
      body:
          attendanceData.isEmpty
              ? Center(
                child: Text(
                  "Visit Not Found",
                  style: TextStyle(fontSize: deviceWidth * 0.06),
                ),
              )
              : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final item = attendanceData[index];
                  final List<dynamic> visits = item['data'] ?? [];
                  List<String> startLoc = [];
                  List<String> endLoc = [];

                  if (visits.isNotEmpty) {
                    for (var visit in visits) {
                      startLoc.add(visit['start_Location'] ?? '0.0, 0.0');
                      endLoc.add(visit['end_Location'] ?? '0.0, 0.0');
                    }
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5,), Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("You Can See :-"),SizedBox(width: devicePixelRatio*5,),
                            ElevatedButton(
                        onPressed: () {
                          List<LatLng> allPoints = [];

                          for (var visit in visits) {
                            final startCoord =
                                visit['start_Location']?.split(',') ?? [];
                            final endCoord =
                                visit['end_Location']?.split(',') ?? [];

                            if (startCoord.length == 2 &&
                                endCoord.length == 2) {
                              allPoints.add(
                                LatLng(
                                  safeParseDouble(startCoord[0]),
                                  safeParseDouble(startCoord[1]),
                                ),
                              );
                              allPoints.add(
                                LatLng(
                                  safeParseDouble(endCoord[0]),
                                  safeParseDouble(endCoord[1]),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Invalid coordinate format for a visit',
                                  ),
                                ),
                              );
                            }
                          }

                          if (allPoints.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        SimpleMapScreen(points: allPoints),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'No valid location data available',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF03a9f4), // Button color
                          fixedSize: Size(
                            double.infinity,
                            devicePixelRatio*8,
                          ), // Full width, height of 60 pixels
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              devicePixelRatio*5,
                            ), // Rounded corners
                          ),
                        ),
                        child: Text(
                          "All Visits",
                          style: TextStyle(
                            fontSize: devicePixelRatio*5, // Adjust font size if necessary
                            color: Colors.white,
                          ),
                        ),
                      ),
                          ],
                        ),
                      SizedBox(height: 5,),
                      ...visits.map((visit) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: devicePixelRatio*5,
                            vertical: devicePixelRatio*2,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                visit['imagev'] ?? '',
                                width: devicePixelRatio*22,
                                height: devicePixelRatio*22,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.broken_image),
                              ),
                            ),
                            title: Text(
                              visit['NameOfCustomer'] ?? 'No Customer Name',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Start: ${visit['time'] ?? 'N/A'}"),
                                Text("End: ${visit['end'] ?? 'N/A'}"),
                              ],
                            ),
                            trailing: Column(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (visits.isNotEmpty) {
                                        showDetail(context, visit);
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                      fixedSize: Size(
                                        devicePixelRatio * 27,
                                        devicePixelRatio * 8,
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
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.mapLocationDot,
                                      color: Color(0xFF03a9f4),
                                      size: devicePixelRatio * 6,
                                    ),
                                    onPressed: () {
                                      List<LatLng> points = [];

                                      if (visit['start_Location'] != null &&
                                          visit['end_Location'] != null) {
                                        final startCoord =
                                            visit['start_Location']
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList();
                                        final endCoord =
                                            visit['end_Location']
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList();

                                        if (startCoord.length == 2 &&
                                            endCoord.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(startCoord[0]),
                                              safeParseDouble(startCoord[1]),
                                            ),
                                          );
                                          points.add(
                                            LatLng(
                                              safeParseDouble(endCoord[0]),
                                              safeParseDouble(endCoord[1]),
                                            ),
                                          );

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
                                                'Invalid coordinate format',
                                              ),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Location data is missing',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              ),
    );
  }
}
