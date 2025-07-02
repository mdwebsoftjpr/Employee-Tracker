import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Employee%20Reports/AttendanceDetail.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';


final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(GetMaterialApp(home: Attendance(), debugShowCheckedModeBanner: false));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class Attendance extends StatefulWidget {
  @override
  AttendanceState createState() => AttendanceState();
}

enum AttendanceFilter { total, present, absent }

AttendanceFilter _currentFilter = AttendanceFilter.present;

class AttendanceState extends State<Attendance> {
  Future<void> _refreshData() async {
    await Future.delayed(Duration(seconds: 2)); // simulate delay
    ShowMaster();
  }

  String name = "key_person";
  String comName = 'Company';
  int? comId;
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = true;
  String day = '';
  String formatDate(String inputDate) {
    DateTime date = DateTime.parse(inputDate);
    String formatted =
        "${date.day.toString().padLeft(2, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.year}";
    return formatted;
  }

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
    final Map<String, dynamic> requestBody = {
      "company_id": comId,
      "currentDate": day,
    };
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
        Alert.alert(context, responseData['message']);
        setState(() {
          attendanceData = [];
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      Alert.alert(context, 'Error: ${e.toString()}');
    }
  }








  List<Map<String, dynamic>> getFilteredAttendance() {
    switch (_currentFilter) {
      case AttendanceFilter.present:
        return attendanceData
            .where((item) => item['attendance_status']?.toLowerCase() == 'p')
            .toList();
      case AttendanceFilter.absent:
        return attendanceData
            .where((item) => item['attendance_status']?.toLowerCase() == 'a')
            .toList();
      case AttendanceFilter.total:
      default:
        return attendanceData;
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
                  _infoRow('Punch In', item['time_in'], ratio),
                  _infoRow('Punch Out', item['time_out'], ratio),
                  _infoRow('Total Hours', item['hours'].toString(), ratio),
                  _infoRow('Total Break Time', item['breakhour'], ratio),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _breakInfo('Break 1', item['break1hour'], ratio),
                      _breakInfo('Break 2', item['break2hour'], ratio),
                      _breakInfo('Break 3', item['break3hour'], ratio),
                    ],
                  ),
                  _infoRow(
                    'Working Hours',
                    "${item['working hours'] ?? ''}".toString(),
                    ratio,
                  ),
                  Divider(height: ratio * 4, color: Colors.grey.shade400),
                  _infoRow('Address In', item['address'], ratio, maxLines: 2),
                  _infoRow(
                    'Address Out',
                    item['address_out'],
                    ratio,
                    maxLines: 2,
                  ),

