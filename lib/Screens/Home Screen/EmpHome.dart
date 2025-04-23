import 'dart:async';
import 'dart:io'; 
import 'package:employee_tracker/Screens/EmployeeReports/visitReport.dart';
import 'package:employee_tracker/Screens/Profile%20Scree/empProfile.dart';
import 'package:employee_tracker/Screens/EmployeeReports/AttendanceRep.dart';
import 'package:employee_tracker/Screens/VisitOut%20Screen/VisitOut.dart';
import 'package:employee_tracker/main.dart';
import 'package:intl/intl.dart';
// #docregion photo-picker-example
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(EmpHome());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class EmpHome extends StatefulWidget {
  @override
  _EmpHomeState createState() => _EmpHomeState();
}

class _EmpHomeState extends State<EmpHome> {
  int _selectedIndex = 0;
  bool drop = false;
  String name = "key_person";
  String comName = 'Compamy';
  String username="";
  String role = '';
  bool visit = false;
  bool punch = false;
  String startTime= '';
  String endtime='';
  int pcount=0;
  int bcount=0;
  bool BreakTime=false;


  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  void initState() {
    super.initState();
    _loadUser();
    loadAddress();
    checkAutoPunchOut();
  }

  void checkAutoPunchOut() {
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day, 24, 0); // 12 aM

