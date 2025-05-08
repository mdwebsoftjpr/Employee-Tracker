import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: AdminVisitreport()));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

class AdminVisitreport extends StatefulWidget {
  const AdminVisitreport({Key? key}) : super(key: key);

  @override
  AdminVisitreportState createState() => AdminVisitreportState();
}

class AdminVisitreportState extends State<AdminVisitreport> {
  int? ComId;
  DateTime? selectedMonth;
  int MonthNo = DateTime.now().month;
  int YearNo = DateTime.now().year;
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    VisitDetail();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      print("Sahil$user");
      setState(() {
        ComId = user['id'] ?? 0;
      });
    }
  }

  void VisitDetail() async {
    print("$ComId,$MonthNo,$YearNo");
    try {
      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/getEmployeeActivity.php',
      );
      final Map<String, dynamic> requestBody = {"company_id": "${ComId ?? ''}"};

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);
      final success = data['success'];
      final message = data['message'] ?? 'No message';

      if (success) {
        final AttData = data['data'];
        print(AttData);

        // Checking if the returned data is a List of Maps
        if (AttData != null && AttData is List) {
          setState(() {
            attendanceData = List<Map<String, dynamic>>.from(AttData);
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } else {
        setState(() {
          attendanceData = [];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _pickMonth() {
    showMonthPicker(context: context, initialDate: DateTime.now()).then((date) {
      if (date != null) {
        setState(() {
          MonthNo = date.month;
          YearNo = date.year;
        });
        VisitDetail();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Attendance Detail',
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
            onPressed: _pickMonth,
            tooltip: "Pick Month",
          ),
        ],
      ),
      body: attendanceData.isEmpty
          ? Center(
              child: Text(
                "Attendance Not Found",
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
                    margin: EdgeInsets.only(
                      top: devicePixelRatio * 2,
                      left: devicePixelRatio * 3.5,
                      right: devicePixelRatio * 3.5,
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
                                  'https://testapi.rabadtechnology.com/${data['image']}',
                                  width: devicePixelRatio * 35,
                                  height: devicePixelRatio * 30,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Text(data['NameOfCustomer']),
                            ],
                          ),
                        ),
                        SizedBox(width: devicePixelRatio * 3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Address 1: ${data['address'] ?? ''}",
                                style: TextStyle(
                                  fontSize: deviceWidth * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: devicePixelRatio * 3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Address 2: ${data['address2'] ?? ''}",
                                style: TextStyle(
                                  fontSize: deviceWidth * 0.04,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: devicePixelRatio * 3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  final startString = data['start_Location'];
                                  final endString = data['end_Location'];

                                  if (startString != null &&
                                      endString != null &&
                                      startString.isNotEmpty &&
                                      endString.isNotEmpty) {
                                    try {
                                      // Print out the raw data to debug
                                      print("Start location: $startString");
                                      print("End location: $endString");

                                      // Split the string by commas, ensure there are no leading/trailing spaces
                                      final startParts =
                                          startString.split(',').map((part) => part.trim()).toList();
                                      final endParts =
                                          endString.split(',').map((part) => part.trim()).toList();

                                      // Check if both coordinates have exactly two parts (latitude and longitude)
                                      if (startParts.length == 2 && endParts.length == 2) {
                                        final start = LatLng(
                                          double.parse(startParts[0]),
                                          double.parse(startParts[1]),
                                        );
                                        final end = LatLng(
                                          double.parse(endParts[0]),
                                          double.parse(endParts[1]),
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
                                          SnackBar(content: Text('Invalid coordinate format (expected lat, lon)')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error parsing coordinates: $e')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Location data not available')),
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