                  SizedBox(height: ratio * 2),

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
            flex: 5,
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
            flex: 5,
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
        day = DateFormat('yyyy-MM-dd').format(pickedDate);
        isLoading = true;
      });
      ShowMaster();
    }
  }

  Widget _buildSummaryTile(
    Widget label,
    String count,
    Color color,
    double ratio,
    VoidCallback onTap,
    Color bgc,
    bool selected,
  ) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: ratio * 3,
          horizontal: ratio * 1,
        ),
        backgroundColor: selected ? bgc : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ratio * 2,
          ), // Minimal corner rounding
          side: BorderSide(
            color: selected ? Colors.blue : Colors.transparent,
          ), // Optional border
        ),
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: ratio * 8,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: ratio * 3),
          label,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredData = getFilteredAttendance();

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
          'Employee Attendance',
          style: TextStyle(
            fontSize: ratio * 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          
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
              : Container(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: ratio * 3,
                        horizontal: ratio * 5,
                      ),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: ratio * 5,
                            horizontal: ratio * 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildSummaryTile(
                                Text(
                                  "Present",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ratio * 6,
                                  ),
                                ),
                                "$totalPresent",
                                Colors.green,
                                ratio,
                                () {
                                  setState(() {
                                    _currentFilter = AttendanceFilter.present;
                                  });
                                },
                                Colors.white,
                                _currentFilter == AttendanceFilter.present,
                              ),
                              _buildSummaryTile(
                                Text(
                                  "Absent",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ratio * 6,
                                  ),
                                ),
                                "$totalAbsent",
                                Colors.red,
                                ratio,
                                () {
                                  setState(() {
                                    _currentFilter = AttendanceFilter.absent;
                                  });
                                },
                                Colors.white,
                                _currentFilter ==
                                    AttendanceFilter
                                        .absent, // ✅ Correct: compares value
                              ),
                              _buildSummaryTile(
                                Text(
                                  "Employee",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: ratio * 6,
                                  ),
                                ),
                                "${attendanceData.length}",
                                Colors.blue,
                                ratio,
                                () {
                                  setState(() {
                                    _currentFilter = AttendanceFilter.total;
                                  });
                                },
                                Colors.white,
                                _currentFilter ==
                                    AttendanceFilter
                                        .total, // ✅ Correct: compares value
                              ),
                              _buildSummaryTile(
                                Icon(
                                  Icons.date_range,
                                  color: Colors.black,
                                  size: ratio * 9,
                                ), // ✅ Corrected
                                formatDate(day), // e.g., "03-06-2025"
                                Colors.blue,
                                ratio,
                                _pickDate,
                                Colors.white,
                                false, // assuming this indicates selection or active state
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    attendanceData.isEmpty
                        ? Container(
                          height: deviceHeight * .7,
                          alignment: Alignment.center,
                          child: Text(
                            "No attendance record found",
                            style: TextStyle(fontSize: ratio * 8),
                          ),
                        )
                        : Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshData,
                            child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: filteredData.length,
                              itemBuilder: (context, index) {
                                final item = filteredData[index];
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
                                        builder:
                                            (context) => AttendanceDetail(item),
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
                                                SizedBox(width: ratio * 1),
                                                Container(
                                                  margin: EdgeInsets.all(
                                                    ratio * 2,
                                                  ),
                                                  width: ratio * 12,
                                                  height: ratio * 12,

                                                  decoration: BoxDecoration(
                                                    color: Color(0xFF03a9f4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          ratio * 6,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '${(index + 1).toString().padLeft(2, '0')}',
                                                      style: TextStyle(
                                                        fontSize: ratio * 5,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  clipBehavior: Clip.antiAlias,
                                                  width: ratio * 27,
                                                  height: ratio * 27,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          ratio * 5,
                                                        ),
                                                  ),
                                                  child: Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                SizedBox(width: ratio * 4),
                                                Container(
                                                  width: deviceWidth * .58,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            (item['empname'] ??
                                                                ''),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  ratio * 6,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      "Punch in",
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
                                                Column(
                                                  children: [
                                                    Text(
                                                      "Punch Out",
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
                                                Container(
                                                  margin: EdgeInsets.all(
                                                    ratio * 4.5,
                                                  ),
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
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item['attendance_status'] ??
                                                        '',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
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
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                      "Total Hours",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ratio * 6,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${item['hours'] ?? ''}",
                                                      style: TextStyle(
                                                        fontSize: ratio * 6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Break Time",
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: ratio * 6,
                                                          ),
                                                        ),
                                                        if ((item['break1'] ??
                                                                    '') ==
                                                                'open' ||
                                                            (item['break2'] ??
                                                                    '') ==
                                                                'open' ||
                                                            (item['break3'] ??
                                                                    '') ==
                                                                'open') ...[
                                                          SizedBox(
                                                            width: ratio * 2,
                                                          ), // spacing between text and dot
                                                          Center(
                                                            child: Lottie.asset(
                                                              'assets/RedDot.json',
                                                              width: ratio * 5,
                                                              height: ratio * 5,
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),

                                                    SizedBox(
                                                      height: ratio * 1.5,
                                                    ), // spacing

                                                    Text(
                                                      "${item['breakhour'] ?? ''}",
                                                      style: TextStyle(
                                                        fontSize: ratio * 6,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      "Working Hours",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: ratio * 6,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${item['working hours'] ?? ''}",
                                                      style: TextStyle(
                                                        fontSize: ratio * 6,
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
                        ),
                  ],
                ),
              ),
    );
  }
}
