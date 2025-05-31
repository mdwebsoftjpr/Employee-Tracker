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
      print("Sahil$user");
      setState(() {
        ComId = user['company_id'] ?? 0;
        empId = user['id'] ?? 0;
      });
    }
  }

  void EmpAttDetail() async {
    print("$empId,$ComId,$MonthNo,$YearNo");
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

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if(deviceWidth<deviceHeight){
      ratio=deviceHeight/deviceWidth;
    }else{
      ratio=deviceWidth/deviceHeight;
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Attendance Detail',
          style: TextStyle(
            fontSize: ratio*9,
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
                      radius:ratio*25,
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
                        left: ratio * 3.5,
                        right: ratio * 3.5,
                      ),
                      padding: EdgeInsets.all(ratio * 1),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(deviceWidth * 0.03),
                        color: const Color.fromARGB(255, 247, 239, 230),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontSize:ratio * 6,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Break: ",
                                      style: TextStyle(
                                        fontSize: ratio * 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      (() {
                                        int count = 0;
                                        if (data['break1'] == 'close') count++;
                                        if (data['break2'] == 'close') count++;
                                        if (data['break3'] == 'close') count++;
                                        return '$count';
                                      })(),style: TextStyle(
                                        fontSize: ratio * 6,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: ratio*7,),
                                Text(
                                  "Address in:",
                                  style: TextStyle(
                                    fontSize: ratio * 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${data['address'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: ratio * 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: ratio*1,),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Text(
                                  "Punch In:",
                                  style: TextStyle(
                                    fontSize: ratio * 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data['time_in'] ?? '',
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
                                  data['time_out'] ?? '',
                                  style: TextStyle(
                                    fontSize: ratio * 6,
                                  ),
                                ),
                                Text(
                                  "Address Out:",
                                  style: TextStyle(
                                    fontSize: ratio * 6,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  data['address_out'] ?? '',
                                  style: TextStyle(
                                    fontSize: ratio * 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: ratio*1,),
                          Expanded(
                            child: Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: deviceHeight * 0.006,
                                    horizontal: deviceWidth * 0.025,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        (data['attendance_status'] == 'P' ||
                                                data['attendance_status'] ==
                                                    'p')
                                            ? Color(0xFF03a9f4)
                                            : Colors.redAccent,
                                    borderRadius: BorderRadius.circular(
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
                                SizedBox(height: deviceHeight * 0.005),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Total Hours:",
                                      style: TextStyle(
                                        fontSize: ratio * 6,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${data['hours']??0}",
                                      style: TextStyle(
                                        fontSize: ratio * 6,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: ratio *1),
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.mapLocationDot,
                                    color: Color(0xFF03a9f4),
                                    size: ratio * 10,
                                  ),
                                  onPressed: () {
                                    List<LatLng> points = [];

                                    final point1 = data['multipoint'];
                                    final point2 = data['multipoint_out'];

                                    try {
                                      // Add point1 if available and valid
                                      if (point1 != null && point1.isNotEmpty) {
                                        final p1Parts = point1.split('_');
                                        if (p1Parts.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(
                                                p1Parts[0].trim(),
                                              ),
                                              safeParseDouble(
                                                p1Parts[1].trim(),
                                              ),
                                            ),
                                          );
                                        }
                                      }

                                      // Add point2 only if point1 was added and point2 is valid
                                      if (points.isNotEmpty &&
                                          point2 != null &&
                                          point2.isNotEmpty) {
                                        final p2Parts = point2.split('_');
                                        if (p2Parts.length == 2) {
                                          points.add(
                                            LatLng(
                                              safeParseDouble(
                                                p2Parts[0].trim(),
                                              ),
                                              safeParseDouble(
                                                p2Parts[1].trim(),
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
                                                (context) => SimpleMapScreen(
                                                  points: points,
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
                    ),
                  );
                },
              ),
    );
  }
}
