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

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
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
            fontSize: 6*devicePixelRatio,
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
                child: CircularProgressIndicator(color: Color(0xFF03a9f4)),
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
                                style: TextStyle(fontSize: devicePixelRatio * 6),
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
                                    fontSize: devicePixelRatio * 5,
                                    color: Colors.black,
                                  ),
                                ),
                                footer: Text(
                                  "Total: $totalPresentDays / 31",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: devicePixelRatio * 6,
                                  ),
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: Colors.blue,
                              ),
                              Text(
                                "This Month Attendance % ${attendancePercentage.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: devicePixelRatio *3.5),
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
                      fontSize: devicePixelRatio * 6,
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
                                style: TextStyle(fontSize: deviceWidth * 0.05),
                              ),
                            )
                            : ListView.builder(
                              itemCount: attendanceData.length,
                              itemBuilder: (context, index) {
                                final data = attendanceData[index];
                                return Container(
                                  margin: EdgeInsets.only(
                                    top: devicePixelRatio * 2,
                                    left: devicePixelRatio * 3.5,
                                    right: devicePixelRatio * 3.5,
                                  ),
                                  padding: EdgeInsets.only(
                                    top: devicePixelRatio * 2,
                                    bottom: devicePixelRatio * 1,
                                    left: devicePixelRatio * 3,
                                    right: devicePixelRatio * 3,
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
                                                    fontSize:
                                                        devicePixelRatio *4,
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
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                  ),
                                                ),
                                                Text(
                                                  "Break Time:",
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${data['break_time'] ?? ''}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Punch In:",
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${data['time_in'] ?? ''}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                  ),
                                                ),
                                                Text(
                                                  "Punch Out:",
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '${data['time_out'] ?? ''}',
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
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
                                                      fontSize:
                                                         devicePixelRatio *5,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: deviceHeight * 0.005,
                                                ),
                                                Text(
                                                  "Total Hours:",
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  "${data['hours']}",
                                                  style: TextStyle(
                                                    fontSize:
                                                        devicePixelRatio *4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: IconButton(
                                              icon: Icon(
                                                FontAwesomeIcons.mapLocationDot,
                                                color: Color(0xFF03a9f4),
                                                size: devicePixelRatio * 10,
                                              ),
                                              onPressed: () {
                                                List<LatLng> points = [];

                                                if (data['multipoint'] !=
                                                        null &&
                                                    data['multipoint'] != '') {
                                                  final startCoord =
                                                      data['multipoint']
                                                          .split('_')
                                                          .map((e) => e.trim())
                                                          .toList();

                                                  if (startCoord.length >= 2) {
                                                    points.add(
                                                      LatLng(
                                                        safeParseDouble(
                                                          startCoord[0],
                                                        ),
                                                        safeParseDouble(
                                                          startCoord[1],
                                                        ),
                                                      ),
                                                    );
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
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            // or use Flexible if needed
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: "Address: ",
                                                        style: TextStyle(
                                                          fontSize:
                                                              deviceWidth *
                                                              0.035,
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
                                                          fontSize:
                                                              deviceWidth *
                                                              0.035,
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
