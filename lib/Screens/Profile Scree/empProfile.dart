import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

void main() async {
  await _initializeLocalStorage();
  runApp(Empprofile());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Empprofile extends StatefulWidget {
  EmpprofileState createState() => EmpprofileState();
}

class EmpprofileState extends State<Empprofile> {
  Map<String, dynamic>? userdata;

  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);

      setState(() {
        userdata = user;
        print(userdata);
      });
    }
  }


   Widget buildUserRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$label',
              style: TextStyle(
                fontSize: 6 * MediaQuery.of(context).devicePixelRatio,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${value ?? 'N/A'}',
              style: TextStyle(
                fontSize: 6 * MediaQuery.of(context).devicePixelRatio,
              ),
            ),
          ),
        ],
      ),
    );
  }
@override
  Widget build(BuildContext context) {
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
        title: Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
        child: Center(
          child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 215, 229, 241),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              if (userdata!['image'] != null &&
                  userdata!['image'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.3),
                  child: Image.network(
                  'https://testapi.rabadtechnology.com/${userdata!['image']}',
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                ),
              SizedBox(height: 10),
              buildUserRow("Company Name:", userdata!['company_name']),
              buildUserRow("Name:", userdata!['name']),
              buildUserRow("Designation:", userdata!['designation']),
               buildUserRow("Salery:", userdata!['salary']),
              buildUserRow("Email:", userdata!['db_email']),
              buildUserRow("Mobile No.:", userdata!['mobile_no']),
              buildUserRow("Address:", userdata!['address']),
              buildUserRow("Pan Card No.:", userdata!['pan_card']),
              buildUserRow("Addhar No.:", userdata!['aadharcard']),
              buildUserRow("User Name:", userdata!['username']),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to EditProfile screen or open edit form
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF03a9f4), // Custom blue color
                  foregroundColor: Colors.white, // Text/icon color
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Text("Edit Profile"),
              ),
            ],
          ),
        ),
      
        )),
    );
  }}
