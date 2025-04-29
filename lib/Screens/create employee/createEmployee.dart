import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: CreateEmployee()));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class CreateEmployee extends StatefulWidget {
  @override
  CreateEmpState createState() => CreateEmpState();
}

class CreateEmpState extends State<CreateEmployee> {
  String comName = 'Compamy';

  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);

      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        print(comName);
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController name = TextEditingController();
  final TextEditingController age = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController panNo = TextEditingController();
  final TextEditingController password = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void createEmp() async {
    if (_formKey.currentState?.validate() ?? false) {
      String EmpName = name.text;
      String EmpAge = age.text;
      String EmpDob = dob.text;
      String EmpPassword = password.text;
      String EmpEmail = email.text;
      String EmpPanNo = panNo.text;
      String EmpMobile = mobile.text;
      String EmapAddress = address.text;
      String EmpUser = username.text;

      if (_imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a profile image")),
        );
        return;
      }
      File imageFile = File(_imageFile!.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      try {
        final url = Uri.parse(
          'https://testapi.rabadtechnology.com/create_employees.php',
        );
        final Map<String, dynamic> requestBody = {
          "company_name": comName,
          "name": EmpName,
          "age": EmpAge,
          "dob": EmpDob,
          "pan_card": EmpPanNo,
          "mobile_no": EmpMobile,
          "email": EmpEmail,
          "address": EmapAddress,
          "username": EmpUser,
          "password": EmpPassword,
          "image": base64Image,
        };

        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        print("success");
        final responseData = jsonDecode(response.body);
        bool success = responseData['success'];
        String message = responseData['message'];
        print(success);
        print(message);
        print(requestBody);
        print(base64Image);
        if (success == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong: ${e.toString()}")),
        );
      }
    }
  }

  void UploadImg() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Profile Image'),
          content: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImageFromCamera(),
                  child: Row(
                    children: [
                      Text(
                        "Take Profile Picture",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.photo_camera, color: Colors.black),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _pickImageFromGallery(),
                  child: Row(
                    children: [
                      Text(
                        "Upload From Gallery",
                        style: TextStyle(fontSize: 15, color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.photo, color: Colors.black),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.black)),
            ),
          ],
          backgroundColor: Colors.grey[300],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Create Employee',
          style: TextStyle(
            color: Colors.white,
            fontSize:  8 * MediaQuery.of(context).devicePixelRatio,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.07,
          right: MediaQuery.of(context).size.width * 0.07,
          bottom: 0,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                _imageFile != null
                    ? CircleAvatar(
                      radius:
                          MediaQuery.of(context).size.width * 0.18, // Size of the avatar, this is half the diameter
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
                  onPressed: () => UploadImg(),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.37,
                    child: Row(
                      children: [
                        Text(
                          "Profile Picture",
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.edit, color: Colors.black),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: name,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Name',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
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
                      return 'Enter Your Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: age,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Age',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.calendar_today),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Age';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: dob,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Date Of Birth',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.date_range),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Date Of Birth';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 10),
                TextFormField(
                  controller: mobile,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Mobile No.',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.phone),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Mobile No.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Email',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.email),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: panNo,
                  decoration: InputDecoration(
                    labelText: 'Enter Your PAN Card No.',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.credit_card),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your PAN Card No.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),

                TextFormField(
                  controller: address,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Address',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.home),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: username,
                  decoration: InputDecoration(
                    labelText: 'Enter Your User Name',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
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
                      return 'Enter Your User Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: password,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Password',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.lock),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => createEmp(),
                  child: Text(
                    "Create Employee",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
