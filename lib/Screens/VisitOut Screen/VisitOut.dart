import 'package:employee_tracker/Screens/Home%20Screen/EmpHome.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: VisitOut()));
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

  void initState(){
    super.initState();
    getCurrentAddress();
    autofillAddress();
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

Future<void> getCurrentAddress() async {
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark place = placemarks[0];

  String foundAddress = "${place.street}, ${place.locality}, ${place.country}";

  setState(() {
    address.text = foundAddress;
  });
}


void autofillAddress() {
  setState(() {
    address.text = 'Address Automatically Picked';
  });
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

 void VisitOut(context) async {
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

    String weather = _selectedValue == 1
        ? 'Hot'
        : _selectedValue == 2
            ? 'Rain'
            : 'Cold';

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please capture a photo')),
      );
      return;
    }

    try {
      // Read image file and convert to base64
      File imageFile = File(_imageFile!.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      var data = {
        "organization": Corganization,
        "concernedperson": CconcernedPerson,
        "phoneno": Cphone,
        "item": Citem,
        "value": Cvalue,
        "transport": modeOfTransport.trim(),
        "Probablity": Cprobability,
        "address": Caddress,
        "Remark": Cremark,
        "weather": weather,
        "imagepunch": base64Image,
      };

      var response = await http.post(
        Uri.parse("https://testapi.rabadtechnology.com/visit_out.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );


      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        print(responseData);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
         localStorage.setItem('visitout', true);
          Navigator.push(context, MaterialPageRoute(builder: (_) => EmpHome()));
         
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'] ?? "Submission failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Something went wrong")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Visit Out',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                  buildTextField(controller: phone, label: 'Enter Phone No.'),
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
                  Text("Mode Of Transport", style: TextStyle(fontSize: 20)),
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
                  buildTextField(controller: address, label: 'Enter Address'),
                  buildTextField(controller: remark, label: 'Enter Remark'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _pickImageFromCamera,
                        child: Text("Take Photo"),
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
                    child: Text("Visit Out"),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
        validator:
            (value) => value == null || value.isEmpty ? 'Required' : null,
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
