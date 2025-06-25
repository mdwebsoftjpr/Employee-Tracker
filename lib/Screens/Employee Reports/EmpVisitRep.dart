import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:employee_tracker/Screens/Components/Alert.dart';
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
  bool isLoading = true;
  List<Map<String, dynamic>> LocData = [];

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    day = DateFormat('yyyy-MM-dd').format(now);
    _loadUser();
    VisitDetail();
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
        var id = responseData['data'][0];
        setState(() {
          isLoading = false;
          attendanceData = List<Map<String, dynamic>>.from(
            responseData['data'],
          );
          LocData = List<Map<String, dynamic>>.from(responseData['data']);
        });
      } else {
        setState(() {
          isLoading = false;
          attendanceData.clear(); // clears the list in place
        });
        await Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      await Alert.alert(context, "Error fetching data: $e");
    }
  }

  double safeParseDouble(String input) {
    try {
      return double.parse(input.replaceAll('"', '').replaceAll("'", '').trim());
    } catch (e) {
      Alert.alert(context, "Error parsing double: $e");
      return 0.0;
    }
  }

  Future<void> showDetail(
    BuildContext context,
    Map<String, dynamic> visit,
  ) async {
    showDialog(
      context: context,
      builder: (context) {
        double deviceWidth = MediaQuery.of(context).size.width;
        double deviceHeight = MediaQuery.of(context).size.height;
        var ratio;
        if (deviceWidth < deviceHeight) {
          ratio = deviceHeight / deviceWidth;
        } else {
          ratio = deviceWidth / deviceHeight;
        }
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Center(
            child: Text(
              "Visit Details:-",
              style: TextStyle(
                fontSize: ratio * 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop(); // Close dialog first
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
                            width: deviceWidth * .30,
                            height: deviceWidth * .30,
                            decoration: BoxDecoration(color: Colors.grey[200]),
                            child: Image.network(
                              visit['image'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    buildTextDetail(
                      "Organization",
                      visit['NameOfCustomer'],
                      context,
                    ),
                    buildTextDetail(
                      "Concerned Person",
                      visit['concernedperson'],
                      context,
                    ),
                    buildTextDetail("Mobile No.", visit['phoneno'], context),
                    buildTextDetail("Date", visit['date'], context),
                    buildTextDetail("Start Time", visit['time'], context),
                    buildTextDetail("End Time", visit['end'], context),
                    buildTextDetail("Transport", visit['transport'], context),
                    buildTextDetail("Probablity", visit['probablity'], context),
                    buildTextDetail("Prospects", visit['prospects'], context),
                    buildTextDetail("Address", visit['address'], context),
                    buildTextDetail(
                      "Location Address",
                      visit['address2'],
                      context,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: ratio * 7,
                        vertical: ratio * 3,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ratio * 10),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Close"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildTextDetail(String label, dynamic value, BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        "$label: ${value ?? 'N/A'}",
        style: TextStyle(fontSize: ratio * 7, fontWeight: FontWeight.w400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee Visit',
          style: TextStyle(
            fontSize: ratio * 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                        fontSize: ratio * 7,
                        color: Colors.white,
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
                        fontSize: ratio * 7,
                        color: Colors.white,
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
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: ratio * 25,
                      backgroundImage: AssetImage(
                        'assets/splesh_Screen/Emp_Attend.png',
                      ), // Set the background image here
                    ),

                    SizedBox(height: 5),
                    CircularProgressIndicator(color: Color(0xFF03a9f4)),
                  ],
                ),
              )
              : attendanceData.isEmpty
              ? Center(
                child: Text(
                  "Visit Not Found",
                  style: TextStyle(fontSize: ratio * 8),
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
                      ...visits.map((visit) {
                        return Card(
                          color: const Color.fromARGB(255, 247, 239, 230),
                          margin: EdgeInsets.symmetric(
                            horizontal: ratio * 5,
                            vertical: ratio * 2,
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                visit['imagev'] ?? '',
                                width: ratio * 30,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        Icon(Icons.broken_image),
                              ),
                            ),
                            title: Text(
                              visit['NameOfCustomer'] ?? 'No Customer Name',
                              style: TextStyle(fontSize: ratio * 7),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Start:",
                                      style: TextStyle(
                                        fontSize: ratio * 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${visit['end'] ?? 'N/A'}",
                                      style: TextStyle(fontSize: ratio * 6),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "End:",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: ratio * 6,
                                      ),
                                    ),
                                    Text(
                                      "${visit['time'] ?? 'N/A'}",
                                      style: TextStyle(fontSize: ratio * 6),
                                    ),
                                  ],
                                ),
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
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          deviceWidth * 0.07,
                                        ),
                                      ),
                                      elevation: 4,
                                    ),
                                    child: Text("More"),
                                  ),
                                ),
                                Expanded(
                                  child: IconButton(
                                    icon: Icon(
                                      FontAwesomeIcons.mapLocationDot,
                                      color: Color(0xFF03a9f4),
                                      size: ratio * 10,
                                    ),
                                    onPressed: () {
                                      List<LatLng> points = [];

                                      // 1. Add punchin_loc
                                      if (item['punchin_loc'] != null) {
                                        final punchInParts = item['punchin_loc']
                                            .toString()
                                            .split('_');
                                        if (punchInParts.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(punchInParts[0]),
                                              safeParseDouble(punchInParts[1]),
                                            ),
                                          );
                                        }
                                      }

                                      // 2. Add visit start_Location
                                      if (visit['start_Location'] != null) {
                                        final startCoord =
                                            visit['start_Location']
                                                .toString()
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
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Invalid start location format',
                                              ),
                                            ),
                                          );
                                        }
                                      }

                                      // 3. Add punchout_loc
                                      if (item['punchout_loc'] != null) {
                                        final punchOutParts =
                                            item['punchout_loc']
                                                .toString()
                                                .split('_');
                                        if (punchOutParts.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(punchOutParts[0]),
                                              safeParseDouble(punchOutParts[1]),
                                            ),
                                          );
                                        }
                                      }

                                      // Navigate to map if there are valid points
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
                                              'No valid location data available',
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
