import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(EmpAttdetail());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

class EmpAttdetail extends StatefulWidget {
  @override
  EmpattdetailState createState() => EmpattdetailState();
}

class EmpattdetailState extends State<EmpAttdetail> {
  int? ComId;
  int? empId;
  DateTime? selectedMonth;
  int MonthNo = DateTime.now().month;
  int YearNo = DateTime.now().year;
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    EmpAttDetail();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        ComId = user['company_id'] ?? 0;
        empId = user['id'] ?? 0;
      });
    }
  }

  void EmpAttDetail() async {
    try {
      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/getSingleEmpAttendanceAll.php',
      );
      final Map<String, dynamic> requestBody = {
        "company_id": "${ComId ?? ''}",
        "emp_id": "${empId ?? ''}",
        "month": "${MonthNo ?? ''}",
        "year": "${YearNo ?? ''}",
      };

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

        List<Map<String, dynamic>> tempList = [];
        if (AttData != null && AttData is Map<String, dynamic>) {
          AttData.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              tempList.add({'date': key, ...value});
            }
          });
          setState(() {
            isLoading = false;
            attendanceData = tempList.reversed.toList();
          });
        } else {
          setState(() {
            isLoading = false;
          });
          Alert.alert(context, message);
        }
      } else {
        setState(() {
          isLoading = false;
          attendanceData = [];
        });

        Alert.alert(context, message);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Alert.alert(context, e);
    }
  }

  void _pickMonth() {
    showMonthPicker(context: context, initialDate: DateTime.now()).then((date) {
      if (date != null) {
        setState(() {
          selectedMonth = date;
          MonthNo = date.month;
          YearNo = date.year;
        });
        EmpAttDetail();
      }
    });
  }

  double safeParseDouble(String input) {
    try {
      return double.parse(input.replaceAll('"', '').replaceAll("'", '').trim());
    } catch (e) {
      Alert.alert(context, "Error parsing double: $e");
      return 0.0;
    }
  }

  Future<void> more(Map<String, dynamic> item, double ratio) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ratio * 4),
          ),
          title: Center(
            child: Text(
              'Attendance Details',
              style: TextStyle(
                fontSize: ratio * 8,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(ratio * 2.5),
              child: Column(
                children: [
                  _infoRow('Time In', item['time_in'], ratio),
                  _infoRow('Time Out', item['time_out'], ratio),
                  _infoRow('Address In', item['address'], ratio, maxLines: 2),
                  _infoRow(
                    'Address Out',
                    item['address_out'],
                    ratio,
                    maxLines: 2,
                  ),
                  _infoRow('Working Hours', item['hours'].toString(), ratio),
                  Divider(height: ratio * 4, color: Colors.grey.shade400),

                  // Breaks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _breakInfo('Break 1', item['break1hour'], ratio),
                      _breakInfo('Break 2', item['break2hour'], ratio),
                      _breakInfo('Break 3', item['break3hour'], ratio),
                    ],
                  ),

                  SizedBox(height: ratio * 2),
                  _infoRow('Total Break Time', item['breakhour'], ratio),

                  SizedBox(height: ratio * 3),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'View on Map',
                        style: TextStyle(
                          fontSize: ratio * 6,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          FontAwesomeIcons.mapLocationDot,
                          color: Color(0xFF03a9f4),
                          size: ratio * 10,
                        ),
                        onPressed: () {
                          _openMap(item);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03a9f4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ratio * 10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: ratio * 2,
                  vertical: ratio * 2,
                ),
              ),
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(
    String label,
    dynamic value,
    double ratio, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ratio * 1.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: ratio * 6,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value?.toString() ?? '',
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: ratio * 6, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakInfo(String title, dynamic value, double ratio) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: ratio * 6,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          (value == null || value == 0) ? '' : value.toString(),
          style: TextStyle(fontSize: ratio * 6),
        ),
      ],
    );
  }

  void _openMap(Map<String, dynamic> item) {
    List<LatLng> points = [];

    final point1 = item['multipoint'];
    final point2 = item['multipoint_out'];

    try {
      if (point1 != null && point1.isNotEmpty) {
        final p1Parts = point1.split('_');
        if (p1Parts.length == 2) {
          points.add(
            LatLng(
              safeParseDouble(p1Parts[0].trim()),
              safeParseDouble(p1Parts[1].trim()),
            ),
          );
        }
      }

      if (points.isNotEmpty && point2 != null && point2.isNotEmpty) {
        final p2Parts = point2.split('_');
        if (p2Parts.length == 2) {
          points.add(
            LatLng(
              safeParseDouble(p2Parts[0].trim()),
              safeParseDouble(p2Parts[1].trim()),
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
        Alert.alert(context, "Attendance Not Marked");
      }
    } catch (e) {
      Alert.alert(context, "Error parsing coordinates.");
    }
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
          'Attendance Detail',
          style: TextStyle(
            fontSize: ratio * 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
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
                  "Attendance Not Found",
                  style: TextStyle(fontSize: ratio * 6),
                ),
              )
              : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final data = attendanceData[index];
                  return Padding(
                    padding: EdgeInsets.all(ratio * .5),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: ratio * 2,
                        left: ratio * 5,
                        right: ratio * 5,
                      ),
                      padding: EdgeInsets.all(ratio * 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(deviceWidth * 0.03),
                        color: const Color.fromARGB(255, 247, 239, 230),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "S.r.No.",
                                          style: TextStyle(
                                            fontSize: ratio * 6,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            vertical: ratio * 1,
                                            horizontal: ratio * 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Color(0xFF03a9f4),
                                            borderRadius: BorderRadius.circular(
                                              ratio * 5,
                                            ),
                                          ),
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                              fontSize: ratio * 5,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Date",
                                      style: TextStyle(
                                        fontSize: ratio * 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      data['date'] != null
                                          ? data['date']
                                              .split('-')
                                              .reversed
                                              .join('-')
                                          : '',
                                      style: TextStyle(fontSize: ratio * 6),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "Break Time",
                                          style: TextStyle(
                                            fontSize: ratio * 6,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          data['breakhour'] ?? '',
                                          style: TextStyle(
                                            fontSize: ratio * 6,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: ratio * 1),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    Text(
                                      "Punch In",
                                      style: TextStyle(
                                        fontSize: ratio * 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      data['time_in'] ?? '',
                                      style: TextStyle(fontSize: ratio * 6),
                                    ),
                                    Text(
                                      "Punch Out:",
                                      style: TextStyle(
                                        fontSize: ratio * 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      data['time_out'] ?? '',
                                      style: TextStyle(fontSize: ratio * 6),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: ratio * 1),
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Column(
                                          children: [
                                            SizedBox(height: ratio * 4),
                                            Container(
                                              width: ratio * 13,
                                              height: ratio * 13,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color:
                                                    (data['attendance_status'] ==
                                                                'P' ||
                                                            data['attendance_status'] ==
                                                                'p')
                                                        ? Color(0xFF03a9f4)
                                                        : Colors.redAccent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      deviceWidth * 0.044,
                                                    ),
                                              ),
                                              child: Text(
                                                "${data['attendance_status'] ?? ''}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ratio * 6,
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: ratio * 3),
                                            Text(
                                              "Status",
                                              style: TextStyle(
                                                fontSize: ratio * 5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(width: ratio * 5),
                                        Column(
                                          children: [
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints: BoxConstraints(
                                                minHeight: 0,
                                              ),
                                              onPressed:
                                                  () =>
                                                      (data['attendance_status'] ==
                                                                  'p' ||
                                                              data['attendance_status'] ==
                                                                  'P')
                                                          ? more(data, ratio)
                                                          : Alert.alert(
                                                            context,
                                                            "Attendance Not Marked",
                                                          ),
                                              icon: Icon(
                                                FontAwesomeIcons.circleInfo,
                                                size: ratio * 12,
                                              ),
                                            ),
                                            Text(
                                              "More Info.",
                                              style: TextStyle(
                                                fontSize: ratio * 5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: deviceHeight * 0.005),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Total Hours:",
                                          style: TextStyle(
                                            fontSize: ratio * 5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${data['hours'] ?? 0}",
                                          style: TextStyle(fontSize: ratio * 5),
                                        ),
                                      ],
                                    ),
                                  ],
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
