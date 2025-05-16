import 'package:employee_tracker/main.dart';
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
        print("Error decoding user data: $e");
      }
    }
  }

  Widget buildUserRow(String label, dynamic value) {
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
                fontSize: 15,
                color: Colors.grey[800],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              '${value ?? 'N/A'}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> alert(BuildContext context, message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Employee Tracker')),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03a9f4),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void clearStorage(context) async {
    try {
      await localStorage.clear();
      await alert(context, "Successfully Logged Out");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CreateScreen()),
        (route) => false,
      );
    } catch (e) {
      print('Error clearing local storage: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

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
        backgroundColor: Color(0xFF03a9f4),
        title: Text('Employee Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.06),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              color: Color(0xFFF1F9FF),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.06),
                child: Column(
                  children: [
                    if (userdata!['image'] != null &&
                        userdata!['image'].toString().isNotEmpty)
                      CircleAvatar(
                        radius: screenWidth * 0.2,
                        backgroundImage: NetworkImage(
                          'https://testapi.rabadtechnology.com/${userdata!['image']}',
                        ),
                        backgroundColor: Colors.grey[200],
                      )
                    else
                      CircleAvatar(
                        radius: screenWidth * 0.2,
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person, size: screenWidth * 0.2),
                      ),
                    SizedBox(height: 20),
                    Divider(color: Colors.grey.shade400),
                    SizedBox(height: 10),

                    buildUserRow("Company Name:", userdata!['company_name']),
                    buildUserRow("Name:", userdata!['name']),
                    buildUserRow("Designation:", userdata!['designation']),
                    buildUserRow("Salary:", userdata!['salary']),
                    buildUserRow("Email:", userdata!['db_email']),
                    buildUserRow("Mobile No.:", userdata!['mobile_no']),
                    buildUserRow("Address:", userdata!['address']),
                    buildUserRow("PAN Card No.:", userdata!['pan_card']),
                    buildUserRow("Aadhar No.:", userdata!['aadharcard']),
                    buildUserRow("Username:", userdata!['username']),
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
                    // TODO: Navigate to EditProfile screen
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
                    clearStorage(context);
                  },
                  icon: Icon(Icons.logout),
                  label: Text("Sign Out"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
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