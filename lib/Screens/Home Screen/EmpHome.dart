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
import 'package:device_info_plus/device_info_plus.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAddress();
    });
    initializeApp();
  }

  void initializeApp() async {
    await getApi();
    await getDeviceId();
    checkAutoPunchOut();
  }

  int _selectedIndex = 0;
  bool drop = false;
  String name = "key_person";
  String comName = 'Compamy';
  String username = "";
  String role = '';
  bool visit = false;
  int bcount = 0;
  bool BreakTime = false;
  String PSatatus = 'Present';
  String Mainstatus = '';
  int userid = 0;
  String CurrentAddress = '';
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  String deviceId = '';
  String latitude = '';
  String longitude = '';
  String status = 'Press the button to get your location';
  String UserImage = '';
  String punchIntime = '';
  String punchOuttime = '';

  Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      ;
      var DeviceId = androidInfo.id;
      setState(() {
        deviceId = DeviceId ?? 'unknown';
      });
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      var DeviceId = iosInfo.identifierForVendor;
      setState(() {
        deviceId = DeviceId ?? 'unknown';
      });
    }

    return null;
  }

  Future<void> getApi() async {
    var userJson = localStorage.getItem('user');
    print(userJson);
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        name = user['name'] ?? 'Default User';
        username = user['username'] ?? 'Default User';
        userid = user['id'] ?? 'Default User';
        role = localStorage.getItem('role');
      });
    }
    var Visit = localStorage.getItem('visitout') ?? false;
    if (Visit == true) {
      setState(() {
        visit = Visit;
      });
    }
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/getEmployeestatus.php',
    );
    try {
      final Map<String, dynamic> requestBody = {"employee_id": userid};
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      var responseData = jsonDecode(response.body);

      var success = responseData['success'];
      var message = responseData['message'];
      print("GetApi $responseData");
      if (success == true) {
        var data = responseData['data'];
        var statusin = data[0]['status_PunchIn'] ?? '';
        var image = data[0]['image_path'] ?? '';
        var punchInTime = data[0]['time'] ?? '';
        var punchOutTime = data[0]['time_out'] ?? '';

        if (statusin != '') {
          setState(() {
            Mainstatus = statusin;
            UserImage = image;
            punchIntime = punchInTime;
            punchOuttime = punchOutTime;
          });
        } else {
          setState(() {
            Mainstatus = '';
            UserImage = image;
            punchIntime = punchInTime;
          });
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        setState(() {
          Mainstatus = '';
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      print("ihcauihhuih $e");
    }
  }

  void checkAutoPunchOut() {
    final now = DateTime.now();
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    if (now.isAfter(endOfDay)) {
      // Auto punch out
      punchOut();
      setState(() {
        PSatatus = 'Not Marke';
        bcount = 0;
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

  void BreakIn() {
    setState(() {
      BreakTime = true;
      bcount++;
      print(bcount);
    });
  }

  void BreakOut() {
    setState(() {
      bcount++;
      BreakTime = false;
      print(BreakTime);
    });
  }

  void punchIn() async {
    if (_imageFile == null) return;

    final url = Uri.parse('https://testapi.rabadtechnology.com/attendence.php');
    final request = http.MultipartRequest('POST', url);

    // Attach image
    request.files.add(
      await http.MultipartFile.fromPath('image', _imageFile!.path),
    );

    // Optional: send extra fields
    request.fields['multipoint'] = '${latitude}_${longitude}';
    request.fields['diviceid'] = deviceId;
    request.fields['address'] = CurrentAddress;
    request.fields['employeeid'] = '$userid';

    // Send request
    final response = await request.send();
    if (response.statusCode == 200) {
      print("✅ Image uploaded successfully");
      final response1 = await http.Response.fromStream(response);
      var data = jsonDecode(response1.body);
      var success = data['success'];
      var message = data['message'];

      if (success) {
        print("Success $success");
        getApi();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      print("❌ Upload failed with status: ${response.statusCode}");
    }
  }

  void punchOut() async {
    if (_imageFile == null) return;

    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/attendenceout.php',
    );
    final request = http.MultipartRequest('POST', url);

    // Attach image
    request.files.add(
      await http.MultipartFile.fromPath('image', _imageFile!.path),
    );

    // Optional: send extra fields
    request.fields['multipoint'] = '${latitude}_${longitude}';
    request.fields['diviceid'] = deviceId;
    request.fields['address'] = CurrentAddress;
    request.fields['employeeid'] = '$userid';
    print("punch out vsonfon");
    // Send request
    final response = await request.send();
    if (response.statusCode == 200) {
      print("✅ Image uploaded successfully");
      final response1 = await http.Response.fromStream(response);
      var data = jsonDecode(response1.body);

      var success = data['success'];
      var message = data['message'];

      if (success) {
        print("hdauihidnh");
        getApi();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } else {
      print("❌ Upload failed with status: ${response.statusCode}");
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

  Future<void> loadAddress() async {
    await getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled. Please enable.');
      await Geolocator.openLocationSettings();
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permission permanently denied.');
      return;
    }

    // ✅ Get the position now
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });

      _showSnackBar('Location fetched successfully.');

      // Now fetch the address
      await fetchAndPrintAddress();
    } catch (e) {
      _showSnackBar('Error getting location: $e');
    }
  }

  Future<void> fetchAndPrintAddress() async {
    double? lat = double.tryParse(latitude);
    double? lng = double.tryParse(longitude);

    if (lat == null || lng == null) {
      _showSnackBar('Invalid latitude or longitude.');
      return;
    }

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address =
            "${place.name}, ${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

        setState(() {
          CurrentAddress = address;
        });

        _showSnackBar('📍 Address: $address');
      } else {
        _showSnackBar('No address found.');
      }
    } catch (e) {
      _showSnackBar('Error fetching address: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                          (UserImage != '')
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  'https://testapi.rabadtechnology.com/uploads/$UserImage',
                                  fit: BoxFit.cover,
                                ),
                              )
                              : SizedBox(),
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
                  (Mainstatus == "" || Mainstatus == 'punchout')
                      ? ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text("Punch in"),
                        onTap: () async {
                          await _pickImageFromCamera();
                          punchIn();
                          Navigator.pop(context);
                        },
                      )
                      : ListTile(
                        leading: Icon(Icons.access_time),
                        title: Text("Punch Out"),
                        onTap: () async {
                          await _pickImageFromCamera();
                          punchOut();
                          Navigator.pop(context);
                        },
                      ),
                  (BreakTime)
                      ? ListTile(
                        leading: Icon(Icons.pause),
                        title: Text("Break Out"),
                        onTap: () {
                          BreakOut();
                          Navigator.pop(context); // Close the drawer first
                        },
                      )
                      : (bcount >= 3)
                      ? ListTile(
                        leading: Icon(Icons.pause),
                        title: Text("Break Limit Over"),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer first
                        },
                      )
                      : ListTile(
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
                        title: Text("Visit out"),
                        onTap: () {
                          visitIn();
                          setState(() {
                            visit == false;
                          });
                        },
                      )
                      : ListTile(
                        leading: Icon(Icons.exit_to_app),
                        title: Text("Visit in"),
                        onTap: () {
                          if (Mainstatus == '' && Mainstatus == 'punchout') {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VisitOut()),
                            );
                          }
                        },
                      ),
                  ListTile(
                    leading: Icon(Icons.assignment_turned_in),
                    title: Text("Attendance Report"),
                    onTap: () { Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Attendancerep()),
                            );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text("Visit Report"),
                    onTap: () { Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => Visitreport()),
                            );
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
                                          (UserImage != '')
                                              ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                  'https://testapi.rabadtechnology.com/uploads/$UserImage',
                                                  width: 80,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                              : SizedBox(),
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
                                                                  () => Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (
                                                                            context,
                                                                          ) =>
                                                                              Attendancerep(),
                                                                    ),
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .remove_red_eye,
                                                                size: 30,
                                                                color:
                                                                    Colors
                                                                        .black,
                                                              ),
                                                            ),
                                                            (Mainstatus != "")
                                                                ? Container(
                                                                  width: 60,
                                                                  height: 20,
                                                                  color:
                                                                      Colors
                                                                          .green,
                                                                  child: Center(
                                                                    child: Text(
                                                                      PSatatus,
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
                                                            (punchIntime != '')
                                                                ? Container(
                                                                  width: 60,
                                                                  height: 20,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  child: Center(
                                                                    child: Text(
                                                                      punchIntime,
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
                                                            (punchOuttime != '')
                                                                ? Container(
                                                                  width: 60,
                                                                  height: 20,
                                                                  color:
                                                                      Colors
                                                                          .white,
                                                                  child: Center(
                                                                    child: Text(
                                                                      punchOuttime,
                                                                      style: TextStyle(
                                                                        color:
                                                                            Colors.black,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                : Text(
                                                                  "     -  ",
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
                            (Mainstatus == "" || Mainstatus == 'punchout')
                                ? ElevatedButton(
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
                                )
                                : ElevatedButton(
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
                                  onPressed: () {
                                    visitIn();
                                    setState(() {
                                      visit == false;
                                    });
                                  },
                                  child: Text(
                                    "Visit out",
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
                                          (Mainstatus == '' && Mainstatus == 'punchout')
                                              ? Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) => VisitOut(),
                                                ),
                                              )
                                              : "",
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        // Set the background color here
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Optional: Adds rounded corners
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              "Break 1",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            Icon(Icons.coffee, size: 35),
                            (bcount == 0)
                                ? ElevatedButton(
                                  onPressed: () => {BreakIn()},
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                )
                                : (bcount == 1)
                                ? ElevatedButton(
                                  onPressed: () => {BreakOut()},
                                  child: Text(
                                    "End",
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
                                  onPressed: () => {},
                                  child: Text(
                                    "End",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        // Set the background color here
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Optional: Adds rounded corners
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              "Break 2",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                              ),
                            ),
                            Icon(Icons.dining, size: 35),
                            (bcount == 2)
                                ? ElevatedButton(
                                  onPressed: () => {BreakIn()},
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                )
                                : (bcount == 3)
                                ? ElevatedButton(
                                  onPressed: () => {BreakOut()},
                                  child: Text(
                                    "End",
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
                                  onPressed: () => {},
                                  child: Text(
                                    "End",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        // Set the background color here
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Optional: Adds rounded corners
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              "Break 3",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Icon(Icons.coffee, size: 35),
                            (bcount == 4)
                                ? ElevatedButton(
                                  onPressed: () => {BreakIn()},
                                  child: Text(
                                    "Start",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                  ),
                                )
                                : (bcount == 5)
                                ? ElevatedButton(
                                  onPressed: () => {BreakOut()},
                                  child: Text(
                                    "End",
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
                                  onPressed: () => {},
                                  child: Text(
                                    "End",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
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
                              "Daily Visit In Report",
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
                            Text(
                              "Break Report",
                              style: TextStyle(fontSize: 15),
                            ),
                            Icon(Icons.breakfast_dining, size: 40),
                            ElevatedButton(
                              onPressed: () => BreakOut(),
                              child: Text(
                                "Break Report",
                                style: TextStyle(
                                  fontSize: 13,
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
