import 'package:employee_tracker/Screens/Create%20Company/updateCom.dart';
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:employee_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

final LocalStorage localStorage = LocalStorage('employee_tracker');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MyApp());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: Adminprofile());
  }
}

class Adminprofile extends StatefulWidget {
  @override
  AdminprofileState createState() => AdminprofileState();
}

class AdminprofileState extends State<Adminprofile> {
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
        print(user);
      } catch (e) {
        print("Error decoding user data: $e");
      }
    }
  }

  Widget buildUserRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              '$label',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              '${value ?? 'N/A'}',
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    if (userdata == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF03a9f4),
          title: Text('Profile'),
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Admin Profile',
          style: TextStyle(
            fontSize: 6*MediaQuery.of(context).devicePixelRatio,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Card with all details
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 5,
              color: Color(0xFFF0F9FF),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Column(
                  children: [
                    /// Profile image
                    if (userdata!['image'] != null &&
                        userdata!['image'].toString().isNotEmpty)
                      CircleAvatar(
                        radius: screenWidth * 0.18,
                        backgroundImage: NetworkImage(
                          'https://testapi.rabadtechnology.com/${userdata!['image']}',
                        ),
                        backgroundColor: Colors.grey[200],
                      )
                    else
                      CircleAvatar(
                        radius: screenWidth * 0.18,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: screenWidth * 0.2),
                      ),

                    SizedBox(height: 20),
                    Divider(thickness: 1, color: Colors.grey[400]),
                    SizedBox(height: 10),

                    /// Admin details
                    buildUserRow("Company Name:", userdata!['company_name']),
                    buildUserRow("Register Id:", userdata!['trade_name']),
                    buildUserRow("Key Person:", userdata!['key_person']),
                    buildUserRow("Email:", userdata!['db_email']),
                    buildUserRow("Mobile No.:", userdata!['mobile_no']),
                    buildUserRow("GST No.:", userdata!['gstin_no']),
                    buildUserRow("Address:", userdata!['address']),
                    buildUserRow("PAN Card No.:", userdata!['pan_card']),
                    buildUserRow("Username:", userdata!['username']),
                    buildUserRow("Website:", userdata!['website_link']),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            /// Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (userdata != null && userdata!['id'] != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Updatecom(),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Edit Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03a9f4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminHome()),
                    );
                  },
                  icon: Icon(Icons.home),
                  label: Text("Go To Home"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03a9f4),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
