import 'dart:convert';
import 'dart:io';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(CreateCom());
}

class CreateCom extends StatefulWidget {
  @override
  CreateComState createState() => CreateComState();
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

class CreateComState extends State<CreateCom> {
  final ImagePicker picker = ImagePicker();
  File? _imageFile;
  bool TermCondition = false;
  bool privacyPolicy = false;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  final TextEditingController cname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController Gst = TextEditingController();
  final TextEditingController Tradename = TextEditingController();
  final TextEditingController keyPerson = TextEditingController();
  final TextEditingController loginUserName = TextEditingController();
  final TextEditingController website = TextEditingController();
  final TextEditingController PanNo = TextEditingController();
  final TextEditingController NoOfEmp = TextEditingController();

  Future<void> pickImage(context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final compressed = await compressImage(pickedFile);
      if (compressed != null) {
        setState(() {
          _imageFile = compressed;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image compression failed or image too large.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<File?> compressImage(XFile xFile) async {
    if (!mounted) return null;

    setState(() {
      isLoading = true;
    });

    final file = File(xFile.path);
    final dir = await getTemporaryDirectory();
    final String base = basename(file.path);
    File? compressedFile;
    const int maxSizeInBytes = 15 * 1024;
    int minWidth = 400;
    int minHeight = 400;

    for (int quality = 70; quality >= 10; quality -= 10) {
      final targetPath = join(dir.path, 'compressed_${quality}_$base');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        format: CompressFormat.jpeg,
      );

      if (result != null) {
        final length = await result.length();
        if (length <= maxSizeInBytes) {
          compressedFile = File(result.path);
          break;
        } else {
          minWidth = (minWidth * 0.85).toInt();
          minHeight = (minHeight * 0.85).toInt();
        }
      }
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    return compressedFile;
  }

  void compLogin(context) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    if (_formKey.currentState?.validate() ?? false) {
      if (!TermCondition || !privacyPolicy) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!TermCondition
                ? 'Please accept the terms and conditions.'
                : 'Please accept the privacy policy.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_imageFile == null || await _imageFile!.length() > 15 * 1024) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a logo image under 15KB.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://testapi.rabadtechnology.com/create.php'),
      );

      request.fields.addAll({
        'company_name': cname.text,
        'trade_name': Tradename.text,
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

      request.files.add(
        await http.MultipartFile.fromPath('image', _imageFile!.path),
      );

      try {
        var response = await request.send();
        final responseBody = await http.Response.fromStream(response);
        final Map<String, dynamic> data = jsonDecode(responseBody.body);

        if (data['success'] == true) {
          if (mounted) {
            setState(() => isLoading = false);
          }
          await Alert.alert(context, data['message']);
          Navigator.pop(context); // Replace with desired screen
        } else {
          if (mounted) {
            setState(() => isLoading = false);
          }
          Alert.alert(context, data['message']);
        }
      } catch (e) {
        if (mounted) {
          setState(() => isLoading = false);
        }
        await Alert.alert(context, 'Error: $e');
      }
    } else {
      if (mounted) {
        setState(() => isLoading = false);
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
          'Create Company',
          style: TextStyle(
            fontSize: 18,
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
                        onPressed:()=> pickImage(context),
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

                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
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
                          ),
                          SizedBox(width: 8),
                          TextButton(onPressed: () {}, child: Text("Verify")),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
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
                          ),
                          SizedBox(width: 8),
                          TextButton(onPressed: () {}, child: Text("Verify")),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              controller: email,
                              label: 'Enter Your Email',
                              icon: Icons.email,
                              validator:
                                  (v) =>
                                      !v!.contains('@')
                                          ? 'Invalid email'
                                          : null,
                            ),
                          ),
                          SizedBox(width: 8),
                          TextButton(onPressed: () {}, child: Text("Verify")),
                        ],
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
                          SizedBox(width: 5,),
                          InkWell(
                            onTap: () async {
                              const url = 'https://testapi.rabadtechnology.com/term-and-condition.html';
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
                                  'Terms & Conditions',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
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
                          SizedBox(width: 5,),
                          InkWell(
                            onTap: () async {
                              const url = 'https://testapi.rabadtechnology.com/privacy.html';
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
                                  'Privacy Policy',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => compLogin(context),
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
                          'Create Company',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
