import 'package:employee_tracker/Screens/Detail%20Screen/AttendanceDetail.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(Attendance());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Attendance extends StatefulWidget {
  AttendanceState createState() => AttendanceState();
}

class AttendanceState extends State<Attendance> {
  String name = "key_person";
  String comName = 'Company';
  int? comId;
  List<Map<String, dynamic>> attendanceData = [];
  @override
  void initState() {
    super.initState();
    _loadUser();
    ShowMaster();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        name = user['name'] ?? 'Default User';
        comId = user['id'] ?? 'Default User';
      });
    }
    var visit = localStorage.getItem('visitout') ?? false;
    if (visit == true) {
      print("Visit out status: $visit");
    }
  }

  void ShowMaster() async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/allemployeeattendence.php',
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
    attendanceData = List<Map<String, dynamic>>.from(responseData['data']);
  });
        print(attendanceData);
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
          'Attendance  Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          attendanceData.isEmpty
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Please Select Date",
                        style: TextStyle(
                          fontFamily: 'Myfont',
                          fontSize: MediaQuery.of(context).size.width * 0.075,
                        ),
                      ),
                    ],
                  ),
                ],
              )
              :ListView.builder(
  itemCount: attendanceData.length,
  itemBuilder: (context, index) {
    final item = attendanceData[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceDetail(item['id']),
          ),
        );
      },
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
        child: ListTile(
          subtitle: Padding(
            padding: EdgeInsets.all(
             0.1 * MediaQuery.of(context).devicePixelRatio,
            ),
            child: Row(
              children: [
                Container(
                  width:MediaQuery.of(context).size.width * 0.06 ,
                  height:MediaQuery.of(context).size.width * 0.06,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(35),color:Colors.white),
                  child:Center(
                    child:  Text('${index + 1}',style: TextStyle(fontSize: 4 * MediaQuery.of(context).devicePixelRatio,color: Colors.black)),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ),
                      child: Image.network(
                        'https://testapi.rabadtechnology.com/uploads/${item['image'] ?? ''}',
                        width: 25 * MediaQuery.of(context).devicePixelRatio,
                        height: 20 * MediaQuery.of(context).devicePixelRatio,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 5,),
                    Text(
                      item['empname'] ?? '',
                      style: TextStyle(
                        fontSize: 4 * MediaQuery.of(context).devicePixelRatio,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                Column(
                  children: [
                    Text("Punch In:-",
                        style: TextStyle(
                            fontSize: 4 *
                                MediaQuery.of(context).devicePixelRatio,
                            color: Colors.black)),
                    Text(item['time_in'] ?? '',
                        style: TextStyle(
                            fontSize: 4 *
                                MediaQuery.of(context).devicePixelRatio,
                            color: Colors.black)),
                    Text("Punch Out:-",
                        style: TextStyle(
                            fontSize: 4 *
                                MediaQuery.of(context).devicePixelRatio,
                            color: Colors.black)),
                    Text(item['time_out'] ?? '',
                        style: TextStyle(
                            fontSize: 4 *
                                MediaQuery.of(context).devicePixelRatio,
                            color: Colors.black)),
                  ],
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: (item['attendance_status'] == 'P' ||
                                item['attendance_status'] == 'p')
                            ? Color(0xFF03a9f4)
                            : Colors.red,
                      ),
                      padding: EdgeInsets.all(
                          3 * MediaQuery.of(context).devicePixelRatio),
                      width: MediaQuery.of(context).size.width * 0.10,
                      child: Center(
                        child: Text(
                          item['attendance_status'] ?? '',
                          style: TextStyle(
                            fontSize: 5 *
                                MediaQuery.of(context).devicePixelRatio,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text("Total Hours:-",
                        style: TextStyle(
                            fontSize: 3 *
                                MediaQuery.of(context).devicePixelRatio,
                            color: Colors.black)),
                    Text(item['hours']?.toString() ?? '0',
                        style: TextStyle(
                            fontSize: 5 *
                                MediaQuery.of(context).devicePixelRatio,
                            color: Colors.black)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  },
)

    );
  }
}
