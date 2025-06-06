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
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        key_person = user['key_person'] ?? 'Default User';
        email = user['db_email'] ?? 'Default User';
        image = user['image'] ?? 'Default User';
      });
    }
    var Visit = localStorage.getItem('visitout') ?? false;
    if (Visit == true) {
      setState(() {
        visit:
        Visit;
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
    setState(() {
      drop = false;
    });
  }

  void clearStorage(context) async {
    try {
      await localStorage.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CreateScreen()),
        (route) => false,
      );
    } catch (e) {
    }
  }

  void dropUp() {
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
      LogOutAlert(context);
    }
  }

  Future<void> LogOutAlert(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'EmpAttend',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(
            "Are you sure you want to Logout?",
            textAlign: TextAlign.center,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                clearStorage(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03A9F4),
                foregroundColor: Colors.white,
              ),
              child: Text('LogOut'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
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
                  fontSize: ratio * 9,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(onPressed: ()=>Alert.alert(context, "Comming Soon..."), icon: Icon(Icons.notifications,size: ratio*15,color: Colors.white,)),
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
                           width: ratio * 18,
                            height:  ratio * 18,
                            fit: BoxFit.cover,
                          )
                          : Icon(
                            Icons.account_circle,
                            size: deviceWidth * 0.10,
                            color: Colors.white,
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        width: deviceWidth * 0.6,
        child: ListView(
          children: <Widget>[
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: ratio*85,
                    decoration: BoxDecoration(color: Color(0xFF03a9f4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ratio * 5),
                          child: Image.network(
                            'https://testapi.rabadtechnology.com/$image',
                            width: ratio * 80,
                            height: ratio * 40,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          comName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ratio * 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ratio * 7,
                          ),
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
                        fontSize: ratio * 8,
                      ),
                    ),
                  ),
                  SizedBox(height: 1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.fact_check, size: ratio * 10),
                    title: Text(
                      "Attendance Report",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Attendance()),
                      );
                    },
                  ),
                  SizedBox(height: 1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.receipt_long, size: ratio * 10),
                    title: Text(
                      "Visit Report",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
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
                  SizedBox(height: ratio*1),
                  ListTile(
                    leading: Icon(Icons.people_alt, size: ratio * 10),
                    title: Text(
                      "Create Employee",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
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
                  SizedBox(height: 1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.person_add_alt_1, size: ratio * 10),
                    title: Text(
                      "Create Designation",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Master()),
                      );
                    },
                  ),
                  SizedBox(height: 1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.person, size: ratio * 10),
                    title: Text(
                      "Profile",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Adminprofile()),
                      );
                    },
                  ),
                  SizedBox(height: 1 * MediaQuery.of(context).devicePixelRatio),
                  ListTile(
                    leading: Icon(Icons.logout, size: ratio * 10),
                    title: Text(
                      "Logout",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
                    onTap: () {
                      LogOutAlert(context);
                    },
                  ),
                  SizedBox(height: .015 * deviceHeight),
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
                              fontSize: ratio * 5,
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
                                size: ratio * 7,
                                color: Colors.grey,
                              ),
                              SizedBox(
                                width:
                                    1 * MediaQuery.of(context).devicePixelRatio,
                              ),
                              Text(
                                '2025 $comName',
                                style: TextStyle(
                                  fontSize: ratio * 5,
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
                              fontSize: ratio * 5,
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
                              fontSize: ratio * 5,
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
                      bottom: ratio * 1,
                      right: ratio * 5,
                      left: ratio * 5,
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
                      width: deviceWidth * 0.9,
                      child: Column(
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(width: deviceWidth * 0.03),
                                  Container(
                                    width: ratio * 50,
                                    height: ratio * 30,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        ratio * 5,
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
                                          fontSize: ratio * 7,
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
                                          fontSize: ratio * 7,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: ratio * 6,
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
                width: deviceWidth * 0.9,
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
                                  fontSize: ratio * 7,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/Att  Report.png',
                                width: deviceWidth * 0.4,
                                height: deviceWidth * 0.3,
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
                                  fontSize: ratio * 7,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/visit_report.png',
                                width: deviceWidth * 0.6,
                                height: deviceWidth * 0.3,
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
                width: deviceWidth * 0.9,
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
                                  fontSize: ratio * 7,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/addEmp.png',
                                width: deviceWidth * 0.6,
                                height: deviceWidth * 0.3,
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
                                  fontSize: ratio * 7,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/Designation.png',
                                width: deviceWidth * 0.6,
                                height: deviceWidth * 0.3,
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
                width: deviceWidth * 0.9,
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
                                  fontSize: ratio * 7,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/empList.png',
                                width: deviceWidth * 0.6,
                                height: deviceWidth * 0.3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                   /*  Expanded(
                      child: TextButton(
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageMatchWithReference(),
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
                                "Emp Scanner",
                                style: TextStyle(
                                  fontSize: ratio * 7,
                                  color: Colors.black,
                                ),
                              ),
                              Image.asset(
                                'assets/images/faceScanner.jpg',
                                width: deviceWidth * 0.6,
                                height: deviceWidth * 0.3,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ), */
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
