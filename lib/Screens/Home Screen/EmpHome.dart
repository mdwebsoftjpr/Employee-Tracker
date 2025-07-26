import 'dart:async';
import 'dart:io';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Employee%20Reports/EmpVisitRep.dart';
import 'package:employee_tracker/Screens/Employee%20Reports/EmpAttDetail.dart';
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
import 'package:get/get.dart';

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
  }

  int _selectedIndex = 0;
  bool drop = false;
  String name = "key_person";
  String comName = 'Compamy';
  String username = "";
  String role = '';
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
  String? trade_name;
  bool isLoading = false;
  String? Break1;
  String? Break2;
  String? Break3;
  String? Status;
  String? totalDays;
  int? totalPresent;
  int? totalAbsent;
  List<dynamic> statusData = [];

  int currentIndex = 0;

  Future<String?> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
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
    setState(() {
      isLoading = true;
    });
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        Comid = user['company_id'] ?? 0;
        trade_name = user['trade_name'] ?? 0;
        name = user['name'] ?? 'Default User';
        username = user['username'] ?? 'Default User';
        userid = user['id'] ?? 'Default User';
        userImg = user['image'] ?? '';
        comimage = user['company_logo'];
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
      if (success == true) {
        var data = responseData['data'];
        var statusin = data[0]['status_PunchIn'] ?? '';
        var image = data[0]['image_path'] ?? '';
        var punchInTime = data[0]['time'] ?? '';
        var punchOutTime = data[0]['time_out'] ?? '';
        var break1 = data[0]['break1'] ?? '';
        var break2 = data[0]['break2'] ?? '';
        var break3 = data[0]['break3'] ?? '';
        var totaldays = data[0]['working_count'] ?? '';
        var totalpresent = data[0]['present_count'] ?? '';
        var totalabsent = data[0]['absent_count'] ?? '';
        if (statusin != '') {
          setState(() {
            statusData = data;
            isLoading = false;
            Mainstatus = statusin;
            UserImage = image;
            punchIntime = punchInTime;
            punchOuttime = punchOutTime;
            Break1 = break1;
            Break2 = break2;
            Break3 = break3;
            totalPresent = totalpresent;
            totalAbsent = totalabsent;
            totalDays = totaldays;
          });
        } else {
          setState(() {
            isLoading = false;
            Mainstatus = '';
            UserImage = image;
            punchIntime = punchInTime;
          });
        }
      } else {
        setState(() {
          isLoading = false;
          Mainstatus = '';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
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
      }
    } catch (e) {}
  }

  Future<File?> compressImage(XFile xFile) async {
    setState(() {
      isLoading = true;
    });
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

    setState(() {
      isLoading = false;
    });
    return compressedFile;
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      imageQuality: 20,
      maxWidth: 600,
      maxHeight: 600,
    );

    if (pickedFile != null) {
      File? compressed = await compressImage(pickedFile);

      setState(() {
        _imageFile = compressed != null ? XFile(compressed.path) : pickedFile;
      });
    }
  }

  void _onItemTapped(int index) {
    int count = 0;
    if (currentIndex == index) return;
    setState(() {
      count++;
      if (count == 0) {
        currentIndex = index;
      } else {
        currentIndex = 0;
      }
    });

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

  final List<String> _options = ['Option 1', 'Option 2', 'Option 3'];

  String currentDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  void dropdown() {
    setState(() {
      drop = false;
    });
  }

  BreakIn(String breakcount) async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/employeebreakupdate.php',
    );

    try {
      final Map<String, dynamic> requestBody = {
        "employee_id": userid,
        "break": breakcount,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Check if response is successful and not empty
      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final responseData = jsonDecode(response.body);

        final success = responseData['success'];
        final message = responseData['message'];

        if (success == true) {
          setState(() {
            Status = responseData['status'];
          });
          Alert.alert(context, message);
          getApi();
        } else {
          Alert.alert(context, message);
        }
      }
    } catch (e) {}
  }

  void punchIn() async {
    setState(() {
      isLoading = true;
    });
    await _pickImageFromCamera();
    if (_imageFile == null) {
      setState(() {
        isLoading = false; // Reset loading when no image picked
      });
      return;
    }

    final url = Uri.parse('https://testapi.rabadtechnology.com/attendence.php');
    final request = http.MultipartRequest('POST', url);

    // Attach image
    request.files.add(
      await http.MultipartFile.fromPath('image', _imageFile!.path),
    );

    // Optional: send extra fields
    request.fields['trade_name'] = trade_name.toString();
    request.fields['multipoint'] = '${latitude}_${longitude}';
    request.fields['diviceid'] = deviceId;
    request.fields['address'] = CurrentAddress;
    request.fields['employeeid'] = '$userid';
    request.fields['company_id'] = Comid.toString();
    // Send request
    final response = await request.send();
    if (response.statusCode == 200) {
      final response1 = await http.Response.fromStream(response);
      var data = jsonDecode(response1.body);
      var success = data['success'];
      var message = data['message'];

      if (success) {
        setState(() {
          isLoading = false;
        });
        getApi();
        Alert.alert(context, message);
      } else {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, message);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Alert.alert(
        context,
        "❌ Upload failed with status: ${response.statusCode}",
      );
    }
  }

  void punchOut() async {
    setState(() {
      isLoading = true;
    });
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
    request.fields['trade_name'] = trade_name.toString();
    request.fields['multipoint'] = '${latitude}_${longitude}';
    request.fields['diviceid'] = deviceId;
    request.fields['address'] = CurrentAddress;
    request.fields['employeeid'] = '$userid';
    request.fields['company_id'] = Comid.toString();

    final response = await request.send();
    if (response.statusCode == 200) {
      final response1 = await http.Response.fromStream(response);
      var data = jsonDecode(response1.body);

      var success = data['success'];
      var message = data['message'];

      if (success) {
        setState(() {
          isLoading = false;
        });
        getApi();
        Alert.alert(context, message);
      } else {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, message);
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Alert.alert(
        context,
        "❌ Upload failed with status: ${response.statusCode}",
      );
    }
  }

  void visitIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      await _pickImageFromCamera();
      if (_imageFile == null) {
        setState(() {
          isLoading = false; // Reset loading when no image picked
        });
        return;
      }

      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/employee_activity.php',
      );
      final request = http.MultipartRequest('POST', url);

      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );
      request.fields['trade_name'] = trade_name.toString();
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
        var status = data['status'] ?? '';
        var id = status[0]['id'] ?? '';
        setState(() {
          isLoading = false;
          VisitId = id;
        });
        Alert.alert(context, message);
        getVisit();
      } else {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, message);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Alert.alert(context, e);
    }
  }

  void clearStorage(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    try {
      await localStorage.clear();
      setState(() {
        isLoading = false;
      });
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => CreateScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      await Alert.alert(context, 'Error: $e'); // also await here
    }
  }

  void dropUp() {
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

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      /* 
      Alert.alert(context, 'Location services are disabled. Please enable.');
      await Geolocator.openLocationSettings(); */
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Location Required",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            "Please enable location services to continue.",
            style: TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: [
            Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03a9f4),
                  ),
                  onPressed: () {
                    Get.back();
                  },
                  child: Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                SizedBox(width: 3),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03a9f4),
                  ),
                  onPressed: () async {
                    await Geolocator.openLocationSettings(); // Open settings
                    Get.back(); // Close dialog

                    // ⏳ Wait and check if location gets enabled
                    bool serviceEnabled = false;
                    for (int i = 0; i < 10; i++) {
                      serviceEnabled =
                          await Geolocator.isLocationServiceEnabled();
                      if (serviceEnabled) break;
                      await Future.delayed(Duration(milliseconds: 500));
                    }

                    if (serviceEnabled) {
                      // ✅ Navigate to next screen (location is ON)
                      Future.delayed(Duration(milliseconds: 100), () {
                        Get.offAll(() => EmpHome()); // your screen
                      });
                    } else {
                      Get.snackbar(
                        icon: Icon(Icons.location_on),
                        "EmpAttend",
                        "❗ Location is still OFF",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Color(0xFF03a9f4),
                        colorText: Colors.white,
                        margin: EdgeInsets.all(10),
                      );
                    }
                  },

                  child: Text(
                    "Open Settings",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      return;
    }
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
      // Now fetch the address
      await fetchAndPrintAddress();
    } catch (e) {}
  }

  Future<void> fetchAndPrintAddress() async {
    setState(() {
      isLoading = true;
    });
    double? lat = double.tryParse(latitude);
    double? lng = double.tryParse(longitude);

    if (lat == null || lng == null) {
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
          isLoading = false;
        });
      }
    } catch (e) {}
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
      LogOutAlert(context);
    }
  }

  Future<void> punchOutAlert(BuildContext context) async {
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
            "Are you sure you want to punch out?",
            textAlign: TextAlign.center,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await _pickImageFromCamera();
                    punchOut();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03A9F4),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Punch Out'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF03A9F4),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Cancel'),
                ),
              ],
            ),
          ],
        );
      },
    );
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

  Future<void> BreakAlert(
    BuildContext context,
    String data,
    String message,
    String btn,
  ) async {
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
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                BreakIn(data);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03A9F4),
                foregroundColor: Colors.white,
              ),
              child: Text(btn),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchData() async {
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EmpHome()),
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
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: () => Alert.alert(context, "Comming Soon..."),
              icon: Icon(
                Icons.notifications,
                size: ratio * 15,
                color: Colors.white,
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
                      (userImg != null)
                          ? Image.network(
                            'https://testapi.rabadtechnology.com/$userImg',
                            width: ratio * 18,
                            height: ratio * 18,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // If image fails to load (e.g. 404), show default icon
                              return Icon(
                                Icons.account_circle,
                                size: deviceWidth * 0.10,
                                color: Colors.white,
                              );
                            },
                          )
                          : Icon(
                            Icons.account_circle,
                            size: ratio * 18,
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
                children: [
                  Container(
                    width: double.infinity,
                    height: ratio * 85,
                    decoration: BoxDecoration(color: Color(0xFF03a9f4)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(ratio * 4),
                          child: Image.network(
                            'https://testapi.rabadtechnology.com/$comimage',
                            width: ratio * 50,
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
                          name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: ratio * 6,
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
                        fontSize: ratio * 9,
                      ),
                    ),
                  ),
                  (Mainstatus == "" || Mainstatus == 'punchout')
                      ? ListTile(
                        leading: Icon(Icons.fingerprint, size: ratio * 10),
                        title: Text(
                          "Punch in",
                          style: TextStyle(fontSize: ratio * 7),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          punchIn();
                        },
                      )
                      : ListTile(
                        leading: Icon(
                          Icons.power_settings_new,
                          size: ratio * 10,
                        ),
                        title: Text(
                          "Punch Out",
                          style: TextStyle(fontSize: ratio * 7),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          punchOutAlert(context);
                        },
                      ),
                  SizedBox(height: ratio * 1),
                  (visitStatus == 'opne')
                      ? ListTile(
                        leading: Icon(Icons.run_circle, size: ratio * 10),
                        title: Text(
                          "Visit Out",
                          style: TextStyle(fontSize: ratio * 7),
                        ),
                        onTap: () {
                          if (Mainstatus != '' && Mainstatus == 'punchin') {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => VisitOut()),
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
                        leading: Icon(Icons.location_on, size: ratio * 10),
                        title: Text(
                          "Visit In",
                          style: TextStyle(fontSize: ratio * 7),
                        ),
                        onTap: () async {
                          if (Mainstatus != '' && Mainstatus == 'punchin') {
                            Navigator.pop(context);
                            visitIn();
                          } else {
                            Navigator.pop(context);
                            Alert.alert(
                              context,
                              'Please Mark Your Attendance Then Do Visit',
                            );
                          }
                        },
                      ),
                  SizedBox(height: ratio * 1),
                  ListTile(
                    leading: Icon(Icons.fact_check, size: ratio * 10),
                    title: Text(
                      "Attendance Report",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => EmpAttdetail()),
                      );
                    },
                  ),
                  SizedBox(height: ratio * 1),
                  ListTile(
                    leading: Icon(Icons.receipt_long, size: ratio * 10),
                    title: Text(
                      "Visit Report",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Empvisitrep()),
                      );
                    },
                  ),
                  SizedBox(height: ratio * 1),
                  ListTile(
                    leading: Icon(Icons.logout, size: ratio * 10),
                    title: Text(
                      "Logout",
                      style: TextStyle(fontSize: ratio * 7),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      LogOutAlert(context);
                    },
                  ),
                  SizedBox(height: .10 * deviceHeight),
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
                              fontSize: ratio * 4,
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
                                size: ratio * 6,
                                color: Colors.grey,
                              ),
                              SizedBox(width: ratio * 1),
                              Text(
                                '2025 $comName',
                                style: TextStyle(
                                  fontSize: ratio * 6,
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
                              fontSize: ratio * 6,
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
                              fontSize: ratio * 6,
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
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: ratio * 25,
                      backgroundImage: AssetImage(
                        'assets/splesh_Screen/Emp_Attend.png',
                      ), // Set the background image here
                    ),

                    SizedBox(height: 5),
                    CircularProgressIndicator(color: Color(0xFF03a9f4)),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: fetchData,
                child: SingleChildScrollView(
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
                                right: ratio * 2,
                                left: ratio * 2,
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
                                  width: deviceWidth * 0.9,
                                  child: Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                margin: EdgeInsets.all(10),
                                                child:
                                                    (UserImage != '' &&
                                                            UserImage
                                                                .isNotEmpty)
                                                        ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: Image.network(
                                                            'https://testapi.rabadtechnology.com/uploads/$UserImage',
                                                            width: ratio * 38,
                                                            height: ratio * 38,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        )
                                                        : Icon(
                                                          Icons.account_circle,
                                                          size: ratio * 38,
                                                        ),
                                              ),

                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start, // Align text to the start
                                                  children: [
                                                    Text(
                                                      name,
                                                      style: TextStyle(
                                                        fontSize: ratio * 8,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      CurrentAddress,
                                                      style: TextStyle(
                                                        fontSize: ratio * 6,
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                      Container(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Container(
                                              width: deviceWidth * 0.85,
                                              margin: EdgeInsets.only(
                                                bottom: 5,
                                              ),
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      drop
                                                          ? TextButton(
                                                            onPressed:
                                                                () =>
                                                                    dropdown(),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'Today Report: $currentDate',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        ratio *
                                                                        7,
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .arrow_drop_up,
                                                                  size:
                                                                      ratio *
                                                                      10,
                                                                ),
                                                              ],
                                                            ),
                                                            style: TextButton.styleFrom(
                                                              iconColor:
                                                                  Colors.black,
                                                              backgroundColor:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                          : TextButton(
                                                            onPressed:
                                                                () => dropUp(),
                                                            child: Row(
                                                              children: [
                                                                Text(
                                                                  'Today Report: $currentDate',
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        ratio *
                                                                        7,
                                                                    color:
                                                                        Colors
                                                                            .black,
                                                                  ),
                                                                ),
                                                                Icon(
                                                                  Icons
                                                                      .arrow_drop_down,
                                                                  size:
                                                                      ratio *
                                                                      10,
                                                                ),
                                                              ],
                                                            ),
                                                            style: TextButton.styleFrom(
                                                              iconColor:
                                                                  Colors.black,
                                                              backgroundColor:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                    ],
                                                  ),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            ratio * 7,
                                                          ),
                                                    ),
                                                    child:
                                                        drop
                                                            ? Container(
                                                              height:
                                                                  ratio * 27,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "View",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                ratio *
                                                                                6,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        Container(
                                                                          width:
                                                                              ratio *
                                                                              14,
                                                                          height:
                                                                              ratio *
                                                                              14,
                                                                          child: IconButton(
                                                                            padding:
                                                                                EdgeInsets.zero,
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
                                                                            icon: Icon(
                                                                              Icons.remove_red_eye,
                                                                              size:
                                                                                  ratio *
                                                                                  14,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "Attendance",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                ratio *
                                                                                6,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              ratio *
                                                                              3,
                                                                        ),
                                                                        (Mainstatus !=
                                                                                "")
                                                                            ? Container(
                                                                              width:
                                                                                  ratio *
                                                                                  30,
                                                                              height:
                                                                                  ratio *
                                                                                  9,
                                                                              color:
                                                                                  Colors.green,
                                                                              child: Center(
                                                                                child: Text(
                                                                                  PSatatus,
                                                                                  style: TextStyle(
                                                                                    fontSize:
                                                                                        ratio *
                                                                                        6,
                                                                                    color:
                                                                                        Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                            : Text(
                                                                              "Not Marked",
                                                                            ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "Work Start",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                ratio *
                                                                                6,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              ratio *
                                                                              3,
                                                                        ),
                                                                        (punchIntime !=
                                                                                '')
                                                                            ? Container(
                                                                              width:
                                                                                  ratio *
                                                                                  30,
                                                                              height:
                                                                                  ratio *
                                                                                  9,
                                                                              color:
                                                                                  Colors.white,
                                                                              child: Center(
                                                                                child: Text(
                                                                                  punchIntime,
                                                                                  style: TextStyle(
                                                                                    fontSize:
                                                                                        ratio *
                                                                                        6,
                                                                                    color:
                                                                                        Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                            : Text(
                                                                              "-",
                                                                            ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Expanded(
                                                                    flex: 1,
                                                                    child: Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Text(
                                                                          "Work End",
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                ratio *
                                                                                6,
                                                                            color:
                                                                                Colors.black,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              ratio *
                                                                              3,
                                                                        ),
                                                                        (punchOuttime !=
                                                                                '')
                                                                            ? Container(
                                                                              width:
                                                                                  ratio *
                                                                                  30,
                                                                              height:
                                                                                  ratio *
                                                                                  9,
                                                                              color:
                                                                                  Colors.white,
                                                                              child: Center(
                                                                                child: Text(
                                                                                  punchOuttime,
                                                                                  style: TextStyle(
                                                                                    fontSize:
                                                                                        ratio *
                                                                                        6,
                                                                                    color:
                                                                                        Colors.black,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            )
                                                                            : Text(
                                                                              "-",
                                                                            ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                            : Text(""),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: ratio * 3),
                        Container(
                          width: deviceWidth * 0.9,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Total Present Box
                              Container(
                                width: deviceWidth * 0.27,
                                padding: EdgeInsets.symmetric(
                                  vertical: ratio * 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    ratio * 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Present',
                                      style: TextStyle(
                                        fontSize: ratio * 4.8,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: ratio * 1.5),
                                    CircleAvatar(
                                      radius: ratio * 6.5,
                                      backgroundColor: Colors.blue,
                                      child: Text(
                                        "$totalPresent",
                                        style: TextStyle(
                                          fontSize: ratio * 5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Total Absent Box
                              Container(
                                width: deviceWidth * 0.27,
                                padding: EdgeInsets.symmetric(
                                  vertical: ratio * 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    ratio * 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Absent',
                                      style: TextStyle(
                                        fontSize: ratio * 4.8,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: ratio * 1.5),
                                    CircleAvatar(
                                      radius: ratio * 6.5,
                                      backgroundColor: Colors.red,
                                      child: Text(
                                        "$totalAbsent",
                                        style: TextStyle(
                                          fontSize: ratio * 5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Total Days Box
                              Container(
                                width: deviceWidth * 0.27,
                                padding: EdgeInsets.symmetric(
                                  vertical: ratio * 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    ratio * 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Total Days',
                                      style: TextStyle(
                                        fontSize: ratio * 4.8,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: ratio * 1.5),
                                    CircleAvatar(
                                      radius: ratio * 6.5,
                                      backgroundColor: Colors.green,
                                      child: Text(
                                        "$totalDays",
                                        style: TextStyle(
                                          fontSize: ratio * 5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          //stop
                          padding: EdgeInsets.only(top: ratio * 5, bottom: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              ratio * 10,
                            ), // Optional: Adds rounded corners
                          ),
                          width: deviceWidth * 0.9,
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
                                        style: TextStyle(fontSize: ratio * 7),
                                      ),
                                      Image.asset(
                                        'assets/images/attendance.png',
                                        width: deviceWidth * 0.3,
                                        height: deviceWidth * 0.25,
                                      ),
                                      (Mainstatus == "" ||
                                              Mainstatus == 'punchout')
                                          ? ElevatedButton(
                                            onPressed: () async {
                                              punchIn();
                                            },
                                            child: Text("Punch in"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF03a9f4,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: deviceWidth * 0.05,
                                                vertical: 4,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      MediaQuery.of(
                                                            context,
                                                          ).size.width *
                                                          0.07,
                                                    ),
                                              ),
                                              elevation: 4,
                                            ),
                                          )
                                          : ElevatedButton(
                                            onPressed: () async {
                                              punchOutAlert(context);
                                            },
                                            child: Text("Punch Out"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color(
                                                0xFF03a9f4,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: deviceWidth * 0.05,
                                                vertical: 4,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      deviceWidth * 0.07,
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
                                          fontSize: ratio * 7,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Image.asset(
                                        'assets/images/visit.png',
                                        width: deviceWidth * 0.3,
                                        height: deviceWidth * 0.25,
                                      ),
                                      (visitStatus == 'opne')
                                          ? ElevatedButton(
                                            onPressed: () {
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
                                              backgroundColor: Color(
                                                0xFF03a9f4,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: deviceWidth * 0.05,
                                                vertical: 4,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      deviceWidth * 0.07,
                                                    ),
                                              ),
                                              elevation: 4,
                                            ),
                                          )
                                          : ElevatedButton(
                                            onPressed: () async {
                                              if (Mainstatus != '' &&
                                                  Mainstatus == 'punchin') {
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
                                              backgroundColor: Color(
                                                0xFF03a9f4,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: deviceWidth * 0.05,
                                                vertical: 4,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      deviceWidth * 0.07,
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
                        SizedBox(height: ratio * 2),
                        Container(
                          padding: EdgeInsets.only(top: ratio * 5, bottom: 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Optional: Adds rounded corners
                          ),
                          width: deviceWidth * 0.9,
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
                                      offset: Offset(
                                        0,
                                        3,
                                      ), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text("Break 1"),
                                      (Break1 == 'open' || Break1 == 'close')
                                          ? Column(
                                            children:
                                                statusData.map<Widget>((item) {
                                                  return Column(
                                                    children: [
                                                      Text(
                                                        'Start',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item['break1in'] ?? '0'}',
                                                        style: TextStyle(
                                                          fontSize: ratio * 5,
                                                        ),
                                                      ),
                                                      Text(
                                                        'End',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item['break1out'] ?? '-'}',
                                                        style: TextStyle(
                                                          fontSize: ratio * 5,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                          )
                                          : Image.asset(
                                            'assets/images/Break.png',
                                            width: deviceWidth * 0.12,
                                            height: deviceWidth * 0.12,
                                          ),
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                (Mainstatus == '' ||
                                                        Mainstatus ==
                                                            'punchout')
                                                    ? {}
                                                    : (Break1 == '' ||
                                                        Break1 == 'open')
                                                    ? BreakAlert(
                                                      context,
                                                      'break1',
                                                      (Break1 == '')
                                                          ? 'Are You Shore For Break'
                                                          : (Break1 == 'open')
                                                          ? "Are You Shore For Break End"
                                                          : '',
                                                      (Break1 == '')
                                                          ? 'Break In'
                                                          : (Break1 == 'open')
                                                          ? "Break End"
                                                          : '',
                                                    )
                                                    : {},

                                        child:
                                            (Break1 == '')
                                                ? Text("Start")
                                                : (Break1 == 'open')
                                                ? Text("End")
                                                : Text("End"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              (Break1 == 'close' ||
                                                      Mainstatus == '' ||
                                                      Mainstatus == 'punchout')
                                                  ? Colors.red
                                                  : Color(0xFF03a9f4),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: deviceWidth * 0.05,
                                            vertical: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              deviceWidth * 0.07,
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
                                      offset: Offset(
                                        0,
                                        3,
                                      ), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text("Break 2"),
                                      (Break2 == 'open' || Break2 == 'close')
                                          ? Column(
                                            children:
                                                statusData.map<Widget>((item) {
                                                  return Column(
                                                    children: [
                                                      Text(
                                                        'Start',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item['break2in'] ?? '0'}',
                                                        style: TextStyle(
                                                          fontSize: ratio * 5,
                                                        ),
                                                      ),
                                                      Text(
                                                        'End',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item['break2out'] ?? '-'}',
                                                        style: TextStyle(
                                                          fontSize: ratio * 5,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                          )
                                          : Image.asset(
                                            'assets/images/Break.png',
                                            width: deviceWidth * 0.12,
                                            height: deviceWidth * 0.12,
                                          ),
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                (Mainstatus == '' ||
                                                        Mainstatus ==
                                                            'punchout')
                                                    ? {}
                                                    : (Break1 == 'close') &&
                                                        (Break2 == '' ||
                                                            Break2 == 'open')
                                                    ? BreakAlert(
                                                      context,
                                                      'break2',
                                                      (Break2 == '')
                                                          ? 'Are You Shore For Break'
                                                          : (Break2 == 'open')
                                                          ? "Are You Shore For Break End"
                                                          : '',
                                                      (Break2 == '')
                                                          ? 'Break In'
                                                          : (Break2 == 'open')
                                                          ? "Break End"
                                                          : '',
                                                    )
                                                    : {},
                                        child:
                                            (Break2 == '')
                                                ? Text("Start")
                                                : (Break2 == 'open')
                                                ? Text("End")
                                                : Text("End"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              (Break2 == 'close' ||
                                                      Mainstatus == '' ||
                                                      Mainstatus == 'punchout')
                                                  ? Colors.red
                                                  : Color(0xFF03a9f4),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: deviceWidth * 0.05,
                                            vertical: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              deviceWidth * 0.07,
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
                                      offset: Offset(
                                        0,
                                        3,
                                      ), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Text("Break 3"),
                                      (Break3 == 'open' || Break3 == 'close')
                                          ? Column(
                                            children:
                                                statusData.map<Widget>((item) {
                                                  return Column(
                                                    children: [
                                                      Text(
                                                        'Start',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item['break3in'] ?? '0'}',
                                                        style: TextStyle(
                                                          fontSize: ratio * 5,
                                                        ),
                                                      ),
                                                      Text(
                                                        'End',
                                                        style: TextStyle(
                                                          fontSize: ratio * 6,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${item['break3out'] ?? '-'}',
                                                        style: TextStyle(
                                                          fontSize: ratio * 5,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }).toList(),
                                          )
                                          : Image.asset(
                                            'assets/images/Break.png',
                                            width: deviceWidth * 0.12,
                                            height: deviceWidth * 0.12,
                                          ),
                                      ElevatedButton(
                                        onPressed:
                                            () =>
                                                (Mainstatus == '' ||
                                                        Mainstatus ==
                                                            'punchout')
                                                    ? {}
                                                    : (Break2 == 'close') &&
                                                        (Break3 == '' ||
                                                            Break3 == 'open')
                                                    ? BreakAlert(
                                                      context,
                                                      'break3',
                                                      (Break3 == '')
                                                          ? 'Are You Shore For Break'
                                                          : (Break3 == 'open')
                                                          ? "Are You Shore For Break End"
                                                          : '',
                                                      (Break3 == '')
                                                          ? 'Break In'
                                                          : (Break3 == 'open')
                                                          ? "Break End"
                                                          : '',
                                                    )
                                                    : {},
                                        child:
                                            (Break3 == '')
                                                ? Text("Start")
                                                : (Break3 == 'open')
                                                ? Text("End")
                                                : Text("End"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              (Break3 == 'close' ||
                                                      Mainstatus == '' ||
                                                      Mainstatus == 'punchout')
                                                  ? Colors.red
                                                  : Color(0xFF03a9f4),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: deviceWidth * 0.05,
                                            vertical: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              deviceWidth * 0.07,
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
                          padding: EdgeInsets.only(top: ratio * 5, bottom: 0),
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
                                        style: TextStyle(fontSize: ratio * 7),
                                      ),
                                      Image.asset(
                                        'assets/images/Att  Report.png',
                                        width: deviceWidth * 0.25,
                                        height: deviceWidth * 0.20,
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) => EmpAttdetail(),
                                              ),
                                            ),
                                        child: Text("View"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF03a9f4),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: deviceWidth * 0.05,
                                            vertical: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              deviceWidth * 0.07,
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
                                        style: TextStyle(fontSize: ratio * 7),
                                      ),
                                      Image.asset(
                                        'assets/images/visit_report.png',
                                        width: deviceWidth * 0.25,
                                        height: deviceWidth * 0.20,
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => Empvisitrep(),
                                              ),
                                            ),
                                        child: Text("View"),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF03a9f4),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.05,
                                            vertical: 4,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              deviceWidth * 0.07,
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
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
/*  */