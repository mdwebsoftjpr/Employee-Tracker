import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Home%20Screen/EmpHome.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class VisitOut extends StatefulWidget {
  @override
  VisitOutState createState() => VisitOutState();
}

class VisitOutState extends State<VisitOut> {
  String? userdata;
  int? empid;
  int? comid;
  int? VisitId;
  String? trade_name;
  bool isLoading = false;

  void initState() {
    super.initState();
    _loadUser();
    _initializeData();
  }

  Future<void> _initializeData() async {
    getId();
    getCurrentAddress();
    autofillAddress();
    await getCurrentLocation();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      try {
        var user = jsonDecode(userJson);
        setState(() {
          empid = user['id'] ?? 0;
          comid = user['company_id'] ?? 0;
          trade_name = user['trade_name'] ?? 0;
        });
        print("$comid,$empid");
      } catch (e) {
        print("Error decoding user data: $e");
      }
    }
  }

  void getId() async {
    try {
      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/getvisitstatus.php',
      );
      final Map<String, dynamic> requestBody = {
        "emp_id": empid.toString(),
        "company_id": comid.toString(),
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      var data = responseData['data'];
      for (var item in data) {
        setState(() {
          VisitId = item['id'];
        });
      }
    } catch (e) {
      Alert.alert(context, "Error fetching data: $e");
    }
  }

  final _formKey = GlobalKey<FormState>();

  final TextEditingController organization = TextEditingController();
  final TextEditingController concernedPerson = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController item = TextEditingController();
  final TextEditingController value = TextEditingController();
  final TextEditingController probability = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController remark = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;

  int? _selectedValue = 1;
  List<bool> selectedTransportModes = [false, false, false];
  String? lat;
  String? long;
  String? deviceId;

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

  Future<void> getCurrentAddress() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    String foundAddress =
        "${place.street}, ${place.locality}, ${place.country}";

    setState(() {
      address.text = foundAddress;
    });
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled. Please enable them.');
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permission permanently denied.');
      return;
    }

    // ✅ Get the position now
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      // Get latitude and longitude
      double latitude = position.latitude;
      double longitude = position.longitude;
      setState(() {
        lat = latitude.toString();
        long = longitude.toString();
      });
      print('Latitude: $latitude, Longitude: $longitude');
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void autofillAddress() {
    setState(() {
      address.text = 'Address Automatically Picked';
    });
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
    );

    if (pickedFile != null) {
      File? compressed = await compressImage(pickedFile);

      setState(() {
        _imageFile = compressed != null ? XFile(compressed.path) : pickedFile;
      });
    }
  }

  void VisitOut(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState?.validate() ?? false) {
      String Corganization = organization.text;
      String CconcernedPerson = concernedPerson.text;
      String Cphone = phone.text;
      String Citem = item.text;
      String Cvalue = value.text;
      String Cprobability = probability.text;
      String Caddress = address.text;
      String Cremark = remark.text;

      String modeOfTransport = '';
      if (selectedTransportModes[0]) modeOfTransport += 'Air ';
      if (selectedTransportModes[1]) modeOfTransport += 'Surface ';
      if (selectedTransportModes[2]) modeOfTransport += 'Extrain ';

      String weather =
          _selectedValue == 1
              ? 'Hot'
              : _selectedValue == 2
              ? 'Rain'
              : 'Cold';

      if (_imageFile == null) {
        Alert.alert(context, 'Please capture a photo');
        return;
      }

      try {
        // Prepare the multipart request
        var url = Uri.parse(
          "https://testapi.rabadtechnology.com/employee_activity_update.php",
        );
        var request = http.MultipartRequest('POST', url);

        // Add the image file to the request
        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );

        // Add other fields to the request
        request.fields['NameOfCustomer'] = Corganization;
        request.fields['concernedperson'] = CconcernedPerson;
        request.fields['trade_name'] = trade_name.toString();
        request.fields['phoneno'] = Cphone;
        request.fields['item'] = Citem;
        request.fields['volume'] = Cvalue;
        request.fields['transport'] = modeOfTransport.trim();
        request.fields['Probablity'] = Cprobability;
        request.fields['address'] = Caddress;
        request.fields['Remark'] = Cremark;
        request.fields['Prospects'] = weather;
        request.fields['diviceid'] = "$deviceId";
        request.fields['location'] = "$lat,$long";
        request.fields['id'] = VisitId.toString();
        // Send the request
        var response = await request.send();

        // Get the response and handle it
        var responseData = await Response.fromStream(response);
        var data = jsonDecode(responseData.body);
        print(data);

        if (response.statusCode == 200) {
          if (data['success'] == true) {
            localStorage.deleteItem('visitId');
            setState(() {
              isLoading = false;
            });
            await Alert.alert(context, data['message']);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => EmpHome()),
            );
          } else {
            setState(() {
              isLoading = false;
            });
            Alert.alert(context, data['message'] ?? "Submission failed");
          }
        } else {
          setState(() {
            isLoading = false;
          });
          Alert.alert(context, "Server error: ${response.statusCode}");
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, "Upload error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Visit Out',
          style: TextStyle(
            fontSize: 6*MediaQuery.of(context).devicePixelRatio,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius:
                          MediaQuery.of(context).size.width *
                          0.16, // Adjust the radius dynamically based on screen width
                      backgroundImage: AssetImage(
                        'assets/splesh_Screen/Emp_Attend.png',
                      ), // Set the background image here
                    ),

                    SizedBox(height: 5),
                    CircularProgressIndicator(color: Color(0xFF03a9f4)),
                  ],
                ),
              )
              : SingleChildScrollView(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    width: MediaQuery.of(context).size.width,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextField(
                            controller: organization,
                            label: 'Enter Organization',
                          ),
                          buildTextField(
                            controller: concernedPerson,
                            label: 'Enter Concerned Person',
                          ),
                          buildTextField(
                            controller: phone,
                            label: 'Enter Phone No.',
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter Your Mobile No.';
                              } else if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                                return 'Mobile number must be exactly 10 digits';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: buildTextField(
                                  controller: item,
                                  label: 'Enter Items',
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: buildTextField(
                                  controller: value,
                                  label: 'Enter Value',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Mode Of Transport",
                            style: TextStyle(fontSize: 20),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildCheckbox("Air", 0),
                              buildCheckbox("Surface", 1),
                              buildCheckbox("Extrain", 2),
                            ],
                          ),
                          buildTextField(
                            controller: probability,
                            label: 'Enter Probability %',
                          ),
                          SizedBox(height: 10),
                          Text("Propetion", style: TextStyle(fontSize: 20)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildRadio("Hot", 1),
                              buildRadio("Rain", 2),
                              buildRadio("Cold", 3),
                            ],
                          ),
                          buildTextField(
                            controller: address,
                            label: 'Enter Address',
                          ),
                          buildTextField(
                            controller: remark,
                            label: 'Enter Remark',
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _pickImageFromCamera,
                                child: Text(
                                  "Take Photo",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF03a9f4),
                                ),
                              ),
                              SizedBox(width: 10),
                              _imageFile != null
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_imageFile!.path),
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[300],
                                  ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () => VisitOut(context),
                            child: Text(
                              "Visit Out",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 6*MediaQuery.of(context).devicePixelRatio,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF03a9f4),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }

  // Reusable text field
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
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
        ),
        validator: validator,
        keyboardType: keyboardType,
      ),
    );
  }

  // Reusable checkbox
  Widget buildCheckbox(String label, int index) {
    return Row(
      children: [
        Checkbox(
          value: selectedTransportModes[index],
          onChanged: (bool? value) {
            setState(() {
              selectedTransportModes[index] = value ?? false;
            });
          },
        ),
        Text(label),
      ],
    );
  }

  // Reusable radio
  Widget buildRadio(String label, int value) {
    return Row(
      children: [
        Radio<int>(
          value: value,
          groupValue: _selectedValue,
          onChanged: (int? newValue) {
            setState(() {
              _selectedValue = newValue;
            });
          },
        ),
        Text(label),
      ],
    );
  }
}
