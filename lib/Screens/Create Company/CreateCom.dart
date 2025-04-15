import 'dart:convert';
import 'package:employee_tracker/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

void main() {
  runApp(CreateCom());
}

class CreateCom extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController cname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController Gst = TextEditingController();
  final TextEditingController Tradename = TextEditingController();
  final TextEditingController keyPerson = TextEditingController();
  final TextEditingController loginUserName = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController PanNo = TextEditingController();

  void compLogin(context) async {
    if (_formKey.currentState?.validate() ?? false) {
      String ComName = cname.text;
      String Cemail = email.text;
      String Cmobile = mobile.text;
      String Cpassword = password.text;
      String Caddress = address.text;
      String GSTIN = Gst.text;
      String Ctradename = Tradename.text;
      String CkeyPerson = keyPerson.text;
      String CloginUserName = loginUserName.text;
      String Cwebsite = website.text;
      String CPanNo = PanNo.text;
      final url = Uri.parse('http://192.168.29.249/emptrack/users');
      final Map<String, dynamic> requestBody = {
        "cname": ComName,
        "tradname": Ctradename,
        "keyperson": CkeyPerson,
        "gstIn": GSTIN,
        "panNo": CPanNo,
        "mobile": Cmobile,
        "email": Cemail,
        "address": Caddress,
        "weblink": Cwebsite,
        "loginUser": CloginUserName,
        "password": Cpassword,
      };
      try {
        final response = await http.post(
          url, // Replace this with your endpoint
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          var success = responseData['success'];
          var message = responseData['message'];
          if (success == true) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
             Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateScreen()),
          );
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        
      } catch (e) {
        ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text("Somthing Wants Wrong")));
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateScreen()),
      );
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        elevation: 0,
        title: Text(
          'Create Company',
          style: TextStyle(
            color: Color.fromARGB(255, 254, 255, 255),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Image.asset('assets/LogoMain.jpg', width: 150, height: 150),
                  Text(
                    "Create Your Company",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: cname,
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
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Your Company Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: Tradename,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Trad Name',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                30.0,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.apartment),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Your Trad Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: keyPerson,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Key Person',
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
                              return 'Enter Your Key Person';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: Gst,
                          decoration: InputDecoration(
                            labelText: 'Enter Your GSTIN No.',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                30.0,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.account_balance),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Your GSTIN No.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextFormField(
                                controller: PanNo,
                                decoration: InputDecoration(
                                  labelText: 'Enter Your Pan Card No.',
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      30.0,
                                    ), // Set the border radius
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: Icon(Icons.credit_card),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter Your Pan Card No.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                ),
                                onPressed: () => print('Verify'),
                                child: Text(
                                  "verify",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ), // Width is fixed here, not influenced by the flex
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextFormField(
                                controller: mobile,
                                decoration: InputDecoration(
                                  labelText: 'Enter Your Mobile No.',
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      30.0,
                                    ), // Set the border radius
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: Icon(Icons.mobile_friendly),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter Your Mobile No.';
                                  } else if (value.length != 10) {
                                    return 'Mobile number must be 10 digits';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                ),
                                onPressed: () => print('Verify'),
                                child: Text(
                                  "verify",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ), // Width is fixedhere, not influenced by the flex
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: TextFormField(
                                controller: email,
                                decoration: InputDecoration(
                                  labelText: 'Enter Your Email.',
                                  labelStyle: TextStyle(color: Colors.black),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      30.0,
                                    ), // Set the border radius
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: Icon(Icons.email),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter Your Email';
                                  } else if (!value.endsWith('@gmail.com')) {
                                    return 'Email must end with @gmail.com';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 5),
                            Container(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                ),
                                onPressed: () => print('Verify'),
                                child: Text(
                                  "verify",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ), // Width is fixedxed here, not influenced by the flex
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: address,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Company Address.',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                30.0,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.location_on),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Your Company Address';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),
                        TextFormField(
                          controller: website,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Website Link',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                30.0,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.web),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Your Website Link';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: loginUserName,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Login User Name',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                30.0,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.account_circle),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Your Login User Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
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
                            prefixIcon: Icon(Icons.password),
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
                        // Submit button
                        ElevatedButton(
                          onPressed: () => compLogin(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF03a9f4),
                            padding: EdgeInsets.only(
                              top: 5,
                              bottom: 5,
                              left: 10,
                              right: 10,
                            ),
                            maximumSize: Size(150, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: Text(
                            'Create Company',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
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
