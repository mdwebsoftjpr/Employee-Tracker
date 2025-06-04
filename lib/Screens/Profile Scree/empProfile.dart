import 'package:employee_tracker/Screens/Home%20Screen/EmpHome.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Empprofile()));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class Empprofile extends StatefulWidget {
  @override
  EmpprofileState createState() => EmpprofileState();
}

class EmpprofileState extends State<Empprofile> {
  Map<String, dynamic>? userdata;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      try {
        var user = jsonDecode(userJson);
        setState(() {
          userdata = user;
        });
      } catch (e) {
      }
    }
  }

  Widget buildUserRow(String label, dynamic value) {
     double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: ratio*7,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              '${value ?? 'N/A'}',
              style: TextStyle(fontSize: ratio*7, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
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
    if (userdata == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF03a9f4),
          title: Text('Profile'),
          leading: BackButton(color: Colors.white),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee Profile',
          style: TextStyle(
            fontSize: ratio*9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(deviceWidth * 0.06),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ratio*10),
              ),
              elevation: 6,
              color: Color(0xFFF1F9FF),
              child: Padding(
                padding: EdgeInsets.all(deviceWidth * 0.06),
                child: Column(
                  children: [
                    if (userdata!['image'] != null &&
                        userdata!['image'].toString().isNotEmpty)
                      CircleAvatar(
                        radius: deviceWidth * 0.2,
                        backgroundImage: NetworkImage(
                          'https://testapi.rabadtechnology.com/${userdata!['image']}',
                        ),
                        backgroundColor: Colors.grey[200],
                      )
                    else
                      CircleAvatar(
                        radius: deviceWidth * 0.2,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: deviceWidth * 0.2),
                      ),
                    SizedBox(height: 20),
                    Divider(color: Colors.grey.shade400),
                    SizedBox(height: 10),
                    buildUserRow("Name:", userdata!['name']),
                    buildUserRow("Designation:", userdata!['designation']),
                    buildUserRow("Salary:", userdata!['salary']),
                    buildUserRow("Email:", userdata!['db_email']),
                    buildUserRow("Mobile No. :", userdata!['mobile_no']),
                    buildUserRow("Address:", userdata!['address']),
                    buildUserRow("PAN Card No.:", userdata!['pan_card']),
                    buildUserRow("Aadhar No. :", userdata!['aadharcard']),
                    buildUserRow("D.O.B. :", userdata!['dob']),
                   buildUserRow("Joining Date:", userdata!['create_at']?.substring(0, 10) ?? ''),
                    buildUserRow("Work Hour:", userdata!['hours']),
                    buildUserRow("Username:", userdata!['username']),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmpHome()),
                );
              },
              icon: Icon(Icons.home),
              label: Text("Go to Home"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03a9f4),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: deviceWidth * 0.06,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(deviceWidth * 0.07),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
