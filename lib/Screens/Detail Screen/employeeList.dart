import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Detail%20Screen/AttendanceDetail.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  @override
  void initState() {
    super.initState();
    _loadUser();
    ShowEmp();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comId = user['id'] ?? 'Default User';
      });
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
                            "Addhar Card No.:-",
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
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          5 * MediaQuery.of(context).devicePixelRatio,
                        ),
                        color: Color(0xFF03a9f4),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 3 * MediaQuery.of(context).devicePixelRatio,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 4 * MediaQuery.of(context).devicePixelRatio,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4 * MediaQuery.of(context).devicePixelRatio),
                Expanded(
                  flex: 1,
                  child: TextButton(
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
                          5 * MediaQuery.of(context).devicePixelRatio,
                        ),
                        color: Color(0xFF03a9f4),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 3 * MediaQuery.of(context).devicePixelRatio,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "Attendance Detail",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 4 * MediaQuery.of(context).devicePixelRatio,
                        ),
                        textAlign: TextAlign.center,
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



  void ShowEmp() async {
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
      if (responseData['success']) {
        setState(() {
          EmpDetail = List<Map<String, dynamic>>.from(responseData['data']);
        });
        print(EmpDetail);
      } else {
        Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      Alert.alert(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee Detail',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body:
          EmpDetail.isEmpty
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
                  final item = EmpDetail[index];
                  return GestureDetector(
                    onTap: () => EmpData(context, item),
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 5,
                        left: MediaQuery.of(context).size.width * 0.03,
                        right: MediaQuery.of(context).size.width * 0.03,
                      ),
                      padding: EdgeInsets.all(
                        1 * MediaQuery.of(context).devicePixelRatio,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 215, 229, 241),
                        borderRadius: BorderRadius.circular(
                          2 * MediaQuery.of(context).devicePixelRatio,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
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
                                        25 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    height:
                                        25 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  item['name']?.length > 9
                                      ? '${item['name'].substring(0, 11)}...'
                                      : item['name'] ?? '',
                                  style: TextStyle(
                                    fontSize:
                                        4 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 6 * MediaQuery.of(context).devicePixelRatio,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Salary:-",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (item['salary'] ?? 0).toString(),
                                  style: TextStyle(
                                    fontSize:
                                        4 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Designation:-",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  item['designation'] ?? '',
                                  style: TextStyle(
                                    fontSize:
                                        5 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 4 * MediaQuery.of(context).devicePixelRatio,),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Mobile No.:-",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (item['mobile_no'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize:
                                        4 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Working Hour:-",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  (item['hours'] ?? '').toString(),
                                  style: TextStyle(
                                    fontSize:
                                        4 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    color: Colors.black,
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
