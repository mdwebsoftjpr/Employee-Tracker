import 'dart:convert';
import 'package:employee_tracker/Api/firebase.dart';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:employee_tracker/Screens/Home%20Screen/EmpHome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'Screens/Create Company/CreateCom.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show TextInput;
import 'SpleshScreen.dart';import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Correct Firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseService().initNotification();
  await _initializeLocalStorage();

  String? user = localStorage.getItem("user");
  String? role = localStorage.getItem("role");

  role = role?.replaceAll('"', '').trim().toLowerCase();

  Widget homeScreen;

  if (user != null && user != '') {
    if (role == 'admin') {
      homeScreen = AdminHome();
    } else if (role == 'employee') {
      homeScreen = EmpHome();
    } else {
      homeScreen = CreateScreen();
    }
  } else {
    homeScreen = CreateScreen();
  }

  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // or homeScreen if you want logic-based route
    ),
  );
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
  bool TermCondition = false;
  String msg = 'msg';
  String user = 'Demo';

  final _formKey = GlobalKey<FormState>();
  final TextEditingController tradename = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    var storedUser = await localStorage.getItem('user');
    if (!mounted) return;
    setState(() {
      user = storedUser != null ? jsonDecode(storedUser) : '';
    });
  }

  void login(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!TermCondition) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String tradeNameValue = tradename.text.trim();
    final String emailValue = email.text.trim();
    final String passwordValue = password.text.trim();

    final url = Uri.parse('https://testapi.rabadtechnology.com/login.php');
    final Map<String, dynamic> requestBody = {
      "trade_name": tradeNameValue,
      "email": emailValue,
      "password": passwordValue,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['success'] == true) {
        final role = responseData['role']?.toString()?.toLowerCase();
        final userData = responseData['data'];

        await localStorage.setItem('user', jsonEncode(userData));
        await localStorage.setItem('role', jsonEncode(role));

        // Finish autofill context
        TextInput.finishAutofillContext();

        if (role == "admin") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminHome()),
            (route) => false,
          );
          Alert.alert(context, responseData['message'] ?? 'Login successful');
        } else if (role == "employee") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => EmpHome()),
            (route) => false,
          );
          Alert.alert(context, responseData['message'] ?? 'Login successful');
        } else {
          Alert.alert(context, 'Unknown user role');
        }
      } else {
        Alert.alert(context, responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      Alert.alert(context, 'Something went wrong: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/splesh_Screen/Emp_Attend.png',
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
                    "Hello Let's get Started",
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
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Reg. Company 10 Digit Id',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.business),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Company ID';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: [AutofillHints.username],
                          controller: email,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Your User Id/Email',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          obscureText: _obscureText,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: [AutofillHints.password],
                          controller: password,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
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
                              return 'Enter your password';
                            }
                            return null;
                          },
                        ),
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
                              onPressed: () => {},
                              child: Text(
                                "I Remember",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => login(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            padding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Don't Have Company?",
                                style: TextStyle(color: Colors.black)),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => CreateCom()),
                              ),
                              child: Text("Create Company"),
                            ),
                          ],
                        ),
                        Divider(height: 30),
                        Text("Follow on", style: TextStyle(fontSize: 16)),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/facebook.jpg',
                                width: 30, height: 30),
                            SizedBox(width: 20),
                            Image.asset('assets/images/insta.jpg',
                                width: 30, height: 30),
                            SizedBox(width: 20),
                            Image.asset('assets/images/tweeter.jpg',
                                width: 30, height: 30),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
