import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Employee%20Reports/AttendanceDetail.dart';
import 'package:employee_tracker/Screens/create%20employee/updateEmp.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

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
        setState(() {
          isLoading = false;
        });
        Alert.alert(
          context,
          responseData['message'] ?? 'Unknown error occurred',
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Alert.alert(context, 'Failed to fetch data: $e');
    }
  }

  String formatDob(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Invalid Date';
    try {
      DateTime parsedDate = DateTime.parse(dateString);
      return DateFormat('dd-MM-yyyy').format(parsedDate);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  void EmpData(BuildContext context, Map<String, dynamic> item) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
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
                            borderRadius: BorderRadius.circular(ratio * 5),
                            child: Image.network(
                              item['image'] ?? '',
                              width: ratio * 32,
                              height: ratio * 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            item['name'] ?? '',
                            style: TextStyle(
                              fontSize: ratio * 7,
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
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          Text(
                            item['designation'] ?? '',
                            style: TextStyle(
                              fontSize: ratio * 7,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Salary:-",
                            style: TextStyle(
                              fontSize: ratio * 7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ("₹ ${item['salary']}" ?? 0).toString(),
                            style: TextStyle(
                              fontSize: ratio * 7,
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
                            "Date Of Birth:-",
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            formatDob(item['dob']),
                            style: TextStyle(
                              fontSize: ratio * 7,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Email:-",
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            item['email'] ?? '',
                            style: TextStyle(
                              fontSize: ratio * 7,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Pan Card No.:-",
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['pan_card'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize: ratio * 7,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Aadhaar Card No.:-",
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['aadharcard'] ?? 0).toString(),
                            style: TextStyle(
                             fontSize: ratio * 7,
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
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['address'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize: ratio * 7,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "User Name:-",
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['username'] ?? 0).toString(),
                            style: TextStyle(
                             fontSize: ratio * 7,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Joining Date.:-",
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            formatDob(item['doinofdate']),
                            style: TextStyle(
                              fontSize: ratio * 7,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Working Hours:-",
                            style: TextStyle(fontSize: ratio * 7,fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            (item['hours'] ?? 0).toString(),
                            style: TextStyle(
                              fontSize: ratio * 7,
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
                        ratio * 7,
                      ),
                      color: Color(0xFF03a9f4),
                    ),
                    padding: EdgeInsets.only(
                      top: ratio * 2,
                      bottom: ratio * 2,
                      left: ratio * 4,
                      right: ratio * 4,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "OK",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize:ratio * 6
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
                        ratio * 6
                      ),
                      color: Color(0xFF03a9f4),
                    ),
                    padding: EdgeInsets.only(
                     top: ratio * 2,
                      bottom: ratio * 2,
                      left: ratio * 4,
                      right: ratio * 4,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Attendance Detail",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ratio*6
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
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if(deviceWidth<deviceHeight){
      ratio=deviceHeight/deviceWidth;
    }else{
      ratio=deviceWidth/deviceHeight;
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee List',
          style: TextStyle(
            fontSize:ratio*9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body:
          isLoading
              ?  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius:
                          ratio*25,
                      backgroundImage: AssetImage(
                        'assets/splesh_Screen/Emp_Attend.png',
                      ), // Set the background image here
                    ),

                    SizedBox(height: 5),
                    CircularProgressIndicator(color: Color(0xFF03a9f4)),
                  ],
                ),
              )
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
                          fontSize: ratio*9,
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
                      top: ratio*2,
                      left: ratio*3,
                      right: ratio*3,
                    ),
                    padding: EdgeInsets.all(
                      ratio*1
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 247, 239, 230),
                      borderRadius: BorderRadius.circular(
                        ratio*3
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
                                      ratio*4
                                    ),
                                    child: Image.network(
                                      item['image'] ?? '',
                                      width:
                                          ratio*32,
                                      height:
                                         ratio*32,
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
                                          ratio*7,
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
                                    style: TextStyle(fontSize: ratio*7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (item['salary'] ?? 0).toString(),
                                    style: TextStyle(
                                      fontSize: ratio*7,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Designation:-",
                                    style: TextStyle(fontSize: ratio*7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item['designation'] ?? '',
                                    style: TextStyle(
                                      fontSize: ratio*7,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width:ratio*5,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    "Mobile No.:-",
                                    style: TextStyle(fontSize: ratio*7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (item['mobile_no'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize: ratio*7,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Working Hour:-",
                                    style: TextStyle(fontSize: ratio*7,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    (item['hours'] ?? '').toString(),
                                    style: TextStyle(
                                      fontSize: ratio*7,
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
                                padding: EdgeInsets.all(
                                 ratio*4,
                                ),
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(
                                   ratio*5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  FontAwesomeIcons.solidEye,
                                  size:
                                      ratio*7,
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
                                padding: EdgeInsets.all(
                                  ratio*4,
                                ),
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(
                                    ratio*5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  FontAwesomeIcons.edit,
                                  size:
                                      ratio*7,
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
                                padding: EdgeInsets.all(
                                  ratio*4,
                                ),
                                margin: EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  borderRadius: BorderRadius.circular(
                                    ratio*5,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  FontAwesomeIcons.key,
                                  size:
                                      ratio*7,
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
                                activeTrackColor: Colors.red,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.green,
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
