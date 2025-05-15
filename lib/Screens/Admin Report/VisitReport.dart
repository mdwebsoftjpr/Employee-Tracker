import 'package:employee_tracker/Screens/Admin Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:employee_tracker/Screens/image FullScreen/fullScreenImage.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

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
  String month = '';
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
        "month": month,
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
              Center(
                child: Text(
                  "Visit Details:-",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10),

              // Row for image and customer details
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => FullScreenImageViewer(
                                  imageUrl: visit['imagev'],
                                ),
                          ),
                        );
                      },
                      child: Container(
                        width: MediaQuery.of(context).devicePixelRatio * 30,
                        height: MediaQuery.of(context).devicePixelRatio * 55,
                        child: Image.network(
                          visit['imagev'] ?? '',

                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Space between image and text
                  // Column to hold all the text data
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Name Of Customer: ${visit['NameOfCustomer'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Concerned Person: ${visit['concernedperson'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Start Time: ${visit['time'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "End Time: ${visit['end'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Address: ${visit['address'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "Location Address: ${visit['address2'] ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
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
          'Visit Report',
          style: TextStyle(
            color: Colors.white,
            fontSize: deviceWidth * 0.06,
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
                  style: TextStyle(fontSize: deviceWidth * 0.05),
                ),
              )
              : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final data = attendanceData[index];

                  List<String> startLoc = [];
                  List<String> endLoc = [];
                  List<dynamic> visits = data['data'] ?? [];

                  if (visits.isNotEmpty) {
                    for (var visit in visits) {
                      startLoc.add(visit['start_Location']);
                      endLoc.add(visit['end_Location']);
                    }
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
                                  if (visits.isNotEmpty) {
                                    showDetail(context, visits[0]);
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
                                  if (startLoc.isNotEmpty &&
                                      endLoc.isNotEmpty) {
                                    try {
                                      List<LatLng> points = [];

                                      for (
                                        int i = 0;
                                        i < startLoc.length;
                                        i++
                                      ) {
                                        final coord =
                                            startLoc[i]
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList();
                                        if (coord.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(coord[0]),
                                              safeParseDouble(coord[1]),
                                            ),
                                          );
                                        }
                                      }

                                      for (int i = 0; i < endLoc.length; i++) {
                                        final coord =
                                            endLoc[i]
                                                .split(',')
                                                .map((e) => e.trim())
                                                .toList();
                                        if (coord.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(coord[0]),
                                              safeParseDouble(coord[1]),
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
