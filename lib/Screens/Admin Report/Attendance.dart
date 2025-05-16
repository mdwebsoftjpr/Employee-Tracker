import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Detail%20Screen/AttendanceDetail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: Attendance(), debugShowCheckedModeBanner: false));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Attendance extends StatefulWidget {
  @override
  AttendanceState createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  String name = "key_person";
  String comName = 'Company';
  int? comId;
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
    ShowMaster();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        name = user['name'] ?? 'Default User';
        comId = user['id'];
      });
    }
  }

  void ShowMaster() async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/allemployeeattendence.php',
    );
    final Map<String, dynamic> requestBody = {"company_id": comId};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(
            responseData['data'],
          );
        });
      } else {
        Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      Alert.alert(context, 'Something went wrong: ${e.toString()}');
    }
  }

  Future<void> alert(BuildContext context, message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Employee Tracker')],
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  overflow:
                      TextOverflow.visible, // Or ellipsis if you want cut-off
                  softWrap: true,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              child: Text('OK', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03a9f4),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss alert
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Daily Attendance Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: deviceWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          attendanceData.isEmpty
              ? Center(
                child: Text(
                  "Attendance not found",
                  style: TextStyle(fontSize: deviceWidth * 0.075),
                ),
              )
              : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final item = attendanceData[index];
                  final imageUrl =
                      (item['image'] != null &&
                              item['image'].toString().trim().isNotEmpty)
                          ? item['image']
                          : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDetail(item),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(
                        horizontal: deviceWidth * 0.05,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: deviceWidth * 0.04,
                              backgroundColor: Colors.white,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 5 * devicePixelRatio,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(width: deviceWidth * 0.02),
                            Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.network(
                                        imageUrl,
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                                Text(
                                  item['empname']?.length > 9
                                      ? '${item['empname'].substring(0, 11)}...'
                                      : item['empname'] ?? '',
                                  style: TextStyle(
                                    fontSize: 4 * devicePixelRatio,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            SizedBox(width: deviceWidth * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    "Punch In:",
                                                    style: TextStyle(
                                                      fontSize:
                                                          3.5 *
                                                          devicePixelRatio,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  Text(
                                                    item['time_in'] ?? '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          4 * devicePixelRatio,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 4),
                                              Container(
                                                width: 1,
                                                height: 30,
                                                color: const Color.fromARGB(
                                                  255,
                                                  78,
                                                  77,
                                                  77,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Column(
                                                children: [
                                                  Text(
                                                    "Punch Out:",
                                                    style: TextStyle(
                                                      fontSize:
                                                          3.5 *
                                                          devicePixelRatio,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  Text(
                                                    item['time_out'] ?? '',
                                                    style: TextStyle(
                                                      fontSize:
                                                          4 * devicePixelRatio,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          Row(
                                            children: [
                                              Text(
                                                "Break Time:- ",
                                                style: TextStyle(
                                                  fontSize:
                                                      3.5 * devicePixelRatio,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                '3',
                                                style: TextStyle(
                                                  fontSize:
                                                      3.5 * devicePixelRatio,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  (item['attendance_status'] ==
                                                              'P' ||
                                                          item['attendance_status'] ==
                                                              'p')
                                                      ? Color(0xFF03a9f4)
                                                      : Colors.red,
                                            ),
                                            padding: EdgeInsets.all(8),
                                            child: Text(
                                              item['attendance_status'] ?? '',
                                              style: TextStyle(
                                                fontSize:
                                                    4.5 * devicePixelRatio,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 6),
                                          Text(
                                            "Total Hours:",
                                            style: TextStyle(
                                              fontSize: 3 * devicePixelRatio,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            item['hours']?.toString() ?? '0',
                                            style: TextStyle(
                                              fontSize: 4.5 * devicePixelRatio,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