  if (now.isAfter(endOfDay)) {
    // Auto punch out
    punchOut();
    setState(() {
      pcount=0;
    });
  }
}

  void loadAddress() async {
    await getCurrentLocation();
    await fetchAndPrintAddress();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);

      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        name = user['name'] ?? 'Default User';
        username = user['username'] ?? 'Default User';
        role = localStorage.getItem('role');
      });
    }
    var Visit = localStorage.getItem('visitout') ?? false;
    if (Visit == true) {
      setState(() {
        visit = Visit;
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
        MaterialPageRoute(builder: (context) => Empprofile()),
      );
    }
  }

  String? _selectedValue;

  // List of options for the dropdown
  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];

  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  void dropdown() {
    print("Down");
    setState(() {
      drop = false;
    });
  }


  void BreakIn(){
    setState(() {
      BreakTime=true;
      bcount++;
      print(bcount);
    });
  }

    void BreakOut(){
    setState(() {
      BreakTime=false;
      print(BreakTime);
    });
  }

  void punchIn() async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/employee_attendence.php',
    );
  String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    try {
      final Map<String, dynamic> requestBody = {
        "company_name": comName,
        "name": name,
        "time": currentTime,
        "date": currentDate,
        "latitude": latitude,
        "longitude": longitude,
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      var success = responseData['success'];
      var message = responseData['message'];
      if (success == true) {
        setState(() {
          punch = true;
          startTime=currentTime;
          pcount++;
          print(pcount);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
  }

  void punchOut() async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/employee_attendence_out.php',
    );
  String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    try {
      final Map<String, dynamic> requestBody = {
        "company_name": comName,
        "name": name,
        "time": currentTime,
        "date": currentDate,
        "latitude": latitude,
        "longitude": longitude,
      };
      final response = await http.post(
        url, // Replace this with your endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      var success = responseData['success'];
      var message = responseData['message'];
      if (success == true) {
        setState(() {
          punch = false;
          endtime=currentTime;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
  }

  void visitIn() async {
    final url = Uri.parse('https://testapi.rabadtechnology.com/visit_in.php');
  String currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
    try {
      final Map<String, dynamic> requestBody = {
        "company_name": comName,
        "name": name,
        "time": currentTime,
        "date": currentDate,
        "latitude": latitude,
        "longitude": longitude,
      };
      final response = await http.post(
        url, // Replace this with your endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      var success = responseData['success'];
      var message = responseData['message'];
      if (success == true) {
        setState(() {
          visit = false;
          print(punch);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
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
  }

  void clearStorage(context) async {
    try {
      await localStorage.clear();
      print('LocalStorage has been cleared!');
      Navigator.pushReplacement(
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

  String latitude = '';
  String longitude = '';
  String status = 'Press the button to get your location';
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        status = 'Location services are disabled.';
      });
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          status = 'Location permissions are denied';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        status = 'Location permissions are permanently denied.';
      });
      return;
    }

    // Get the current location
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
        status = 'Location found!';
        print("Latitude: $latitude, Longitude: $longitude");
      });

      // Fetch and print the address
      await fetchAndPrintAddress();
    } catch (e) {
      print("Error getting current location: $e");
      setState(() {
        status = 'Error retrieving location: $e';
      });
    }
  }

  Future<void> fetchAndPrintAddress() async {
    double lat = double.tryParse(latitude) ?? 0.0;
    double lng = double.tryParse(longitude) ?? 0.0;

    if (lat == 0.0 && lng == 0.0) {
      print("Invalid latitude and longitude.");
      return;
    }

    String address = await getAddressFromLatLng(lat, lng);
    print("📍 Address: $address");

    // Optional: show on screen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(address)));
  }

  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return "${place.name}, ${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
      } else {
        return "No address available";
      }
    } catch (e) {
      print("Error getting address: $e");
      return "Error retrieving address";
    }
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
                            MaterialPageRoute(builder: (context) => EmpHome()),
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
                      name,
                      style: TextStyle(color: Colors.black),
                    ),
                    accountEmail: Text(
                      name,
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
                                  width: 80,
                                  height: 80,
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
                  (punch == true)
                      ? ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text("Punch Out"),
                        onTap: () {
                          punchOut();
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EmpHome()),
                          );
                        },
                      )
                      :(pcount>=1)?ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text("Punch in"),
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ): ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text("Punch in"),
                        onTap: () {
                          punchIn();
                          Navigator.pop(context);
                        },
                      ),
                    (BreakTime)?ListTile(
                    leading: Icon(Icons.pause),
                    title: Text("Break Out"),
                    onTap: () {
                      BreakOut();
                      Navigator.pop(context); // Close the drawer first
                    },
                  ):(bcount>=3)?ListTile(
                    leading: Icon(Icons.pause),
                    title: Text("Break Limit Over"),
                    onTap: () {
                      Navigator.pop(context); // Close the drawer first
                    },
                  ):ListTile(
                    leading: Icon(Icons.pause),
                    title: Text("Break In"),
                    onTap: () {
                      BreakIn();
                      Navigator.pop(context); // Close the drawer first
                    },
                  ),
                  (visit == true)
                      ? ListTile(
                        leading: Icon(Icons.person),
                        title: Text("Visit in"),
                        onTap: () {
                          visitIn();
                          setState(() {
                            visit==false;
                          });
                        },
                      )
                      : ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text("Visit out"),
                        onTap: () {
                          if (punch == true) {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VisitOut()),
                            );
                          }
                        },
                      ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app),
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
                          color: Color(
                            0xFF03a9f4,
                          ), // Set the background color here
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Optional: Adds rounded corners
                        ),
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Column(
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
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
                                                  width: 80,
                                                  height: 80,
                                                  fit:
                                                      BoxFit
                                                          .cover, // Optional: Adjust how the image fits inside the container
                                                ),
                                              )
                                              : Text(" "),
                                    ),

                                    SizedBox(width: 10),
                                    Text(
                                      name,
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
                            Container(
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
                                                        'Today Report: $currentDate',
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
                                                        height: 20,
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
                                                                        .black,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Attendance",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                            Text(
                                                              "Work Start",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                            Text(
                                                              "End",
                                                              style: TextStyle(
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>  Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => Attendancerep(),
                                                ),
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .remove_red_eye,
                                                                size: 30,color: Colors.black,
                                                              ),
                                                            ),
                                                            (punch == true )
                                                                ? Container(
                                                                  width: 60,
                                                                  height: 20,
                                                                  color:
                                                                      Colors
                                                                          .green,
                                                                  child: Center(
                                                                    child: Text(
                                                                      "Present",
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.white,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                : Text(
                                                                  "Not Marked",
                                                                ),
                                                            (startTime != '')
                                                                ? Container(
                                                                  width: 60,
                                                                  height: 20,
                                                                  color:
                                                                      Colors.white,
                                                                  child: Center(
                                                                    child: Text(
                                                                      startTime,
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                : Text(
                                                                  "      -  ",
                                                                ),
                                                            (endtime != '')
                                                                ? Container(
                                                                  width: 60,
                                                                  height: 20,
                                                                  color:
                                                                      Colors.white,
                                                                  child: Center(
                                                                    child: Text(
                                                                      endtime,
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                : Text(
                                                                  "       -  ",
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
                            SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                //stop
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  // Set the background color here
                  color: Color(0xFF03a9f4),
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Optional: Adds rounded corners
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Mark Attendance",
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(Icons.add, size: 40),
                            (punch)
                                ? ElevatedButton(
                                  onPressed: () async {
                                    await _pickImageFromCamera();
                                    punchOut();
                                  },
                                  child: Text(
                                    "Punch Out",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                )
                                :(pcount>=1)? ElevatedButton(
                                  onPressed: () async {},
                                  child: Text(
                                    "Punch in",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                ):ElevatedButton(
                                  onPressed: () async {
                                    await _pickImageFromCamera();
                                    punchIn();
                                  },
                                  child: Text(
                                    "Punch in",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Visit Time",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Icon(Icons.exit_to_app, size: 40),
                            (visit == true)
                                ? ElevatedButton(
                                  onPressed: () {visitIn();
                                  setState(() {
                            visit==false;
                          });},
                                  child: Text(
                                    "Visit in",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed:
                                      () =>
                                          (punch == true)
                                              ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => VisitOut(),
                                                ),
                                              )
                                              : "",
                                  child: Text(
                                    "Visit Out",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                ),
                          ],
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
                  // Set the background color here
                  color: Color(0xFF03a9f4),
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Optional: Adds rounded corners
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Attendance Report",
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(Icons.assignment_turned_in, size: 40),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Attendancerep(),
                                    ),
                                  ),
                              child: Text(
                                "View",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03a9f4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Break Time Report",
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(Icons.access_time, size: 40),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Visitreport(),
                                    ),
                                  ),
                              child: Text(
                                "View",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03a9f4),
                              ),
                            ),
                          ],
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
                  // Set the background color here
                  color: Color(0xFF03a9f4),
                  borderRadius: BorderRadius.circular(
                    10,
                  ), // Optional: Adds rounded corners
                ),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Break Time", style: TextStyle(fontSize: 15)),
                            Icon(Icons.breakfast_dining, size: 40),
                            (BreakTime)?ElevatedButton(
                              onPressed: () => BreakOut(),
                              child: Text(
                                "Break Out",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03a9f4),
                              ),
                            ):(bcount>=3)?ElevatedButton(
                              onPressed: () => print("Break Limit Over"),
                              child: Text(
                                "Break Limit Over",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03a9f4),
                              ),
                            ):ElevatedButton(
                              onPressed: () => BreakIn(),
                              child: Text(
                                "Break In",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03a9f4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Report", style: TextStyle(fontSize: 15)),
                            Icon(Icons.insert_chart_outlined, size: 40),
                            ElevatedButton(
                              onPressed: () => print("Report"),
                              child: Text(
                                "Report",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF03a9f4),
                              ),
                            ),
                          ],
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
