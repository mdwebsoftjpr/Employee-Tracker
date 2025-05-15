import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
              if (value['attendance_status'] == 'P' || value['attendance_status'] == 'p') {
                totalPresentDays++;
              }
            }
          });

          // Calculate attendance percentage
          attendancePercentage = (totalPresentDays / 31) * 100;

          setState(() {
            attendanceData = tempList.reversed.toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        }
      } else {
        setState(() {
          attendanceData = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    final item = widget.items;
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final imageUrl = (item['image'] != null && item['image'].toString().trim().isNotEmpty)
        ?item['image']
        : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Monthly Attendance Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: deviceWidth * 0.06,
            fontWeight: FontWeight.bold,
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(deviceWidth * 0.04),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(deviceWidth * 0.02),
                        child: Image.network(
                          imageUrl,
                          width: deviceWidth * 0.25,
                          height: deviceHeight * 0.17,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: deviceHeight * 0.01),
                      Text(
                        item['empname'] ?? 'Unknown',
                        style: TextStyle(fontSize: deviceWidth * 0.045),
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
                            fontSize: deviceWidth * 0.05,
                            color: Colors.black,
                          ),
                        ),
                        footer: Text(
                          "Total: $totalPresentDays / 31",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: deviceWidth * 0.045,
                          ),
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: Colors.blue,
                      ),
                      Text(
                        "This Month Attendance % $attendancePercentage",
                        style: TextStyle(fontSize: deviceWidth * 0.04),
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
              fontSize: devicePixelRatio * 7,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: attendanceData.isEmpty
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
                            borderRadius: BorderRadius.circular(
                              deviceWidth * 0.03,
                            ),
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
                                      "Date: ${data['date'] ?? ''}",
                                      style: TextStyle(
                                        fontSize: deviceWidth * 0.04,
                                      ),
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
                                        color: (data['attendance_status'] == 'P' ||
                                                data['attendance_status'] == 'p')
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
          ),
        ],
      ),
    );
  }
}
