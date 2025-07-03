import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(GetMaterialApp(home: AttDownlod(), debugShowCheckedModeBanner: false));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class AttDownlod extends StatefulWidget {
  @override
  AttDownlodState createState() => AttDownlodState();
}

class AttDownlodState extends State<AttDownlod> {
  int? comId;
  List<Map<String, dynamic>> attendanceData = [];
  bool isLoading = false;
  String month = DateTime.now().month.toString();
  String year = DateTime.now().year.toString();
  String formatDate(String rawDate) {
    try {
      // Split the date manually to support formats like "2025-7-1"
      final parts = rawDate.split('-');
      if (parts.length == 3) {
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final dt = DateTime(year, month, day);
        return DateFormat('dd-MM-yyyy').format(dt);
      }
      return rawDate;
    } catch (e) {
      return rawDate;
    }
  }

  bool isSavingFile = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    DownlodData();
  }

  Future<void> _loadUser() async {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comId = user['id'];
      });
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    final now = DateTime.now();
    final DateTime? selectedMonth = await showMonthPicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );

    if (selectedMonth != null) {
      setState(() {
        month = '${selectedMonth.month}';
        year = '${selectedMonth.year}';
      });
      await DownlodData(); // trigger API call when month selected
    }
  }

  Future<void> DownlodData() async {
    if (comId == null || month == null || year == null) {
      Alert.alert(context, "Please select month and year");
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/employeemonthsattendence.php',
    );
    final requestBody = {
      "company_id": comId,
      "month": int.parse(month!),
      "year": int.parse(year!),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        setState(() {
          attendanceData = List<Map<String, dynamic>>.from(
            responseData['data'],
          );
          isLoading = false;
        });
      } else {
        Alert.alert(context, responseData['message'] ?? "Failed to fetch data");
        setState(() {
          attendanceData = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      Alert.alert(context, 'Error: ${e.toString()}');
    }
  }

  Future<void> exportJsonToExcel() async {
    if (isSavingFile || attendanceData.isEmpty || month == null || year == null)
      return;
    setState(() => isSavingFile = true);

    try {
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];

      final int m = int.parse(month!);
      final int y = int.parse(year!);
      final dateFormatter = DateFormat('dd-MM-yyyy');

      // Step 1: Collect all unique attendance dates (parsed safely)
      final Set<String> uniqueDates = {};

      for (var emp in attendanceData) {
        if (emp['att_status'] is List) {
          for (var att in emp['att_status']) {
            final rawDate = att['date']?.toString();
            DateTime? dt;
            try {
              dt = DateFormat('y-M-d').parseStrict(rawDate ?? '');
            } catch (_) {
              dt = null;
            }

            if (dt != null && dt.month == m && dt.year == y) {
              uniqueDates.add(dateFormatter.format(dt));
            }
          }
        }
      }

      final List<String> allDates =
          uniqueDates.toList()..sort(
            (a, b) => dateFormatter.parse(a).compareTo(dateFormatter.parse(b)),
          );

      // Step 2: Header row
      final headers = [
        'ID',
        'Name',
        'Total Present',
        'Total Absent',
        'Total Hours',
        ...allDates,
      ];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(1, i + 1);
        cell.setText(headers[i]);

        final style = cell.cellStyle;
        style.bold = true;
        style.hAlign = xlsio.HAlignType.center;
        style.vAlign = xlsio.VAlignType.center;
        style.borders.all.lineStyle = xlsio.LineStyle.thin;

        if (headers[i] == 'Name') {
          cell.columnWidth = 20;
        } else {
          sheet.autoFitColumn(i + 1);
        }
      }

      // Step 3: Data rows
      for (var i = 0; i < attendanceData.length; i++) {
        final emp = attendanceData[i] as Map<String, dynamic>;
        final row = i + 2;

        final base = [
          emp['id'].toString(),
          emp['name']?.toString() ?? '',
          emp['total_p']?.toString() ?? '0',
          emp['total_a']?.toString() ?? '0',
          emp['hours']?.toString() ?? '0',
        ];

        for (var j = 0; j < base.length; j++) {
          final cell = sheet.getRangeByIndex(row, j + 1);
          cell.setText(base[j]);

          final style = cell.cellStyle;
          style.hAlign =
              (j == 1) ? xlsio.HAlignType.left : xlsio.HAlignType.center;
          style.vAlign = xlsio.VAlignType.center;
          style.borders.all.lineStyle = xlsio.LineStyle.thin;
          style.wrapText = (j == 1);
          if (j == 1) cell.columnWidth = 35;
        }

        // Step 4: Attendance map per employee
        final Map<String, String> dateMap = {};
        if (emp['att_status'] is List) {
          for (var att in emp['att_status']) {
            final rawDate = att['date']?.toString();
            final status = (att['status'] ?? '').toString().toUpperCase();

            DateTime? dt;
            try {
              dt = DateFormat('y-M-d').parseStrict(rawDate ?? '');
            } catch (_) {
              dt = null;
            }

            if (dt != null && status.isNotEmpty) {
              final formattedDate = dateFormatter.format(dt);
              dateMap[formattedDate] = status;
            }
          }
        }

        // Step 5: Fill status for each date
        for (var j = 0; j < allDates.length; j++) {
          final cell = sheet.getRangeByIndex(row, 6 + j);
          final val = dateMap[allDates[j]] ?? '-';
          cell.setText(val);

          final style = cell.cellStyle;
          style.hAlign = xlsio.HAlignType.center;
          style.vAlign = xlsio.VAlignType.center;
          style.borders.all.lineStyle = xlsio.LineStyle.thin;
          style.wrapText = true;
          cell.columnWidth = 15;
        }
      }

      // Step 6: Save the Excel file
      final bytes = workbook.saveAsStream();
      workbook.dispose();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/attendance_${month}_$year.xlsx');
      await file.writeAsBytes(bytes);

      final saved = await FlutterFileDialog.saveFile(
        params: SaveFileDialogParams(
          sourceFilePath: file.path,
          fileName: 'attendance_${month}_$year.xlsx',
        ),
      );

      if (saved != null) {
        Get.snackbar("EmpAttend", "Saved to: $saved");
        await OpenFile.open(saved);
      } else {
        Get.snackbar("EmpAttend", "Save cancelled");
      }
    } catch (e) {
      Get.snackbar("Export Error", e.toString());
    } finally {
      setState(() => isSavingFile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    double ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance Xl",
          style: TextStyle(color: Colors.white, fontSize: ratio * 9),
        ),
        backgroundColor: Color(0xFF03a9f4),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Column(
              children: [
                Icon(Icons.calendar_month, size: ratio * 10),
                Text(
                  (month != null)
                      ? DateFormat.MMMM().format(DateTime(0, int.parse(month)))
                      : 'Month',

                  style: TextStyle(fontSize: ratio * 5, color: Colors.white),
                ),
              ],
            ),
            onPressed: () => _pickMonth(context),
          ),
          IconButton(
            icon: Column(
              children: [
                Icon(Icons.sim_card_download_sharp, size: ratio * 10),
                Text(
                  'Downlod',
                  style: TextStyle(fontSize: ratio * 5, color: Colors.white),
                ),
              ],
            ),
            onPressed: () async {
              if (attendanceData.isNotEmpty) {
                await exportJsonToExcel();
              } else {
                Alert.alert(context, "No data to export");
              }
            },
          ),
        ],
      ),
      body: Center(
        child:
            isLoading
                ? CircularProgressIndicator()
                : (attendanceData.isNotEmpty
                    ? ListView.builder(
                      itemCount: attendanceData.length,
                      itemBuilder: (context, index) {
                        final item = attendanceData[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: ratio * 2,
                            horizontal: ratio * 5,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(ratio * 4),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(ratio * 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 🔵 Circular Number Badge
                                Container(
                                  width: ratio * 20,
                                  height: ratio * 20,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF03a9f4),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        fontSize: ratio * 8,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(width: ratio * 6), // spacing
                                // 🧑 Name + Hours
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontSize: ratio * 6.5,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: ratio * 1.5),
                                      Text(
                                        "Total Hours: ${item['hours']}",
                                        style: TextStyle(fontSize: ratio * 6),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(width: ratio * 4), // spacing
                                // 📊 Attendance Stats
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Present: ${item['total_p']}',
                                        style: TextStyle(fontSize: ratio * 5.8),
                                      ),
                                      SizedBox(height: ratio * 1.5),
                                      Text(
                                        "Absent: ${item['total_a']}",
                                        style: TextStyle(fontSize: ratio * 5.8),
                                      ),
                                    ],
                                  ),
                                ),

                                // ℹ️ Info Icon (tight layout)
                                IconButton(
                                  onPressed: () {
                                    MoreInfo(item['att_status'], ratio);
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.circleInfo,
                                    size: ratio * 11,
                                    color: Colors.black87,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints:
                                      BoxConstraints(), // ensures no extra space
                                  splashRadius: ratio * 10,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    : Text(
                      "Attendance Not found",
                      style: TextStyle(fontSize: ratio * 9),
                    )),
      ),
    );
  }

  void MoreInfo(List<dynamic> info, double ratio) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: [
              Text(
                'Attendance Details',
                style: TextStyle(
                  fontSize: ratio * 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: Column(
              children: [
                // Header row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Text(
                          'Date',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(thickness: 1),
                // List with alternate row colors
                Expanded(
                  child: ListView.builder(
                    itemCount: info.length,
                    itemBuilder: (context, index) {
                      final item = info[index];
                      final isEven = index % 2 == 0;

                      return Container(
                        color: isEven ? Colors.grey[100] : Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                formatDate(item['date'] ?? ''),
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    (item['status'] ?? '').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          (item['status'] == 'A')
                                              ? Colors.red
                                              : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03a9f4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: ratio * 2,
                  vertical: ratio * 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ratio * 5),
                ),
                elevation: 4,
              ),
              child: Text('Close', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

/* 
 */
