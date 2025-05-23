import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:month_picker_dialog/month_picker_dialog.dart';

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

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Attendance Detail',
          style: TextStyle(
            fontSize: 18,
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
                      radius:
                          MediaQuery.of(context).size.width *
                          0.16, // Adjust the radius dynamically based on screen width
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
                  style: TextStyle(fontSize: deviceWidth * 0.05),
                ),
              )
              : ListView.builder(
                itemCount: attendanceData.length,
                itemBuilder: (context, index) {
                  final data = attendanceData[index];
                  return Padding(
                    padding: EdgeInsets.all(devicePixelRatio * .5),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: devicePixelRatio * 2,
                        left: devicePixelRatio * 3.5,
                        right: devicePixelRatio * 3.5,
                      ),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(deviceWidth * 0.03),
                        color: const Color.fromARGB(255, 247, 239, 230),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                    Text(
                                  "Date:",
                                  style: TextStyle(
                                    fontSize: deviceWidth * 0.04,
                                  ),
                                ),
                                    Text(
                                  data['date'] != null
                                      ? data['date']
                                          .split('-')
                                          .reversed
                                          .join('-')
                                      : '',
                                  style: TextStyle(fontSize: deviceWidth * 0.04),
                                ),
                                Text(
                                  "Break Time: ${data['break_time'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: deviceWidth * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Punch In: ${data['time_in'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: deviceWidth * 0.04,
                                  ),
                                ),
                                Text(
                                  "Punch Out: ${data['time_out'] ?? ''}",
                                  style: TextStyle(
                                    fontSize: deviceWidth * 0.04,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: deviceHeight * 0.005,
                                    horizontal: deviceWidth * 0.03,
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
                                      fontSize: deviceWidth * 0.04,
                                    ),
                                  ),
                                ),
                                SizedBox(height: deviceHeight * 0.005),
                                Text(
                                  "Total Hours: ${data['hours']}",
                                  style: TextStyle(
                                    fontSize: deviceWidth * 0.04,
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
