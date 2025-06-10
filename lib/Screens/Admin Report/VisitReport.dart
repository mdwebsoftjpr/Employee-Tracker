import 'package:employee_tracker/Screens/Admin Report/VisitRepMap.dart';
import 'package:employee_tracker/Screens/Admin%20Report/MainVisit.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:localstorage/localstorage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import 'package:employee_tracker/Screens/image FullScreen/fullScreenImage.dart';
import 'package:employee_tracker/Screens/Components/Alert.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: AdminVisitreport()));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class AdminVisitreport extends StatefulWidget {
  const AdminVisitreport({Key? key}) : super(key: key);

  @override
  AdminVisitreportState createState() => AdminVisitreportState();
}

class AdminVisitreportState extends State<AdminVisitreport> {
  int? ComId;
  String day = '';
  String month = '';
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = true;

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
        ComId = user['id'] ?? 0;
      });
    }
  }

  void VisitDetail() async {
    try {
      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/getEmployeeActivity.php',
      );
      final Map<String, dynamic> requestBody = {
        "company_id": ComId,
        "month": month,
        "date": day,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        setState(() {
          isLoading = false;
          attendanceData = List<Map<String, dynamic>>.from(
            responseData['data'],
          );
        });
      } else {
        setState(() {
          isLoading = false;
          attendanceData.clear(); // clears the list in place
        });
        Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
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

  /*  Future<void> _pickMonth(BuildContext context) async {
    DateTime? selected = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),

      builder: (BuildContext context, Widget? child) {
  return Theme(
    data: Theme.of(context).copyWith(
      dialogTheme: DialogTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    child: SingleChildScrollView( // 👈 add scroll
      child: child!,
    ),
  );
}, 
    );

    if (selected != null) {
      setState(() {
        month = DateFormat('MM').format(selected);
        day = '';
      });
      VisitDetail();
    }
  }
*/
  double safeParseDouble(String input) {
    try {
      return double.parse(input.replaceAll('"', '').replaceAll("'", '').trim());
    } catch (e) {
      return 0.0;
    }
  }

  Future<void> showDetail(BuildContext context, List<dynamic> visitList) async {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    // Calculate ratio
    double ratio =
        deviceWidth < deviceHeight
            ? deviceHeight / deviceWidth
            : deviceWidth / deviceHeight;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * ratio),
          ),
          title: Center(
            child: Text(
              "Visit Details",
              style: TextStyle(
                fontSize: ratio * 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: ratio * 200, // Adjust max height if needed
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    visitList.map((visit) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: ratio * 2,
                          horizontal: ratio * 1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (visit['imagev'] != null)
                              Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    8 * ratio,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pop();
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
                                      width: ratio * 40,
                                      height: ratio * 40,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                      ),
                                      child: Image.network(
                                        visit['imagev'],
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                                  Icons.broken_image,
                                                  size: 40 * ratio,
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(height: 5 * ratio),

                            /// Custom text fields
                            buildTextDetail(
                              "Organization",
                              visit['NameOfCustomer'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Concerned Person",
                              visit['concernedperson'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Mobile No.",
                              visit['phoneno'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Date",
                              visit['date'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Start Time",
                              visit['time'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "End Time",
                              visit['end'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Transport",
                              visit['transport'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Probability",
                              visit['probablity'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Prospects",
                              visit['prospects'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Address",
                              visit['address'],
                              context,
                              ratio,
                            ),
                            buildTextDetail(
                              "Location Address",
                              visit['address2'],
                              context,
                              ratio,
                            ),

                            Divider(thickness: 1 * ratio, color: Colors.grey),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 5 * ratio,
                    horizontal: 8 * ratio,
                  ),
                  textStyle: TextStyle(fontSize: 8 * ratio),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildTextDetail(
    String label,
    String value,
    BuildContext context,
    double ratio,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2 * ratio, horizontal: ratio * 1),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 7 * ratio),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  String formatDateSimple(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return 'N/A';

  try {
    DateTime parsedDate = DateTime.parse(dateStr);
    String day = parsedDate.day.toString().padLeft(2, '0');
    String month = parsedDate.month.toString().padLeft(2, '0');
    String year = parsedDate.year.toString();
    return "$day $month $year";
  } catch (e) {
    return dateStr; // fallback to original if parsing fails
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
          'Visit Report',
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
                      formatDateSimple(day),
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
                 /*SizedBox(width: deviceWidth * 0.01),
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
                      onPressed: () => _pickMonth(context),
                      tooltip: "Pick Month",
                    ), 
                  ],
                ),*/
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
                  'Visit Not Found',
                  style: TextStyle(
                    fontSize: ratio * 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
              : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final data = attendanceData[index];

                  List<String> startLoc = [];
                  List<String> endLoc = [];
                  List<dynamic> EmpVisitDetail = [];
                  List<dynamic> visits = data['data'] ?? [];

                  if (visits.isNotEmpty) {
                    for (var visit in visits) {
                      startLoc.add(visit['start_Location']);
                      endLoc.add(visit['end_Location']);
                      EmpVisitDetail.add(visit);
                    }
                  }
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(ratio * 1),
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: ratio * 1,
                          horizontal: ratio * 2,
                        ),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            deviceWidth * 0.03,
                          ),
                          color: const Color.fromARGB(255, 247, 239, 230),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Image and Name
                            Expanded(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      data['image'] ?? '',
                                      width: ratio * 32,
                                      height: ratio * 32,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Icon(Icons.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: ratio * 3),
                            Expanded(
                              child: Column(
                                children: [
                                  
                                  Text(
                                    data['name'] ?? '',
                                    style: TextStyle(fontSize: ratio * 7),
                                  ),
                                  Row(
                                    children: [
                                      
                                  Text(
                                    "Total Visit:- ",
                                    style: TextStyle(fontSize: ratio * 6),
                                  ),
                                      Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ratio * 4.5,
                                      vertical: ratio * 1.8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF03a9f4),
                                      borderRadius: BorderRadius.circular(
                                        ratio * 6,
                                      ),
                                    ),
                                    child: Text(
                                      "${data['total_visit'] ?? 0}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: ratio * 3),
                            // Buttons
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    if (visits.isNotEmpty) {
                                       Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Mainvisit(data),
                                            ),
                                          ); 
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: deviceWidth * 0.06,
                                      vertical: deviceHeight * 0.006,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        deviceWidth * 0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Text("More"),
                                ),
                                SizedBox(height: ratio * 2),
                                IconButton(
                                  onPressed: () {
                                    if ((startLoc.isNotEmpty) ||
                                        data["punchin_loc"] != null ||
                                        data["punchout_loc"] != null) {
                                      try {
                                        List<LatLng> points = [];

                                        String cleanCoordStr(String input) {
                                          return input.replaceAll('_', ',');
                                        }

                                        LatLng? parseCoord(String coordStr) {
                                          final coordStrCleaned = cleanCoordStr(
                                            coordStr,
                                          );
                                          final coord =
                                              coordStrCleaned
                                                  .split(',')
                                                  .map((e) => e.trim())
                                                  .toList();
                                          if (coord.length == 2) {
                                            final lat = safeParseDouble(
                                              coord[0],
                                            );
                                            final lng = safeParseDouble(
                                              coord[1],
                                            );
                                            if (lat != null && lng != null) {
                                              return LatLng(lat, lng);
                                            }
                                          }
                                          return null;
                                        }

                                        // Add punchin_loc first
                                        if (data["punchin_loc"] != null &&
                                            data["punchin_loc"]
                                                .toString()
                                                .isNotEmpty) {
                                          final punchin = parseCoord(
                                            data["punchin_loc"],
                                          );
                                          if (punchin != null)
                                            points.add(punchin);
                                        }

                                        // Add startLoc points
                                        for (var loc in startLoc) {
                                          final point = parseCoord(loc);
                                          if (point != null) points.add(point);
                                        }

                                        // NO endLoc points added here (removed)

                                        // Add punchout_loc last
                                        if (data["punchout_loc"] != null &&
                                            data["punchout_loc"]
                                                .toString()
                                                .isNotEmpty) {
                                          final punchout = parseCoord(
                                            data["punchout_loc"],
                                          );
                                          if (punchout != null)
                                            points.add(punchout);
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
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'No valid coordinates found',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Error parsing coordinates: $e',
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
                                            'Location data is empty',
                                          ),
                                        ),
                                      );
                                    }
                                  },

                                  icon: Icon(
                                    FontAwesomeIcons.mapLocationDot,
                                    color: Color(0xFF03a9f4),
                                    size: ratio * 10,
                                  ),
                                ),
                              ],
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
