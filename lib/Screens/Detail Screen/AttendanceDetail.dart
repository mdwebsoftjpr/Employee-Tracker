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
  int? MonthNo;
  int? YearNo;
  final int currentExp = 85;
  final int totalExp = 100;
  List<Map<String, dynamic>> attendanceData = [];

  @override
  void initState() {
    super.initState();
    empId = widget.items['id'];
    ComId = widget.items['company_id'];
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
      final AttData = data['data'];
      if (success) {
        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(AttData);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    double percent = currentExp / totalExp;

    final imageUrl =
        (item['image'] != null && item['image'].toString().trim().isNotEmpty)
            ? 'https://testapi.rabadtechnology.com/uploads/${item['image']}'
            : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Attendance Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: deviceWidth * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.date_range, color: Colors.white, size: deviceWidth * 0.06),
            onPressed: _pickMonth,
            tooltip: "Pick Month",
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                        Text(item['empname'] ?? 'Unknown', style: TextStyle(fontSize: deviceWidth * 0.045)),
                        if (MonthNo != null && YearNo != null) ...[
                          Text("Month: $MonthNo", style: TextStyle(fontSize: deviceWidth * 0.04)),
                          Text("Year: $YearNo", style: TextStyle(fontSize: deviceWidth * 0.04)),
                        ],
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
                          percent: percent,
                          center: Text(
                            "${(percent * 100).toInt()}%",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: deviceWidth * 0.05,
                              color: Colors.black,
                            ),
                          ),
                          footer: Text(
                            "EXP: $currentExp / $totalExp",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: deviceWidth * 0.045,
                            ),
                          ),
                          circularStrokeCap: CircularStrokeCap.round,
                          progressColor: Colors.blue,
                        ),
                        Text("This Month Attendance %", style: TextStyle(fontSize: deviceWidth * 0.04)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            attendanceData.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(deviceWidth * 0.04),
                    child: Text(
                      "Please Select month",
                      style: TextStyle(fontSize: deviceWidth * 0.05),
                    ),
                  )
                :  ListView.builder(
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final data = attendanceData[index];
                      return Padding(
                        padding: EdgeInsets.all(deviceWidth * 0.04),
                        child: Container(
                          margin: EdgeInsets.all(deviceWidth * 0.025),
                          padding: EdgeInsets.all(deviceWidth * 0.025),
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
                                    Text("Date: ${data['date'] ?? ''}", style: TextStyle(fontSize: deviceWidth * 0.04)),
                                    Text("Break Time: ${data['break_time'] ?? ''}", style: TextStyle(fontSize: deviceWidth * 0.04)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Punch In: ${data['time_in'] ?? ''}", style: TextStyle(fontSize: deviceWidth * 0.04)),
                                    Text("Punch Out: ${data['time_out'] ?? ''}", style: TextStyle(fontSize: deviceWidth * 0.04)),
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
                                        color: (data['attendance_status'] == 'P' || data['attendance_status'] == 'p')
                                            ? Color(0xFF03a9f4)
                                            : Colors.redAccent,
                                        borderRadius: BorderRadius.circular(deviceWidth * 0.044),
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
                                    Text("Total Hours: ${data['hours'] ?? ''}", style: TextStyle(fontSize: deviceWidth * 0.04)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
