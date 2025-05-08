import 'dart:convert';
/* import 'package:employee_tracker/Screens/Forget%20Password/ForgetPass.dart'; */
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:employee_tracker/Screens/Home%20Screen/EmpHome.dart';
import 'Screens/Create Company/CreateCom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();

  String? user = localStorage.getItem("user");
  String? role = localStorage.getItem("role");

  role = role?.toString().replaceAll('"', '').trim().toLowerCase();

  Widget homeScreen;

  if (user != null && user != '') {
    if (role == 'admin') {
      homeScreen = AdminHome();
    } else if (role == 'employee') {
      homeScreen = EmpHome();
    } else {
      homeScreen = CreateScreen(); // fallback if role is unknown
    }
  } else {
    homeScreen = CreateScreen(); // if user is not found
  }

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: homeScreen));
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
  bool _obscureText = true;
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
  String msg = 'msg';
  String user = 'Demo';
  final _formKey = GlobalKey<FormState>();
  final TextEditingController tradename = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  void login(BuildContext context) async {
  if (_formKey.currentState?.validate() ?? false) {
    if (!TermCondition) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String Tradename = tradename.text;
    String Email = email.text;
    String Cpassword = password.text;

    final url = Uri.parse('https://testapi.rabadtechnology.com/login.php');
    final Map<String, dynamic> requestBody = {
      "trade_name": Tradename,
      "email": Email,
      "password": Cpassword,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      final success = responseData['success'];
      final message = responseData['message'];
      final role = responseData['role'];
      final data = responseData['data'];

      if (success == true) {
        await localStorage.setItem('user', jsonEncode(data));
        await localStorage.setItem('role', jsonEncode(role));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );

        if (role.toString().toLowerCase() == "admin") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminHome()),
            (route) => false,
          );
        } else if (role.toString().toLowerCase() == "employee") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => EmpHome()),
            (route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: ${e.toString()}')),
      );
    }
  }
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
                        controller: tradename,
                        inputFormatters: [
                            FilteringTextInputFormatter.deny(
                              RegExp(r'\s'),
                            ), 
                          ],
                        decoration: InputDecoration(
                          labelText: 'Reg. Company 10 Digit Id',
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
                            return 'Reg. Company 10 Digit Id';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          labelText: 'Your User Id',
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
                            return 'Your User Id';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      // Password field
                      TextFormField(
                        controller: password,
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                          labelText: 'Your Password',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Your Password';
                          }
                          return null;
                        },
                      ),
                      /* TextButton(onPressed: ()=>Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgetPassword())), child: Text("Forget Password")), */
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
                          TextButton(
                            onPressed: () => print("term Com"),
                            child: Text(
                              "I Remember",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      /*  Row(
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
                      ), */
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
                          'Login',
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
                              MainAxisAlignment.center, // Cthe Row content
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
