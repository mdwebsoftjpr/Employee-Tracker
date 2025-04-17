import 'dart:convert';

import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:employee_tracker/Screens/Home%20Screen/EmpHome.dart';
import 'Screens/Create Company/CreateCom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:localstorage/localstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();

  String? user = localStorage.getItem("user");
  String? role = localStorage.getItem("role");

  print('User: $user');
  print('Role: $role');

  // Clean up role string just in case it was jsonEncoded
  role = role?.toString().replaceAll('"', '').trim().toLowerCase();

  Widget homeScreen;

  if (user != null && user != '') {
    (role == 'admin') ?
      homeScreen = AdminHome():
    (role == 'employee') ?
      homeScreen = EmpHome():
      homeScreen = CreateScreen();
  } else {
    homeScreen = CreateScreen();
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: homeScreen,
  ));
}


Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');



class CreateScreen extends StatefulWidget {
  @override
  _createScreen createState() => _createScreen();
}

class _createScreen extends State<CreateScreen> {
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Function to load user data after localStorage is initialized
  Future<void> _loadUserData() async {
    var storedUser = await localStorage.getItem('user');
    if (!mounted) return;
    setState(() {
      user = storedUser != null ? jsonDecode(storedUser) : '';
    });
  }

  bool TermCondition = false;
  bool privacyPolicy = false;
  String msg = 'msg';
  String user = 'Demo';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController Uname = TextEditingController();
  final TextEditingController userId = TextEditingController();
  final TextEditingController password = TextEditingController();
  void login(context) async {

    if (_formKey.currentState?.validate() ?? false) {
      if (!TermCondition || !privacyPolicy) {
        // Show an error message if checkbox is not checked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please accept the terms and conditions.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the function without proceeding further
      }

      String ComName = Uname.text;
      String userid = userId.text;
      String Cpassword = password.text;

      final url = Uri.parse('https://testapi.rabadtechnology.com/login.php');
      final Map<String, dynamic> requestBody={
         "company_name": ComName,
    "email": userid,
    "password": Cpassword
      };
     try {
  final response = await http.post(
    url, // Your API endpoint
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(requestBody),
  );

  print("sahil");

  // Decode response
  final responseData = jsonDecode(response.body);

  final success = responseData['success'];
  final message = responseData['message'];
  final role = responseData['role'];
  final data = responseData['data'];

  print("Type: $data");

  if (success == true) {
    // Save to localStorage
    await localStorage.setItem('user', jsonEncode(data));
    await localStorage.setItem('role', jsonEncode(role));

    // Optional alert function
    alert();

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );

    // Navigate based on role
    if (role.toString().toLowerCase() == "admin") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminHome()),
      );
    } else if (role.toString().toLowerCase() == "employee") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmpHome()),
      );
    }

  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Update state (if needed)
  setState(() {
    msg = message;
  });

} catch (e) {
  print("Error: $e");
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Something went wrong. Please check your internet connection.')),
  );
}

    }
  }

  void alert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Message:'),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Image.asset(
                  'assets/images/LogoMain.jpg',
                  width: 100,
                  height: 100,
                ),
                SizedBox(height: 10),
                Text(
                  "Sign-In",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Hello Lets's get Started",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: Uname,
                        decoration: InputDecoration(
                          labelText: 'Enter Your Company Name',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              30.0,
                            ), // Set the border radius
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: Icon(Icons.business),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your Company Name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: userId,
                        decoration: InputDecoration(
                          labelText: 'Enter Your User Id',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              30.0,
                            ), // Set the border radius
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your User Id';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Password field
                      TextFormField(
                        controller: password,
                        decoration: InputDecoration(
                          labelText: 'Enter Your Password',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              30.0,
                            ), // Set the border radius
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true, // Hides the password text
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter Your Password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: TermCondition,
                            onChanged: (bool? newValue) {
                              setState(() {
                                TermCondition = newValue!;
                              });
                            },
                          ),
                          Text(
                            "I accept",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextButton(
                            onPressed: () => print("term Com"),
                            child: Text("Terms & Conditions"),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: privacyPolicy,
                            onChanged: (bool? newValue) {
                              setState(() {
                                privacyPolicy = newValue!;
                              });
                            },
                          ),
                          Text(
                            "I accept",
                            style: TextStyle(color: Colors.black),
                          ),
                          TextButton(
                            onPressed: () => print("privacy"),
                            child: Text("Privacy Policy"),
                          ),
                        ],
                      ),
                      // Submit button
                      ElevatedButton(
                        onPressed: () => login(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          padding: EdgeInsets.only(
                            top: 5,
                            bottom: 5,
                            left: 15,
                            right: 15,
                          ),
                          maximumSize: Size(150, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                        ),
                        child: Text(
                          'Login User',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "Don't Have Company?",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Container(
                              child: TextButton(
                                onPressed:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateCom(),
                                      ),
                                    ),
                                child: Text("Create Company"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center, // Center the Row content
                          children: [
                            // Left line (Container)
                            Container(
                              height: 1,
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.2, // 30% width for the left line
                              color: Colors.black,
                            ),

                            SizedBox(
                              width: 10,
                            ), // Space between the lines and the text
                            // Text in the middle
                            Text(
                              "Follow on",
                              style: TextStyle(
                                fontSize: 16,
                              ), // Adjust the text size as needed
                            ),

                            SizedBox(
                              width: 10,
                            ), // Space between the text and the right line
                            // Right line (Container)
                            Container(
                              height: 1,
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.2, // 30% width for the right line
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/facebook.jpg',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 20),
                    Image.asset(
                      'assets/images/insta.jpg',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 20),
                    Image.asset(
                      'assets/images/tweeter.jpg',
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
