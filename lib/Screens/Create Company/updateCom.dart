import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:localstorage/localstorage.dart';

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Updatecom extends StatefulWidget {
  @override
  UpdatecomState createState() => UpdatecomState();
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class UpdatecomState extends State<Updatecom> {
  Map<String, dynamic>? userdata;
  File? _imageFile;
  bool TermCondition = false;
  bool privacyPolicy = false;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController cname;
  late TextEditingController email;
  late TextEditingController mobile;
  late TextEditingController password;
  late TextEditingController address;
  late TextEditingController Gst;
  late TextEditingController Tradename;
  late TextEditingController keyPerson;
  late TextEditingController loginUserName;
  late TextEditingController website;
  late TextEditingController PanNo;
  late TextEditingController NoOfEmp;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    cname = TextEditingController();
    email = TextEditingController();
    mobile = TextEditingController();
    password = TextEditingController();
    address = TextEditingController();
    Gst = TextEditingController();
    Tradename = TextEditingController();
    keyPerson = TextEditingController();
    loginUserName = TextEditingController();
    website = TextEditingController();
    PanNo = TextEditingController();
    NoOfEmp = TextEditingController();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      try {
        var user = jsonDecode(userJson);
        setState(() {
          userdata = user;
          cname.text = user['company_name'] ?? '';
          email.text = user['db_email'] ?? '';
          mobile.text = user['mobile_no'] ?? '';
          password.text = user['password'] ?? '';
          address.text = user['address'] ?? '';
          Gst.text = user['gstin_no'] ?? '';
          Tradename.text = user['trade_name'] ?? '';
          keyPerson.text = user['key_person'] ?? '';
          loginUserName.text = user['username'] ?? '';
          website.text = user['website_link'] ?? '';
          PanNo.text = user['pan_card'] ?? '';
          NoOfEmp.text = user['noofemp'] ?? '';
        });
      } catch (e) {
        print("Error decoding user data: $e");
      }
    }
  }

  @override
  void dispose() {
    cname.dispose();
    email.dispose();
    mobile.dispose();
    password.dispose();
    address.dispose();
    Gst.dispose();
    Tradename.dispose();
    keyPerson.dispose();
    loginUserName.dispose();
    website.dispose();
    PanNo.dispose();
    NoOfEmp.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      img.Image? image = img.decodeImage(await imageFile.readAsBytes());
      if (image != null) {
        int quality = 85;
        Uint8List compressedBytes = Uint8List.fromList(
          img.encodeJpg(image, quality: quality),
        );
        while (compressedBytes.lengthInBytes > 75 * 1024 && quality > 10) {
          quality -= 5;
          compressedBytes = Uint8List.fromList(
            img.encodeJpg(image, quality: quality),
          );
        }
        File compressedFile = await _saveCompressedImage(compressedBytes);
        setState(() => _imageFile = compressedFile);
      }
    }
  }

  Future<File> _saveCompressedImage(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/compressed_image.jpg';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return file;
  }

  void company_update(context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!TermCondition || !privacyPolicy) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please accept all terms and policies'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'https://testapi.rabadtechnology.com/company_update.php',
        ), // change to your update endpoint
      );

      request.fields.addAll({
        'company_id': userdata!['id'].toString(),
        'company_name': cname.text,
        'key_person': keyPerson.text,
        'gstin_no': Gst.text,
        'pan_card': PanNo.text,
        'mobile_no': mobile.text,
        'email': email.text,
        'address': address.text,
        'website_link': website.text,
        'username': loginUserName.text,
        'password': password.text,
        'noofemp': NoOfEmp.text,
        'terms': TermCondition.toString(),
        'conditions': privacyPolicy.toString(),
      });

      if (_imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _imageFile!.path),
        );
      }

      try {
        var response = await request.send();
        final responseBody = await http.Response.fromStream(response);
        final Map<String, dynamic> data = jsonDecode(responseBody.body);
        if (data['success'] == true) {
          await Alert.alert(context, 'Thank You ${data['message']}');
          Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminHome()),
                    );
        } else {
          Alert.alert(context, data['message']);
        }
      } catch (e) {
        Alert.alert(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = MediaQuery.of(context).devicePixelRatio;

    InputDecoration buildInput(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        contentPadding: EdgeInsets.all(4 * scale),
        labelStyle: TextStyle(fontSize: 5 * scale, color: Colors.black),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4 * scale),
        ),
        filled: true,
        fillColor: Colors.grey[200],
        prefixIcon: Icon(icon),
      );
    }

    Widget buildTextField({
      required TextEditingController controller,
      required String label,
      required IconData icon,
      String? Function(String?)? validator,
      bool obscure = false,
      List<TextInputFormatter>? inputFormatters,
      TextInputType? keyboardType,
      Widget? suffixIcon,
    }) {
      return TextFormField(
        controller: controller,
        decoration: buildInput(label, icon).copyWith(suffixIcon: suffixIcon),
        obscureText: obscure,
        validator: validator,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Update Company Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body:
          userdata == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      _imageFile != null
                          ? CircleAvatar(
                            radius: size.width * 0.18,
                            backgroundImage: FileImage(_imageFile!),
                          )
                          : Container(
                            width: size.width * 0.32,
                            height: size.width * 0.32,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                      ElevatedButton(
                        onPressed: _pickImageFromGallery,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Upload Company Logo",
                              style: TextStyle(color: Colors.black),
                            ),
                            Icon(Icons.edit, color: Colors.black),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: cname,
                        label: 'Enter Your Company Name',
                        icon: Icons.business,
                        validator:
                            (v) =>
                                v!.isEmpty ? 'Company name is required' : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: Tradename,
                        label: 'Enter your 10 Digit Id',
                        icon: Icons.apartment,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        validator:
                            (v) =>
                                (v == null || v.length < 6 || v.length > 15)
                                    ? 'ID must be 6-15 characters'
                                    : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: keyPerson,
                        label: 'Enter Your Key Person',
                        icon: Icons.person,
                        validator:
                            (v) => v!.isEmpty ? 'Key person is required' : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: Gst,
                        label: 'Enter Your GSTIN No.',
                        icon: Icons.account_balance,
                        inputFormatters: [UpperCaseTextFormatter()],
                        validator:
                            (v) =>
                                v!.length != 15
                                    ? 'GSTIN must be exactly 15 characters'
                                    : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: PanNo,
                        label: 'Enter Your Pan Card No.',
                        icon: Icons.credit_card,
                        inputFormatters: [UpperCaseTextFormatter()],
                        validator:
                            (v) =>
                                v!.length != 10
                                    ? 'PAN must be 10 characters'
                                    : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: mobile,
                        label: 'Enter Your Mobile No.',
                        icon: Icons.mobile_friendly,
                        keyboardType: TextInputType.phone,
                        validator:
                            (v) =>
                                v!.length != 10
                                    ? 'Mobile number must be 10 digits'
                                    : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: email,
                        label: 'Enter Your Email',
                        icon: Icons.email,
                        validator:
                            (v) => !v!.contains('@') ? 'Invalid email' : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: address,
                        label: 'Enter Your Company Address',
                        icon: Icons.location_on,
                        validator:
                            (v) => v!.isEmpty ? 'Address required' : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: website,
                        label: 'Enter Your Website Link',
                        icon: Icons.web,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: NoOfEmp,
                        label: 'Enter No. Of Employee',
                        icon: Icons.group,
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: loginUserName,
                        label: 'Enter Your Login User Name',
                        icon: Icons.account_circle,
                        validator:
                            (v) =>
                                v!.isEmpty
                                    ? 'Login username is required'
                                    : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: password,
                        label: 'Enter Your Password',
                        icon: Icons.lock,
                        obscure: _obscureText,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        validator:
                            (v) => v!.isEmpty ? 'Password is required' : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed:
                              () =>
                                  setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: TermCondition,
                            onChanged:
                                (v) => setState(() => TermCondition = v!),
                          ),
                          Text("I accept"),
                          TextButton(
                            onPressed: () {},
                            child: Text("Terms & Conditions"),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Checkbox(
                            value: privacyPolicy,
                            onChanged:
                                (v) => setState(() => privacyPolicy = v!),
                          ),
                          Text("I accept"),
                          TextButton(
                            onPressed: () {},
                            child: Text("Privacy Policy"),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => company_update(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF03a9f4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          'Update Company',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
    );
  }
}
