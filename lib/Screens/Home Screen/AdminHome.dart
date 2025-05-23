import 'dart:async';
import 'package:employee_tracker/Screens/Admin%20Report/Attendance.dart';
import 'package:employee_tracker/Screens/Admin%20Report/VisitReport.dart';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Employee%20Reports/employeeList.dart';
import 'package:employee_tracker/Screens/Profile%20Scree/adminProfile.dart';
import 'package:employee_tracker/Screens/create%20employee/Master.dart';
import 'package:employee_tracker/Screens/create%20employee/createEmployee.dart';
import 'package:employee_tracker/main.dart';
import 'package:intl/intl.dart';
// #docregion photo-picker-example
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
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
  String key_person = "";
  String email = "";
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
        email = user['db_email'] ?? 'Default User';
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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminHome()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Attendance()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdminVisitreport()),
      );
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
      await Alert.alert(context, "Successfully LogOut");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateScreen()),
      );
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

  void _openDropdown(TapDownDetails details) async {
    final selectedItem = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'Profile',
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.black54,
              ), // You can change icon and color
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),

        PopupMenuItem(
          value: 'Logout',
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.black54,
              ), // You can change icon and color
              SizedBox(width: 8),
              Text('Logout'),
            ],
          ),
        ),
      ],
    );

    if (selectedItem == 'Profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Adminprofile()),
      );
    } else if (selectedItem == 'Logout') {
      clearStorage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4), // Custom AppBar background
        elevation: 4,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu), // Change this to your preferred icon
                color: Colors.white, // Set custom icon color
                onPressed: () {
                  Scaffold.of(context).openDrawer(); // Open the drawer
                },
              ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                comName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTapDown: _openDropdown,
              child: Container(
                margin: EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white70, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                      (image != null && image.isNotEmpty)
                          ? Image.network(
                            'https://testapi.rabadtechnology.com/$image',
                            width: MediaQuery.of(context).size.width * 0.10,
                            height: MediaQuery.of(context).size.width * 0.10,
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.account_circle,
                            size: 36,
                            color: Colors.white,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: ListView(
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 62 * MediaQuery.of(context).devicePixelRatio,
                    decoration: BoxDecoration(color: Color(0xFF03a9f4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(
                            4 * MediaQuery.of(context).devicePixelRatio,
                          ),
                          child: Image.network(
                            'https://testapi.rabadtechnology.com/$image',
                            width: 30 * MediaQuery.of(context).devicePixelRatio,
                            height:
                                26 * MediaQuery.of(context).devicePixelRatio,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          comName,
                          style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          email,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Activity",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 6 * MediaQuery.of(context).devicePixelRatio,
                      ),
                    ),
                  ),
                  SizedBox(height:1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.fact_check,size: 8 * MediaQuery.of(context).devicePixelRatio,),
                    title: Text("Attendance Report",style: TextStyle(fontSize: 5 * MediaQuery.of(context).devicePixelRatio),),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Attendance()),
                      );
                    },
                  ),
                  SizedBox(height:1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.receipt_long,size: 8 * MediaQuery.of(context).devicePixelRatio,),
                    title: Text("Visit Report",style: TextStyle(fontSize: 5 * MediaQuery.of(context).devicePixelRatio),),
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
                  SizedBox(height:1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.people_alt,size: 8 * MediaQuery.of(context).devicePixelRatio,),
                    title: Text("Create Employee",style: TextStyle(fontSize: 5 * MediaQuery.of(context).devicePixelRatio),),
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
                  SizedBox(height:1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.person_add_alt_1,size: 8 * MediaQuery.of(context).devicePixelRatio,),
                    title: Text("Create Designation",style: TextStyle(fontSize: 5 * MediaQuery.of(context).devicePixelRatio),),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Master()),
                      );
                    },
                  ),
                  SizedBox(height:1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.person,size: 8 * MediaQuery.of(context).devicePixelRatio,),
                    title: Text("Profile",style: TextStyle(fontSize: 5 * MediaQuery.of(context).devicePixelRatio),),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Adminprofile()),
                      );
                    },
                  ),
                  SizedBox(height:1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.logout,size: 8 * MediaQuery.of(context).devicePixelRatio,),
                    title: Text("Logout",style: TextStyle(fontSize: 5 * MediaQuery.of(context).devicePixelRatio),),
                    onTap: () {
                      clearStorage(context);
                    },
                  ),
                 SizedBox(height:.020* MediaQuery.of(context).size.height),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: InkWell(
                      onTap: () async {
                        const url = 'https://www.mdwebsoft.com/';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Copy Rights',
                            style: TextStyle(
                              fontSize: 4 * MediaQuery.of(context).devicePixelRatio,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.copyright,
                                size: 16,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 1 * MediaQuery.of(context).devicePixelRatio),
                              Text(
                                '2025 $comName',
                                style: TextStyle(
                                  fontSize: 4 * MediaQuery.of(context).devicePixelRatio,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: InkWell(
                      onTap: () async {
                        const url = 'https://www.mdwebsoft.com/';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(
                            'Maintain And Dev. By Md Websoft',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: InkWell(
                      onTap: () async {
                        const url = 'https://www.mdwebsoft.com/';
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        } else {
                          throw 'Could not launch $url';
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'About Us',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.add_photo_alternate_rounded),
            label: 'Att. Detail',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Visit Rep',
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
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 6,
                            offset: Offset(0, 3), // changes position of shadow
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
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width *
                                        0.03,
                                  ),
                                  Container(
                                    width:
                                        25 *
                                        MediaQuery.of(context).devicePixelRatio,
                                    height:
                                        25 *
                                        MediaQuery.of(context).devicePixelRatio,
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        softWrap: true,
                                        overflow:
                                            TextOverflow
                                                .visible, // or TextOverflow.ellipsis
                                        maxLines: null, // allow multiple lines
                                      ),
                                      Text(
                                        key_person,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                        ],
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
                                "Att. Report",
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
                                "Visit Report",
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
                                "Add Employee",
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
                                "Designation",
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
