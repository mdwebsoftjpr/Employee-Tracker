import 'dart:async';
import 'dart:io';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Home%20Screen/EmpVisitRep.dart';
import 'package:employee_tracker/Screens/Detail%20Screen/EmpAttDetail.dart';
import 'package:employee_tracker/Screens/Profile%20Scree/empProfile.dart';
import 'package:employee_tracker/Screens/VisitOut%20Screen/VisitOut.dart';
import 'package:employee_tracker/main.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; 

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
    await getVisit();
    await getDeviceId();
    checkAutoPunchOut();
  }

  int _selectedIndex = 0;
  bool drop = false;
  String name = "key_person";
  String comName = 'Compamy';
  String username = "";
  String role = '';
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
  int VisitId = 0;
  int? Comid;
  String? visitStatus;
  String? userImg;
  String? comimage;

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
        Comid = user['company_id'] ?? 0;
        name = user['name'] ?? 'Default User';
        username = user['username'] ?? 'Default User';
        userid = user['id'] ?? 'Default User';
        userImg =  user['image'];
        comimage=user['company_logo'];
      });
      print(userImg);
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
          print(Mainstatus);
        } else {
          setState(() {
            Mainstatus = '';
            UserImage = image;
            punchIntime = punchInTime;
          });
        }
        print(message);
      } else {
        setState(() {
          Mainstatus = '';
        });

        print(message);
      }
    } catch (e) {
      print("ihcauihhuih $e");
    }
  }

  Future<void> getVisit() async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/getvisitstatus.php',
    );
    try {
      final Map<String, dynamic> requestBody = {
        "emp_id": userid,
        "company_id": Comid,
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        var visitData = responseData['data'][0];
        var visitPunc = visitData['status'];
        setState(() {
          visitStatus = visitPunc;
        });
        print(visitPunc);
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

  Future<File?> compressImage(XFile xFile) async {
  final File file = File(xFile.path);
  final dir = await getTemporaryDirectory();
  final targetPath = p.join(dir.path, 'compressed_${p.basename(file.path)}');

  int quality = 70;
  File? compressedFile;
  const int maxSizeInBytes = 100 * 1024;

  for (int q = quality; q >= 10; q -= 10) {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: q,
      format: CompressFormat.jpeg,
    );

    if (result != null && await result.length() <= maxSizeInBytes) {
      compressedFile = File(result.path);
      break;
    }
  }

  return compressedFile;
}

Future<void> _pickImageFromCamera() async {
  final XFile? pickedFile = await _picker.pickImage(
    source: ImageSource.camera,
    preferredCameraDevice: CameraDevice.front,
  );

  if (pickedFile != null) {
    File? compressed = await compressImage(pickedFile);

    setState(() {
      _imageFile = compressed != null ? XFile(compressed.path) : pickedFile;
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EmpHome()),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EmpAttdetail()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Empvisitrep()),
      );
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
    request.fields['company_id'] = Comid.toString();
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
        Alert.alert(context, message);
      } else {
        Alert.alert(context, message);
      }
    } else {
      Alert.alert(
        context,
        "❌ Upload failed with status: ${response.statusCode}",
      );
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
    print(Comid);
    // Optional: send extra fields
    request.fields['multipoint'] = '${latitude}_${longitude}';
    request.fields['diviceid'] = deviceId;
    request.fields['address'] = CurrentAddress;
    request.fields['employeeid'] = '$userid';
    request.fields['company_id'] = Comid.toString();
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
        getApi();
        Alert.alert(context, message);
      } else {
        Alert.alert(context, message);
      }
    } else {
      Alert.alert(
        context,
        "❌ Upload failed with status: ${response.statusCode}",
      );
    }
  }

  void visitIn() async {
    try {
      if (_imageFile == null) return;
      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/employee_activity.php',
      );
      final request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
      request.fields['coordinate'] = '$latitude,$longitude';
      request.fields['diviceid'] = deviceId;
      request.fields['company_id'] = Comid.toString();
      request.fields['address'] = CurrentAddress;
      request.fields['empid'] = '$userid';
      // Send request
      final response = await request.send();
      final response1 = await http.Response.fromStream(response);
      var data = jsonDecode(response1.body);
      var success = data['success'] ?? '';
      var message = data['message'] ?? '';
      if (success) {
        print(data);
        var status = data['status'] ?? '';
        var id = status[0]['id'] ?? '';
        print(id);
        setState(() {
          VisitId = id;
        });
        Alert.alert(context, message);
        getVisit();
      } else {
        Alert.alert(context, message);
      }
    } catch (e) {
      Alert.alert(context, e);
    }
  }

  void clearStorage(BuildContext context) async {
    try {
      await localStorage.clear();
      await Alert.alert(
        context,
        'Successfully Logout',
      ); // WAIT before navigating
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateScreen()),
      );
    } catch (e) {
      await Alert.alert(context, 'Error: $e'); // also await here
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
      Alert.alert(context, 'Location services are disabled. Please enable.');
      await Geolocator.openLocationSettings();
      return;
    }

    // Check permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Alert.alert(context, 'Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Alert.alert(context, 'Location permission permanently denied.');
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

      print('Location fetched successfully.');

      // Now fetch the address
      await fetchAndPrintAddress();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> fetchAndPrintAddress() async {
    double? lat = double.tryParse(latitude);
    double? lng = double.tryParse(longitude);

    if (lat == null || lng == null) {
      print('Invalid latitude or longitude.');
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

        print('📍 Address: $address');
      } else {
        print('No address found.');
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          value: 'profile',
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

    if (selectedItem == 'profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Empprofile()),
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
                      (UserImage != null && UserImage.isNotEmpty)
                          ? Image.network(
                            'https://testapi.rabadtechnology.com/$userImg',
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
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(
                        0xFF03a9f4,
                      ), // Background color for the entire drawer
                    ),
                    accountName: Text(
                      comName,
                      style: TextStyle(color: Colors.white),
                    ),
                    accountEmail: Text(
                      name,
                      style: TextStyle(color: Colors.white),
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
                                  'https://testapi.rabadtechnology.com/$comimage',
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
                        leading: Icon(Icons.fingerprint) ,
                        title: Text("Punch in"),
                        onTap: () {
                          _pickImageFromCamera();
                          punchOut();
                        },
                      )
                      : ListTile(
                        leading: Icon(Icons.power_settings_new),
                        title: Text("Punch Out"),
                        onTap: () {
                          _pickImageFromCamera();
                          punchIn();
                        },
                      ),
                  (BreakTime)
                      ? ListTile(
                        leading: Icon(Icons.coffee) ,
                        title: Text("Break Out"),
                        onTap: () {
                          BreakOut();
                          Navigator.pop(context); // Close the drawer first
                        },
                      )
                      : (bcount >= 3)
                      ? ListTile(
                        leading: Icon(Icons.coffee) ,
                        title: Text("Break Limit Over"),
                        onTap: () {
                          Navigator.pop(context); // Close the drawer first
                        },
                      )
                      : ListTile(
                        leading: Icon(Icons.coffee) ,
                        title: Text("Break In"),
                        onTap: () {
                          BreakIn();
                          Navigator.pop(context); // Close the drawer first
                        },
                      ),
                  (visitStatus == 'opne')
                      ? ListTile(
                        leading: Icon(Icons.run_circle) ,
                        title: Text("Visit Out"),
                        onTap: () {
                          if (Mainstatus != '' && Mainstatus == 'punchin') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VisitOut(),
                              ),
                            );
                          } else {
                            Alert.alert(
                              context,
                              'Please Mark Your Attendance Then Do Visit',
                            );
                          }
                        },
                      )
                      : ListTile(
                        leading: Icon(Icons.location_on) ,
                        title: Text("Visit In"),
                        onTap: () async {
                          if (Mainstatus != '' && Mainstatus == 'punchin') {
                            await _pickImageFromCamera();
                            visitIn();
                          } else {
                            Alert.alert(
                              context,
                              'Please Mark Your Attendance Then Do Visit',
                            );
                          }
                        },
                      ),

                  ListTile(
                    leading: Icon(Icons.fact_check) ,
                    title: Text("Attendance Report"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EmpAttdetail()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.receipt_long) ,
                    title: Text("Visit Report"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Empvisitrep()),
                      );
                    },
                  ),
                  ListTile(
                    leading:Icon(Icons.logout) ,
                    title: Text("Logout"),
                    onTap: () {
                      clearStorage(context);
                    },
                  ),
                  SizedBox(height: 60,),
                  Divider(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0, top: 10),
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
                              fontSize: 13,
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
                              SizedBox(width: 4),
                              Text(
                                '2025 Md Websoft',
                                style: TextStyle(
                                  fontSize: 13,
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
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF03a9f4),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_photo_alternate_outlined),
            label: 'Att. Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Visit Rep.',
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
                          color: Color(0xFF03a9f4),
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      margin: EdgeInsets.all(10),
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
                                              : SizedBox(width: 80, height: 80),
                                    ),

                                    SizedBox(width: 10),

                                    /// 👇 Wrap this in Flexible so the Column can wrap text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start, // Align text to the start
                                        children: [
                                          Text(
                                            name,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            CurrentAddress,
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            softWrap: true,
                                            overflow:
                                                TextOverflow
                                                    .visible, // or TextOverflow.ellipsis
                                            maxLines:
                                                null, // allow multiple lines
                                          ),
                                        ],
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
                                                                              EmpAttdetail(),
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
                              "Mark Attendance",
                              style: TextStyle(fontSize: 15),
                            ),
                            Image.asset(
                              'assets/images/attendance.png',
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.25,
                            ),
                            (Mainstatus == "" || Mainstatus == 'punchout')
                                ? ElevatedButton(
                                  onPressed: () async {
                                    await _pickImageFromCamera();
                                    punchIn();
                                  },
                                  child: Text("Punch in"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: () async {
                                    await _pickImageFromCamera();
                                    punchOut();
                                  },
                                  child: Text("Punch Out"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
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
                              "Visit Time",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Image.asset(
                              'assets/images/visit.png',
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: MediaQuery.of(context).size.width * 0.25,
                            ),
                            (visitStatus == 'opne')
                                ? ElevatedButton(
                                  onPressed: () {
                                    print(VisitId);
                                    if (Mainstatus != '' &&
                                        Mainstatus == 'punchin') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => VisitOut(),
                                        ),
                                      );
                                    } else {
                                      Alert.alert(
                                        context,
                                        'Please Mark Your Attendance Then Do Visit',
                                      );
                                    }
                                  },
                                  child: Text("Visit Out"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: () async {
                                    if (Mainstatus != '' &&
                                        Mainstatus == 'punchin') {
                                      await _pickImageFromCamera();
                                      visitIn();
                                    } else {
                                      Alert.alert(
                                        context,
                                        'Please Mark Your Attendance Then Do Visit',
                                      );
                                    }
                                  },
                                  child: Text("Visit In"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
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
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              "Break 1"
                            ),
                            Image.asset(
                              'assets/images/Break.png',
                              width: MediaQuery.of(context).size.width * 0.12,
                              height: MediaQuery.of(context).size.width * 0.12,
                            ),
                            (bcount == 0)
                                ? ElevatedButton(
                                  onPressed: () => {BreakIn()},
                                  child: Text(
                                    "Start"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : (bcount == 1)
                                ? ElevatedButton(
                                  onPressed: () => {BreakOut()},
                                  child: Text(
                                    "End"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: () => {},
                                  child: Text(
                                    "End"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    Container(
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
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              "Break 2"
                            ),
                            Image.asset(
                              'assets/images/Break.png',
                              width: MediaQuery.of(context).size.width * 0.12,
                              height: MediaQuery.of(context).size.width * 0.12,
                            ),
                            (bcount == 2)
                                ? ElevatedButton(
                                  onPressed: () => {BreakIn()},
                                  child: Text(
                                    "Start"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : (bcount == 3)
                                ? ElevatedButton(
                                  onPressed: () => {BreakOut()},
                                  child: Text(
                                    "End"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: () => {},
                                  child: Text(
                                    "End"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                    Container(
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
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              "Break 3"
                            ),
                            Image.asset(
                              'assets/images/Break.png',
                              width: MediaQuery.of(context).size.width * 0.12,
                              height: MediaQuery.of(context).size.width * 0.12,
                            ),
                            (bcount == 4)
                                ? ElevatedButton(
                                  onPressed: () => {BreakIn()},
                                  child: Text(
                                    "Start"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : (bcount == 5)
                                ? ElevatedButton(
                                  onPressed: () => {BreakOut()},
                                  child: Text(
                                    "End"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                                )
                                : ElevatedButton(
                                  onPressed: () => {},
                                  child: Text(
                                    "End"
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
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
                              "Att. Report's",
                              style: TextStyle(fontSize: 15),
                            ),
                            Image.asset(
                              'assets/images/Att  Report.png',
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.width * 0.20,
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EmpAttdetail(),
                                    ),
                                  ),
                              child: Text(
                                "View"
                              ),
                              style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
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
                              "Visit Report's",
                              style: TextStyle(fontSize: 15),
                            ),
                            Image.asset(
                              'assets/images/visit_report.png',
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: MediaQuery.of(context).size.width * 0.20,
                            ),
                            ElevatedButton(
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Empvisitrep(),
                                    ),
                                  ),
                              child: Text(
                                "View"
                              ),
                              style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF03a9f4),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal:
                                          MediaQuery.of(context).size.width *
                                          0.05,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        MediaQuery.of(context).size.width *
                                            0.07,
                                      ),
                                    ),
                                    elevation: 4,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              /*  SizedBox(height: 10),
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
              ), */
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
