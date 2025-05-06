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
                              'https://testapi.rabadtechnology.com/${item['image'] ?? ''}',
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
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF03a9f4),
                ),
                padding: EdgeInsets.only(
                  top: 2 * MediaQuery.of(context).devicePixelRatio,
                  left: 5 * MediaQuery.of(context).devicePixelRatio,
                  right: 4 * MediaQuery.of(context).devicePixelRatio,
                  bottom: 2 * MediaQuery.of(context).devicePixelRatio,
                ),
                child: Text("OK", style: TextStyle(color: Colors.black)),
              ),
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(responseData['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
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
                        left: MediaQuery.of(context).size.width * 0.05,
                        right: MediaQuery.of(context).size.width * 0.05,
                      ),
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 215, 229, 241),
                        borderRadius: BorderRadius.circular(
                          2 * MediaQuery.of(context).devicePixelRatio,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    4 * MediaQuery.of(context).devicePixelRatio,
                                  ),
                                  child: Image.network(
                                    'https://testapi.rabadtechnology.com/${item['image'] ?? ''}',
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
                                  item['name'] ?? '',
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
                          Expanded(
                            child: Column(
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
