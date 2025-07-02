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
  String? month;
  String? year;
  bool isSavingFile = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
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

    final url = Uri.parse('https://testapi.rabadtechnology.com/employeemonthsattendence.php');
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
          attendanceData = List<Map<String, dynamic>>.from(responseData['data']);
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
    if (isSavingFile || attendanceData.isEmpty || month == null || year == null) return;
    setState(() => isSavingFile = true);

    try {
      final workbook = xlsio.Workbook();
      final sheet = workbook.worksheets[0];
      final int m = int.parse(month!);
      final int y = int.parse(year!);
      final int lastDay = DateTime(y, m + 1, 0).day;
      final allDates = List.generate(lastDay, (i) => DateFormat('yyyy-MM-dd').format(DateTime(y, m, i + 1)));

      final headers = ['ID', 'Name', 'Total P', 'Total A', 'Hours', ...allDates];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(1, i + 1);
        cell.setText(headers[i]);
        final style = cell.cellStyle;
        style.bold = true;
        style.hAlign = xlsio.HAlignType.center;
        style.vAlign = xlsio.VAlignType.center;
        style.borders.all.lineStyle = xlsio.LineStyle.thin;
        sheet.autoFitColumn(i + 1);
      }

      for (var i = 0; i < attendanceData.length; i++) {
        final emp = attendanceData[i] as Map<String, dynamic>;
        final row = i + 2;
        final base = [
          emp['id'].toString(),
          emp['name'] ?? '',
          emp['total_p']?.toString() ?? '0',
          emp['total_a']?.toString() ?? '0',
          emp['hours']?.toString() ?? '0',
        ];
        for (var j = 0; j < base.length; j++) {
          final cell = sheet.getRangeByIndex(row, j + 1);
          cell.setText(base[j]);
          final style = cell.cellStyle;
          style.hAlign = xlsio.HAlignType.center;
          style.vAlign = xlsio.VAlignType.center;
          style.borders.all.lineStyle = xlsio.LineStyle.thin;
        }

        final dateMap = <String, String>{};
        if (emp['att_status'] is List) {
          for (var att in emp['att_status']) {
            final rawDate = att['date'];
            final rawStatus = (att['status'] ?? '').toString().toUpperCase();
            final dt = DateTime.tryParse(rawDate ?? '');
            if (dt != null && rawStatus.isNotEmpty) {
              final key = DateFormat('yyyy-MM-dd').format(dt);
              dateMap[key] = rawStatus;
            }
          }
        }

        for (var j = 0; j < allDates.length; j++) {
          final cell = sheet.getRangeByIndex(row, 6 + j);
          final val = dateMap[allDates[j]] ?? '-';
          cell.setText(val);
          final style = cell.cellStyle;
          style.hAlign = xlsio.HAlignType.center;
          style.vAlign = xlsio.VAlignType.center;
          style.wrapText = true;
          style.borders.all.lineStyle = xlsio.LineStyle.thin;
        }
      }

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
        Get.snackbar("EmpAttend", "✅ Saved to: $saved");
        await OpenFile.open(saved);
      } else {
        Get.snackbar("EmpAttend", "❌ Save cancelled");
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
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Attendance Download",
          style: TextStyle(color: Colors.white, fontSize: ratio * 9),
        ),
        backgroundColor: Colors.indigo,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Column(
              children: [
                Icon(Icons.calendar_month, size: ratio * 10),
                Text('Month', style: TextStyle(fontSize: ratio * 5)),
              ],
            ),
            onPressed: () => _pickMonth(context),
          ),
          IconButton(
            icon: Column(
              children: [
                Icon(Icons.download, size: ratio * 10),
                Text('Export', style: TextStyle(fontSize: ratio * 5)),
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
        child: isLoading
            ? CircularProgressIndicator()
            : (attendanceData.isNotEmpty
                ? ListView.builder(
                    itemCount: attendanceData.length,
                    itemBuilder: (context, index) {
                      final item = attendanceData[index];
                      return ListTile(
                        title: Text(item['name'] ?? 'No Name'),
                        subtitle: Text("ID: ${item['id']} - Total P: ${item['total_p']}"),
                      );
                    },
                  )
                : Text("Attendance Not found")),
      ),
    );
  }
}
