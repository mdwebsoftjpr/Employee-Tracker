import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Employee%20Reports/AttendanceDetail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

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
  String day = '';

  @override
  void initState() {
    super.initState(); // Keep only this one
    final DateTime now = DateTime.now();
    day = DateFormat('yyyy-MM-dd').format(now);
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
    final Map<String, dynamic> requestBody = {"company_id": comId,"currentDate":day};
    print(day);
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
                  CircleAvatar(
                    radius: ratio * 25,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: NetworkImage(item['image'] ?? ''),
                    onBackgroundImageError: (_, __) {},
                  ),
                  SizedBox(height: ratio * 3),

                  // Name
                  _infoRow('Name', item['empname'], ratio),
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

  double safeParseDouble(String input) {
    try {
      return double.parse(input.replaceAll('"', '').replaceAll("'", '').trim());
    } catch (e) {
      Alert.alert(context, "Error parsing double: $e");
      return 0.0;
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
        day = DateFormat(
          'yyyy-MM-dd',
        ).format(pickedDate); 
        print(day);
        isLoading = true;
      });

      // Fetch attendance for the selected date
      ShowMaster();
    }
  }

  Widget _buildSummaryTile(String label, String count, Color color,double ratio) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: ratio*8,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: ratio*3),
        Text(label, style: TextStyle(fontSize: ratio*7, color: Colors.grey[800])),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalPresent =
        attendanceData
            .where((item) => item['attendance_status']?.toLowerCase() == 'p')
            .length;

    int totalAbsent =
        attendanceData
            .where((item) => item['attendance_status']?.toLowerCase() == 'a')
            .length;
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.date_range,
              color: Colors.white,
              size: deviceWidth * 0.09,
            ),
            onPressed: _pickDate,
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
                  'Attendance Not found',
                  style: TextStyle(fontSize: ratio * 8),
                ),
              )
              : Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                            vertical: ratio*3,
                            horizontal: ratio*5,
                          ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: ratio*5,
                            horizontal: ratio*2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryTile(
                                "Total Present",
                                "$totalPresent",
                                Colors.green,
                                ratio
                              ),
                              _buildSummaryTile(
                                "Total Absent",
                                "$totalAbsent",
                                Colors.red,ratio
                              ),
                              _buildSummaryTile(
                                "Employees",
                                "${attendanceData.length}",
                                Colors.blue,ratio
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: attendanceData.length,
                        itemBuilder: (context, index) {
                          final item = attendanceData[index];
                          final imageUrl =
                              (item['image'] != null &&
                                      item['image']
                                          .toString()
                                          .trim()
                                          .isNotEmpty)
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
                                vertical: ratio * 2,
                                horizontal: ratio * 6,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(ratio * 3),
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
                                    Container(
                                      child: Row(
                                        children: [
                                          SizedBox(width: ratio * 10),
                                          Container(
                                            clipBehavior: Clip.antiAlias,
                                            width: ratio * 27,
                                            height: ratio * 27,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    ratio * 13,
                                                  ),
                                            ),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.fill,
                                            ),
                                          ),
                                          SizedBox(width: ratio * 5),
                                          Container(
                                            width: deviceWidth * .62,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      (item['empname'] ?? ''),
                                                      style: TextStyle(
                                                        fontSize: ratio * 5,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      ('Full Time'),
                                                      style: TextStyle(
                                                        fontSize: ratio * 5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                ratio * 4.5,
                                                              ),
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    ratio * 4.5,
                                                                vertical:
                                                                    ratio * 2,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                (item['attendance_status']
                                                                            ?.toLowerCase() ==
                                                                        'p')
                                                                    ? Color(
                                                                      0xFF03a9f4,
                                                                    )
                                                                    : Colors
                                                                        .red,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            item['attendance_status'] ??
                                                                '',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Status',
                                                          style: TextStyle(
                                                            fontSize: ratio * 5,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        IconButton(
                                                          onPressed:
                                                              () =>
                                                                  (item['attendance_status'] ==
                                                                              'p' ||
                                                                          item['attendance_status'] ==
                                                                              'P')
                                                                      ? more(
                                                                        item,
                                                                        ratio,
                                                                      )
                                                                      : Alert.alert(
                                                                        context,
                                                                        "Attendance Not Marked",
                                                                      ),
                                                          icon: Icon(
                                                            FontAwesomeIcons
                                                                .circleInfo,
                                                            size: ratio * 11,
                                                          ),
                                                        ),
                                                        Text(
                                                          "More info",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize:
                                                                ratio * 4.5,
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
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: ratio * 1.5,
                                      ),
                                      width: deviceWidth * .9,
                                      height: 1,
                                      color: const Color.fromARGB(
                                        255,
                                        211,
                                        203,
                                        203,
                                      ),
                                    ),
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              Text(
                                                "S.r.No.",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical: ratio * 1,
                                                  horizontal: ratio * 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF03a9f4),
                                                  borderRadius:
                                                      BorderRadius.circular(
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
                                          Column(
                                            children: [
                                              Text(
                                                "Time in",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                              Text(
                                                "${item['time_in'] ?? ''}",
                                                style: TextStyle(
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "Time Out",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                              Text(
                                                "${item['time_out'] ?? ''}",
                                                style: TextStyle(
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "Total Hours",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                              Text(
                                                "${item['hours'] ?? ''}",
                                                style: TextStyle(
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Text(
                                                "Break Time",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: ratio * 5,
                                                ),
                                              ),
                                              Text(
                                                "${item['breakhour'] ?? ''}",
                                                style: TextStyle(
                                                  fontSize: ratio * 5,
                                                ),
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
                    ),
                  ],
                ),
              ),
    );
  }
}
