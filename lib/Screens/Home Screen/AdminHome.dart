import 'dart:async';
import 'dart:io'; // This is required to use the File class
import 'package:employee_tracker/Screens/Admin%20Report/Attendance.dart';
import 'package:employee_tracker/Screens/Admin%20Report/VisitRepMap.dart';
import 'package:employee_tracker/Screens/Admin%20Report/VisitReport.dart';
import 'package:employee_tracker/Screens/Detail%20Screen/employeeList.dart';
import 'package:employee_tracker/Screens/Profile%20Scree/adminProfile.dart';
import 'package:employee_tracker/Screens/create%20employee/Master.dart';
import 'package:employee_tracker/Screens/create%20employee/createEmployee.dart';
import 'package:employee_tracker/main.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
// #docregion photo-picker-example
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(AdminHome());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class AdminHome extends StatefulWidget {
  @override
  AdminhomeState createState() => AdminhomeState();
}

class AdminhomeState extends State<AdminHome> {
  int _selectedIndex = 0;
  bool drop = false;
  String key_person = "key_person";
  String comName = 'Compamy';
  String image = '';
  bool visit = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      print(user);
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        key_person = user['key_person'] ?? 'Default User';
        image = user['image'] ?? 'Default User';
      });
      print(image);
    }
    var Visit = localStorage.getItem('visitout') ?? false;
    if (Visit == true) {
      setState(() {
        visit:
        Visit;
        print(Visit);
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }

    print("addSds$ImageSource");
  }

  // Notification method to navigate to Notification screen
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Perform actions based on the selected index
    if (index == 0) {
      print('Search tab tapped');
    } else if (index == 1) {
      // Search Tab
      print('Search tab tapped');
    } else if (index == 2) {
      // Notifications Tab
      print('Search tab tapped');
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Adminprofile()),
      );
    }
  }

  String? _selectedValue;

  // List of options for the dropdown
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];

  String currentDate = DateFormat(
    'dd-MM-yyyy',
  ).format(DateTime.now()); // Make sure this is defined in your state

  void dropdown() {
    print("Down");
    setState(() {
      drop = false;
    });
  }

  void clearStorage(context) async {
    try {
      await localStorage.clear();
      print('LocalStorage has been cleared!');
      _showAlert();
    } catch (e) {
      print('Error clearing local storage: $e');
    }
  }

  void dropUp() {
    print("UP");
    setState(() {
      drop = true;
    });
  }

  // This is the value that will hold the selected item
  String _selectedItem = 'One';

  void _openDropdown() async {
    final selectedItem = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Action'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Column(
                  children: [
                    TextButton(
                      onPressed:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminHome(),
                            ),
                          ),
                      child: Text(
                        "Home",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () => clearStorage(context),
                      child: Text(
                        "Logout",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedItem != null) {
      setState(() {
        _selectedItem = selectedItem;
      });
    }
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Icon(
            Icons.check_circle_outline_outlined,
            color: Colors.lightBlue,
            size: 70,
          ),
          content: Text("You are successfully LogOut"),
          actions: [
            TextButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateScreen()),
                  ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color(0xFF03a9f4),
                ),
                padding: EdgeInsets.only(
                  top: 2 * MediaQuery.of(context).devicePixelRatio,
                  left: 5 * MediaQuery.of(context).devicePixelRatio,
                  right: 4 * MediaQuery.of(context).devicePixelRatio,
                  bottom: 2 * MediaQuery.of(context).devicePixelRatio,
                ),
                child: Text(
                  "OK, got it!",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(child: Text(comName)),
            SizedBox(width: 10),
            Container(
              child: Align(
                alignment:
                    Alignment
                        .centerRight, // Align the second Expanded to the end
                child: TextButton(
                  onPressed:
                      _openDropdown, // Call the function when button is pressed
                  child: Icon(Icons.logout, size: 30, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Color(0xFF03a9f4),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          children: <Widget>[
            Container(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(
                        0xFF03a9f4,
                      ), // Background color for the entire drawer
                    ),
                    accountName: Text(
                      key_person,
                      style: TextStyle(color: Colors.black),
                    ),
                    accountEmail: Text(
                      key_person,
                      style: TextStyle(color: Colors.black),
                    ),
                    currentAccountPicture: Container(
                      margin: EdgeInsets.only(
                        top: 10,
                        bottom: 0,
                        left: 10,
                        right: 10,
                      ),
                      child:
                          _imageFile != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  20,
                                ), // Apply border radius to the image
                                child: Image.file(
                                  File(
                                    _imageFile!.path,
                                  ), // Convert XFile to File
                                  width: 70,
                                  height: 70,
                                  fit:
                                      BoxFit
                                          .cover, // Optional: Adjust how the image fits inside the container
                                ),
                              )
                              : Text(" "),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Activity",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/Att  Report.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    title: Text("Attendance Report"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Attendance()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/visit_report.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    title: Text("Visit Time Report"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminVisitreport(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/addEmp.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    title: Text("Create Employee"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateEmployee(),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: Image.asset(
                      'assets/images/Designation.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    title: Text("Create Designation"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Master()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Image.asset(
                      'assets/images/logout.png',
                      width: MediaQuery.of(context).size.width * 0.1,
                      height: MediaQuery.of(context).size.width * 0.1,
                    ),
                    title: Text("Logout"),
                    onTap: () {
                      clearStorage(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF03a9f4),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: 0,
                      bottom: 10,
                      right: 10,
                      left: 10,
                    ),
                    width: double.infinity,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width:
                                          25 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      height:
                                          25 *
                                          MediaQuery.of(
                                            context,
                                          ).devicePixelRatio,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          4 *
                                              MediaQuery.of(
                                                context,
                                              ).devicePixelRatio,
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            'https://testapi.rabadtechnology.com/$image',
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      key_person,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            /*  Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.85,
                                    margin: EdgeInsets.only(bottom: 5),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            drop
                                                ? TextButton(
                                                  onPressed: () => dropdown(),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        '#@Today Report: $currentDate',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_drop_up,
                                                        size: 15,
                                                      ),
                                                    ],
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    iconColor: Colors.black,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                )
                                                : TextButton(
                                                  onPressed: () => dropUp(),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Today Report: $currentDate',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_drop_down,
                                                        size: 15,
                                                      ),
                                                    ],
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    iconColor: Colors.black,
                                                    backgroundColor:
                                                        Colors.white,
                                                  ),
                                                ),
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child:
                                              drop
                                                  ? Column(
                                                    children: [
                                                      Container(
                                                        height: 30,
                                                        color: Colors.black,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Text(
                                                              "View",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Attendance",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              "In",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Out",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            TextButton(
                                                              onPressed:
                                                                  () => print(
                                                                    "Row",
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .remove_red_eye,
                                                                size: 30,
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () => print(
                                                                    "Row",
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .remove_red_eye,
                                                                size: 30,
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () => print(
                                                                    "Row",
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .remove_red_eye,
                                                                size: 30,
                                                              ),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () => print(
                                                                    "Row",
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .remove_red_eye,
                                                                size: 30,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                  : Text(""),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5), */
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Attendance(),
                              ),
                            ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Attendance Report",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/Att  Report.png',
                                width: MediaQuery.of(context).size.width * 0.4,
                                height: MediaQuery.of(context).size.width * 0.3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminVisitreport(),
                              ),
                            ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Visit Time Report",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/visit_report.png',
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.width * 0.3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Optional: Adds rounded corners
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateEmployee(),
                              ),
                            ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Create/Add Employee",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/addEmp.png',
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.width * 0.3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Master()),
                            ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Create Designation",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/Designation.png',
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.width * 0.3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Optional: Adds rounded corners
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Employeelist(),
                              ),
                            ),
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 6,
                                offset: Offset(
                                  0,
                                  3,
                                ), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "View Employee",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/empList.png',
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: MediaQuery.of(context).size.width * 0.3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
