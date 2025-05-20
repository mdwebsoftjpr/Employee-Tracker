import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Detail%20Screen/AttendanceDetail.dart';
import 'package:employee_tracker/Screens/create%20employee/updateEmp.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(Employeelist());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Employeelist extends StatefulWidget {
  EmployeelistState createState() => EmployeelistState();
}

class EmployeelistState extends State<Employeelist> {
  int? comId;
  List<Map<String, dynamic>> EmpDetail = [];
  List<bool> isSwitchedList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    await _loadUser(); // Wait to ensure comId is set
    if (comId != null) {
      ShowEmp();
    }
  }

  Future<void> _loadUser() async {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comId = int.tryParse(user['id'].toString());
      });
    }
  }

  void ShowEmp() async {
    if (comId == null) return;
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/getemployeedetails.php',
    );
    final Map<String, dynamic> requestBody = {"company_id": comId};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final responseData = jsonDecode(response.body);

      if (responseData['success'] == true && responseData['data'] != null) {
        setState(() {
          isLoading = false;
          EmpDetail = List<Map<String, dynamic>>.from(responseData['data']);
          isSwitchedList = List<bool>.filled(EmpDetail.length, false);
        });
      } else {
        isLoading = false;
        Alert.alert(
          context,
          responseData['message'] ?? 'Unknown error occurred',
        );
      }
    } catch (e) {
      isLoading = false;
      Alert.alert(context, 'Failed to fetch data: $e');
    }
  }

  void EmpData(BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Employee Details:-",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            child: Image.network(
                              item['image'] ?? '',
                              width:
                                  25 * MediaQuery.of(context).devicePixelRatio,
                              height:
                                  25 * MediaQuery.of(context).devicePixelRatio,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            item['name'] ?? '',
                            style: TextStyle(
                              fontSize:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            "Designation:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item['designation'] ?? '',
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Salary:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ("₹ ${item['salary']}" ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Trade Name:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            item['trade_name'] ?? '',
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Date Of Birth:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['dob'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Email:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            item['email'] ?? '',
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Pan Card No.:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['pan_card'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Aadhaar Card No.:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['aadharcard'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Address.:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['address'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "User Name:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['username'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Joining Date.:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['doinofdate'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Working Hours:-",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['hours'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        6 * MediaQuery.of(context).devicePixelRatio,
                      ),
                      color: Color(0xFF03a9f4),
                    ),
                    padding: EdgeInsets.only(
                      top: 2 * MediaQuery.of(context).devicePixelRatio,
                      bottom: 2 * MediaQuery.of(context).devicePixelRatio,
                      left: 3 * MediaQuery.of(context).devicePixelRatio,
                      right: 3 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AttendanceDetail(item),
                        ),
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        6 * MediaQuery.of(context).devicePixelRatio,
                      ),
                      color: Color(0xFF03a9f4),
                    ),
                    padding: EdgeInsets.only(
                      top: 2 * MediaQuery.of(context).devicePixelRatio,
                      bottom: 2 * MediaQuery.of(context).devicePixelRatio,
                      left: 3 * MediaQuery.of(context).devicePixelRatio,
                      right: 3 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Attendance Detail",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee Detail',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: Color(0xFF03a9f4)),
              ) // ✅ Show loader first
              : EmpDetail.isEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Employee Not Found",
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.075,
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : ListView.builder(
                itemCount: EmpDetail.length,
                itemBuilder: (context, index) {
                  print(isSwitchedList);
                  final item = EmpDetail[index];
                  return Container(
                    margin: EdgeInsets.only(
                      top: 5,
                      left: MediaQuery.of(context).size.width * 0.03,
                      right: MediaQuery.of(context).size.width * 0.03,
                    ),
                    padding: EdgeInsets.all(
                      1 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 239, 230),
                      borderRadius: BorderRadius.circular(
                        2 * MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      4 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                    ),
                                    child: Image.network(
                                      item['image'] ?? '',
                                      width:
                                          25 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      height:
                                          25 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    (item['name'] ?? '').toString().length > 10
                                        ? '${(item['name'] ?? '').toString().substring(0, 10)}...'
                                        : (item['name'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize:
                                          4 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width:
                                  6 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Salary:-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (item['salary'] ?? 0).toString(),
                                    style: TextStyle(
                                      fontSize:
                                          4 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Designation:-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item['designation'] ?? '',
                                    style: TextStyle(
                                      fontSize:
                                          4 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "Mobile No.:-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (item['mobile_no'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize:
                                          4 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Working Hour:-",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (item['hours'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize:
                                          4 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                EmpData(context, item);
                              },
                              child: Container(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(
                                    4 * MediaQuery.of(context).devicePixelRatio,
                                  ),
                                ),
                                width:
                                    10 *
                                    MediaQuery.of(
                                      context,
                                    ).devicePixelRatio, // Set exact size if needed
                                height:
                                    10 *
                                    MediaQuery.of(context).devicePixelRatio,
                                alignment: Alignment.center,
                                child: Icon(
                                  FontAwesomeIcons.solidEye,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UpdateEmp(item: [item]),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(
                                    4 * MediaQuery.of(context).devicePixelRatio,
                                  ),
                                ),
                                width:
                                    10 *
                                    MediaQuery.of(
                                      context,
                                    ).devicePixelRatio, // Set exact size if needed
                                height:
                                    10 *
                                    MediaQuery.of(context).devicePixelRatio,
                                alignment: Alignment.center,
                                child: Icon(
                                  FontAwesomeIcons.edit,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => UpdateEmp(item: [item]),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.zero,
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.circular(
                                    4 * MediaQuery.of(context).devicePixelRatio,
                                  ),
                                ),
                                width:
                                    10 *
                                    MediaQuery.of(
                                      context,
                                    ).devicePixelRatio, // Set exact size if needed
                                height:
                                    10 *
                                    MediaQuery.of(context).devicePixelRatio,
                                alignment: Alignment.center,
                                child: Icon(
                                  FontAwesomeIcons.key,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            Transform.scale(
                              scale: .7, // Increase or decrease the size
                              child: Switch(
                                value: isSwitchedList[index],
                                onChanged: (bool value) {
                                  setState(() {
                                    isSwitchedList[index] = value;
                                  });
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Colors.green,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
