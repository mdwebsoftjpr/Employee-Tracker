import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');

class AttendanceDetail extends StatefulWidget {
  final Map<String, dynamic> items;

  const AttendanceDetail(this.items, {Key? key}) : super(key: key);

  @override
  AttendanceDetailState createState() => AttendanceDetailState();
}

class AttendanceDetailState extends State<AttendanceDetail> {
  int? ComId;
  int? empId;
  DateTime? selectedMonth;
  int MonthNo = DateTime.now().month;
  int YearNo = DateTime.now().year;
  bool isLoading = true;

  final int currentExp = 85;
  final int totalExp = 100;
  List<Map<String, dynamic>> attendanceData = [];
  int totalPresentDays = 0; // To store the count of 'P' days
  double attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    empId = widget.items['id'];
    ComId = widget.items['company_id'];
    EmpAttDetail();
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
        print(AttData);

        List<Map<String, dynamic>> tempList = [];
        if (AttData != null && AttData is Map<String, dynamic>) {
          AttData.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              tempList.add({'date': key, ...value});
              // Count 'P' status days
              if (value['attendance_status'] == 'P' ||
                  value['attendance_status'] == 'p') {
                totalPresentDays++;
              }
            }
          });

          // Calculate attendance percentage
          attendancePercentage = (totalPresentDays / 31) * 100;

          setState(() {
            isLoading = false;
            attendanceData = tempList.reversed.toList();
          });
        } else {
          setState(() {
            isLoading = false;
            attendanceData = [];
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
    showMonthPicker(
      context: context,
      initialDate: selectedMonth ?? DateTime.now(),
    ).then((date) {
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

  @override
  Widget build(BuildContext context) {
    final item = widget.items;
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
    final imageUrl =
        (item['image'] != null && item['image'].toString().trim().isNotEmpty)
            ? item['image']
            : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Monthly Attendance Detail',
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
              : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(deviceWidth * 0.04),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  deviceWidth * 0.02,
                                ),
                                child: Image.network(
                                  imageUrl,
                                  width: deviceWidth * 0.22,
                                  height: deviceHeight * 0.15,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              SizedBox(height: deviceHeight * 0.01),
                              Text(
                                item['empname'] ?? 'Unknown',
                                style: TextStyle(fontSize: ratio * 6),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              CircularPercentIndicator(
                                radius: deviceWidth * 0.1,
                                lineWidth: deviceWidth * 0.03,
                                animation: true,
                                percent: attendancePercentage / 100,
                                center: Text(
                                  "${attendancePercentage.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ratio * 6,
                                    color: Colors.black,
                                  ),
                                ),
                                footer: Text(
                                  "Total: $totalPresentDays / 31",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ratio * 6,
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.blue,
                              ),
                              Text(
                                "This Month Attendance % ${attendancePercentage.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: ratio * 5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Details:-",
                    style: TextStyle(
                      fontSize: ratio * 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child:
                        isLoading
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius:
                                        MediaQuery.of(context).size.width *
                                        0.16, // Adjust the radius dynamically based on screen width
                                    backgroundImage: AssetImage(
                                      'assets/splesh_Screen/Emp_Attend.png',
                                    ), // Set the background image here
                                  ),

                                  SizedBox(height: 5),
                                  CircularProgressIndicator(
                                    color: Color(0xFF03a9f4),
                                  ),
                                ],
                              ),
                            )
                            : attendanceData.isEmpty
                            ? Center(
                              child: Text(
                                "Attendance Not Found",
                                style: TextStyle(fontSize: ratio * 9),
                              ),
                            )
                            : ListView.builder(
                              itemCount: attendanceData.length,
                              itemBuilder: (context, index) {
                                final data = attendanceData[index];
                                return Container(
                                  margin: EdgeInsets.only(
                                    top: ratio * 2,
                                    left: ratio * 3.5,
                                    right: ratio * 3.5,
                                  ),
                                  padding: EdgeInsets.only(
                                    top: ratio * 2,
                                    bottom: ratio * 1,
                                    left: ratio * 3,
                                    right: ratio * 3,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      deviceWidth * 0.03,
                                    ),
                                    color: const Color.fromARGB(
                                      255,
                                      247,
                                      239,
                                      230,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Date:",
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
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                  ),
                                                ),
                                                Text(
                                                  "Total Hours:",
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "${data['hours']}",
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: ratio * 5),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Punch In:",
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${data['time_in'] ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                  ),
                                                ),
                                                Text(
                                                  "Punch Out:",
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${data['time_out'] ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: ratio * 2),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        deviceHeight * 0.005,
                                                    horizontal:
                                                        deviceWidth * 0.025,
                                                  ),
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: ratio * 5,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: deviceHeight * 0.005,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Break Time:",
                                                      style: TextStyle(
                                                        fontSize: ratio * 6,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(width: ratio * 6),
                                                    Text(
                                                      data['breakhour']??'',
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
                                          SizedBox(width: ratio * 2),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    FontAwesomeIcons
                                                        .mapLocationDot,
                                                    color: Color(0xFF03a9f4),
                                                    size: ratio * 10,
                                                  ),
                                                  onPressed: () {
                                                    List<LatLng> points = [];

                                                    final point1 =
                                                        data['multipoint'];
                                                    final point2 =
                                                        data['multipoint_out'];

                                                    try {
                                                      // Add point1 if available and valid
                                                      if (point1 != null &&
                                                          point1.isNotEmpty) {
                                                        final p1Parts = point1
                                                            .split('_');
                                                        if (p1Parts.length ==
                                                            2) {
                                                          points.add(
                                                            LatLng(
                                                              safeParseDouble(
                                                                p1Parts[0]
                                                                    .trim(),
                                                              ),
                                                              safeParseDouble(
                                                                p1Parts[1]
                                                                    .trim(),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }

                                                      // Add point2 only if point1 was added and point2 is valid
                                                      if (points.isNotEmpty &&
                                                          point2 != null &&
                                                          point2.isNotEmpty) {
                                                        final p2Parts = point2
                                                            .split('_');
                                                        if (p2Parts.length ==
                                                            2) {
                                                          points.add(
                                                            LatLng(
                                                              safeParseDouble(
                                                                p2Parts[0]
                                                                    .trim(),
                                                              ),
                                                              safeParseDouble(
                                                                p2Parts[1]
                                                                    .trim(),
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }

                                                      if (points.isNotEmpty) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    SimpleMapScreen(
                                                                      points:
                                                                          points,
                                                                    ),
                                                          ),
                                                        );
                                                      } else {
                                                        Alert.alert(
                                                          context,
                                                          "Attemdance Not Marked",
                                                        );
                                                      }
                                                    } catch (e) {
                                                      Alert.alert(
                                                        context,
                                                        "Error parsing coordinates.",
                                                      );
                                                    }
                                                  },
                                                ),

                                                Text(
                                                  "Location..",
                                                  style: TextStyle(
                                                    fontSize: ratio * 6,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: ratio * 1),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Address In: ",
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            data['address'] ??
                                                            'No address available',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  overflow:
                                                      TextOverflow.visible,
                                                  softWrap: true,
                                                ),
                                                SizedBox(height: 6),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Address Out: ",
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            data['address_out'] ??
                                                            'No address available',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  overflow:
                                                      TextOverflow.visible,
                                                  softWrap: true,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: deviceWidth * .9,
                                        height: ratio * 20,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            ratio * 5,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Break 1",
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    (data['break1hour']
                                                                    .toString() ==
                                                                '0' ||
                                                            data['break1hour']
                                                                    .toString() ==
                                                                '')
                                                        ? ''
                                                        : data['break1hour']
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Break 2",
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    (data['break2hour']
                                                                    .toString() ==
                                                                '0' ||
                                                            data['break2hour']
                                                                    .toString() ==
                                                                '')
                                                        ? ''
                                                        : data['break2hour']
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Break 3",
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    (data['break3hour']
                                                                    .toString() ==
                                                                '0' ||
                                                            data['break3hour']
                                                                    .toString() ==
                                                                '')
                                                        ? ''
                                                        : data['break3hour']
                                                            .toString(),
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: ratio * 2),
                                    ],
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
