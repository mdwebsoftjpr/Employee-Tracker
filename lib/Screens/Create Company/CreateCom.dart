import 'dart:convert';
import 'package:employee_tracker/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(CreateCom());
}

class CreateCom extends StatefulWidget {
  @override
  CreateComState createState() => CreateComState();
}

class CreateComState extends State<CreateCom> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool TermCondition = false;
  bool privacyPolicy = false;
  bool _obscureText = true;
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
  final TextEditingController NoOfEmp = TextEditingController();

  // Image picking function
  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      print('$TermCondition,$privacyPolicy');
    }
  }

  // Submit the form and send data to the API
  void compLogin(context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!TermCondition) {
        // Show an error message if checkbox is not checked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please accept the terms and conditions.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the function without proceeding further
      } else if (!privacyPolicy) {
        // Show an error message if checkbox is not checked
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please accept Privacy And Policy.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Exit the function without proceeding further
      }

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
      String EmpNo = NoOfEmp.text;

      // Check if an image has been selected
      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No image selected.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final url = Uri.parse('https://testapi.rabadtechnology.com/create.php');
      var request = http.MultipartRequest('POST', url);

      // Add the other form fields as part of the body
      request.fields['company_name'] = ComName;
      request.fields['trade_name'] = Ctradename;
      request.fields['key_person'] = CkeyPerson;
      request.fields['gstin_no'] = GSTIN;
      request.fields['pan_card'] = CPanNo;
      request.fields['mobile_no'] = Cmobile;
      request.fields['email'] = Cemail;
      request.fields['address'] = Caddress;
      request.fields['website_link'] = Cwebsite;
      request.fields['username'] = CloginUserName;
      request.fields['password'] = Cpassword;
      request.fields['noofemp'] = EmpNo;
      request.fields['terms'] = TermCondition.toString();
      request.fields['conditions'] = privacyPolicy.toString();
      // Add the image as a multipart file
      var image = await http.MultipartFile.fromPath(
        'image', // The field name expected by your API (change this to match your API's expected field name)
        _imageFile!.path,
      );
      request.files.add(image);

      try {
        // Send the request
        var response = await request.send();
        final responseBody = await http.Response.fromStream(response);

        final Map<String, dynamic> responseData = jsonDecode(responseBody.body);
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
        ).showSnackBar(SnackBar(content: Text("Something went wrong")));
      }
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
            fontSize: 8 * MediaQuery.of(context).devicePixelRatio,
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
                  SizedBox(height: 20),
                  _imageFile != null
                      ? CircleAvatar(
                        radius:
                            MediaQuery.of(context).size.width *
                            0.18, // Size of the avatar, this is half the diameter
                        backgroundImage: FileImage(
                          File(_imageFile!.path),
                        ), // If you are using an image
                        backgroundColor:
                            Colors
                                .grey, // Background color if no image is provided
                      )
                      : Container(
                        width: MediaQuery.of(context).size.width * 0.32,
                        height: MediaQuery.of(context).size.width * 0.32,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                  ElevatedButton(
                    onPressed: () => _pickImageFromGallery(),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.51,
                      child: Row(
                        children: [
                          Text(
                            "Upload Company Logo",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.edit, color: Colors.black),
                        ],
                      ),
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
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
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

                        // Make sure this is imported
                        TextFormField(
                          controller: Tradename,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Enter your 10 Digit Id',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.apartment),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter your 10 Digit Id';
                            } else if (value.length < 6 || value.length > 15) {
                              return 'ID must be 6 to 15 characters';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),
                        TextFormField(
                          controller: keyPerson,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Key Person',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
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
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.account_balance),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ID must be Greater Then And Equal To 15 characters';
                            } else if (value.length >= 15) {
                              return 'ID must be Greater Then And Equal To 15 characters';
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
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 5.0,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        5 *
                                        MediaQuery.of(context).devicePixelRatio,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10.0,
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
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 5.0,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        5 *
                                        MediaQuery.of(context).devicePixelRatio,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10.0,
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
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0,
                                    horizontal: 5.0,
                                  ),
                                  labelStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        5 *
                                        MediaQuery.of(context).devicePixelRatio,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      10.0,
                                    ), // Set the border radius
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[200],
                                  prefixIcon: Icon(Icons.email),
                                ),

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter Your Email';
                                  } else if (!value.contains('@')) {
                                    return 'Email must contain @';
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
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
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
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.web),
                          ),
                        ),
                        SizedBox(height: 10), SizedBox(height: 10),
                        TextFormField(
                          controller: NoOfEmp,
                          decoration: InputDecoration(
                            labelText: 'Enter No. Of Employee',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.lock),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 10), SizedBox(height: 10),
                        TextFormField(
                          controller: loginUserName,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Enter Your Login User Name',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
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
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Enter Your Password',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                              horizontal:
                                  4 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  5 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                4 * MediaQuery.of(context).devicePixelRatio,
                              ),
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
                              return 'Enter Your Password';
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
                            Text(
                              "I accept",
                              style: TextStyle(color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () => print("term Com"),
                              child: Text("Term And Condition"),
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
