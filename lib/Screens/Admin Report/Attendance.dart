import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Employee%20Reports/AttendanceDetail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: Attendance(), debugShowCheckedModeBanner: false));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class Attendance extends StatefulWidget {
  @override
  AttendanceState createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  String name = "key_person";
  String comName = 'Company';
  int? comId;
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser().then((_) => ShowMaster());
  }

  Future<void> _loadUser() async {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      if (mounted) {
        setState(() {
          comName = user['company_name'] ?? 'Default Company';
          name = user['name'] ?? 'Default User';
          comId = user['id'];
        });
      }
    }
  }

  void ShowMaster() async {
    if (comId == null) return;

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
      if (responseData['success'] && responseData['data'] != null) {
        if (mounted) {
          setState(() {
            attendanceData = List<Map<String, dynamic>>.from(
              responseData['data'],
            );
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
        Alert.alert(context, responseData['message'] ?? 'Failed to load data');
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      Alert.alert(context, 'Error: ${e.toString()}');
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
        backgroundColor: Color(0xFF03a9f4),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Daily Attendance Detail',
          style: TextStyle(
            fontSize: ratio * 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
                  'Attendance Not found',
                  style: TextStyle(fontSize: ratio * 8),
                ),
              )
              : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final item = attendanceData[index];
                  final imageUrl =
                      (item['image'] != null &&
                              item['image'].toString().trim().isNotEmpty)
                          ? '${item['image']}'
                          : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

                  return GestureDetector(
                    onTap: () {
                      // When the tile is tapped, navigate to the details page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDetail(item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ratio * 1,
                        horizontal: ratio * 3,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            deviceWidth * 0.03,
                          ),
                          color: const Color.fromARGB(255, 247, 239, 230),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      ratio * 6,
                                    ),
                                    color: Colors.blue,
                                  ),
                                  width: ratio * 10,
                                  height: ratio * 10,
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: ratio * 7,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        width: ratio * 25,
                                        height: ratio * 25,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Image.network(
                                            imageUrl,
                                            width: ratio * 25,
                                            height: ratio * 25,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    Text(
                                      (item['empname'] ?? '').length > 7
                                          ? '${item['empname'].substring(0, 7)}...'
                                          : item['empname'] ?? '',
                                      style: TextStyle(fontSize: ratio * 6.5),
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Punch in:-",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: ratio * 6,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${item['time_in'] ?? ''}",
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 12),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Punch Out:-",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: ratio * 6,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${item['time_out'] ?? ''}",
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    "Break Time:",
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(item['breakhour']??'',
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,

                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: ratio * 4.5,
                                                  vertical: ratio * 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      (item['attendance_status']
                                                                  ?.toLowerCase() ==
                                                              'p')
                                                          ? Color(0xFF03a9f4)
                                                          : Colors.red,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  item['attendance_status'] ??
                                                      '',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Total Hours: ",
                                                    style: TextStyle(
                                                      fontSize: ratio * 6,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    (item['hours']).toString(),
                                                    style: TextStyle(
                                                      fontSize: ratio * 5,
                                                    ),
                                                  ),
                                                ],
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Address in: ",
                                              style: TextStyle(
                                                fontSize: ratio * 6,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: item['address'],
                                              style: TextStyle(
                                                fontSize: ratio * 6,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                      SizedBox(height: 5),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Address Out: ",
                                              style: TextStyle(
                                                fontSize: ratio * 6,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text: item['address_out'],
                                              style: TextStyle(
                                                fontSize: ratio * 6,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        softWrap: true,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ],
                                  ),
                                ),

                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,

                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          FontAwesomeIcons.mapLocationDot,
                                          color: Color(0xFF03a9f4),
                                          size: ratio * 10,
                                        ),
                                        onPressed: () {
                                          List<LatLng> points = [];

                                          final point1 = item['multipoint'];
                                          final point2 = item['multipoint_out'];

                                          try {
                                            // Add point1 if available and valid
                                            if (point1 != null &&
                                                point1.isNotEmpty) {
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
                                                      (context) =>
                                                          SimpleMapScreen(
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
                            Container(
                        width: deviceWidth*.9,
                        height: ratio*20,
                        decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(ratio*5)),
                        child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Break 1",
                                        style: TextStyle(
                                          fontSize: ratio * 6,
                                          color: Colors.black,fontWeight:FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                        (item['break1hour'].toString() == '0' ||
                                                item['break1hour'].toString() ==
                                                    '')
                                            ? ''
                                            : item['break1hour'].toString(),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Break 2",
                                        style: TextStyle(
                                          fontSize: ratio * 6,
                                          color: Colors.black,fontWeight:FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                        (item['break2hour'].toString() == '0' ||
                                                item['break2hour'].toString() ==
                                                    '')
                                            ? ''
                                            : item['break2hour'].toString(),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Break 3",
                                        style: TextStyle(
                                          fontSize: ratio * 6,
                                          color: Colors.black,fontWeight:FontWeight.bold
                                        ),
                                      ),
                                      Text(
                                        (item['break3hour'].toString() == '0' ||
                                                item['break3hour'].toString() ==
                                                    '')
                                            ? ''
                                            : item['break3hour'].toString(),
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
