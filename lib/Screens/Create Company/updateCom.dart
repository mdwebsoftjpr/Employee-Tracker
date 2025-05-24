import 'dart:convert';
import 'dart:io';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';

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
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String userImg = '';

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

  final picker = ImagePicker();

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
          userImg = user['image'];
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

 Future<void> pickImage(context) async {
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    final compressed = await compressImage(pickedFile);
    if (compressed != null && await compressed.length() <= 15 * 1024) {
      if (mounted) {
        setState(() => _imageFile = compressed);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to compress image under 15KB.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }
}



Future<File?> compressImage(XFile xFile) async {
  if (!mounted) return null;
  setState(() => isLoading = true);

  final File file = File(xFile.path);
  final dir = await getTemporaryDirectory();
  const int maxSizeInBytes = 15 * 1024;
  int minWidth = 300;
  int minHeight = 300;
  File? compressedFile;

  for (int quality = 60; quality >= 10; quality -= 5) {
    final String targetPath = join(
        dir.path, 'compressed_${quality}_${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}');

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
      }
    }

    minWidth = (minWidth * 0.85).toInt();
    minHeight = (minHeight * 0.85).toInt();
  }

  if (mounted) setState(() => isLoading = false);
  return compressedFile;
}





 void company_update(context) async {
  if (!mounted) return;
  setState(() => isLoading = true);

  if (_formKey.currentState?.validate() ?? false) {
    if (userdata == null) {
      if (mounted) setState(() => isLoading = false);
      Alert.alert(context, 'User data not loaded.');
      return;
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://testapi.rabadtechnology.com/company_update.php'),
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
    });

    if (_imageFile != null) {
      final imgSize = await _imageFile!.length();
      if (imgSize > 15 * 1024) {
        if (mounted) setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Image must be under 15KB.'),
          backgroundColor: Colors.red,
        ));
        return;
      }
      request.files.add(await http.MultipartFile.fromPath('image', _imageFile!.path));
    }

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);
      final Map<String, dynamic> data = jsonDecode(responseBody.body);

      if (mounted) setState(() => isLoading = false);

      if (data['success'] == true) {
        await Alert.alert(context, 'Thank You ${data['message']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHome()),
        );
      } else {
        Alert.alert(context, data['message']);
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
      Alert.alert(context, 'Error: $e');
    }
  } else {
    if (mounted) setState(() => isLoading = false);
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
      TextCapitalization textCapitalization = TextCapitalization.none,
      Widget? suffixIcon,
    }) {
      return TextFormField(
        controller: controller,
        decoration: buildInput(label, icon).copyWith(suffixIcon: suffixIcon),
        obscureText: obscure,
        validator: validator,
        inputFormatters: inputFormatters,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Update Company Details',
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
              : userdata == null
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 5),
                      _imageFile != null
                          ? CircleAvatar(
                            radius: size.width * 0.18,
                            backgroundImage: FileImage(_imageFile!),
                          )
                          : CircleAvatar(
                            radius: size.width * 0.18,
                            backgroundImage: NetworkImage(
                              'https://testapi.rabadtechnology.com/$userImg',
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
                        textCapitalization: TextCapitalization.words,
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
                        textCapitalization: TextCapitalization.words,
                        validator:
                            (v) => v!.isEmpty ? 'Key person is required' : null,
                      ),
                      SizedBox(height: 10),
                      buildTextField(
                        controller: Gst,
                        label: 'Enter Your GSTIN No.',
                        icon: Icons.account_balance,
                        inputFormatters: [UpperCaseTextFormatter(),FilteringTextInputFormatter.deny(RegExp(r'\s')),],
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
                        inputFormatters: [UpperCaseTextFormatter(),FilteringTextInputFormatter.deny(RegExp(r'\s')),],
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
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s')),],
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
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s')),],
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
                            color: Colors.white,
                            fontSize: 6*MediaQuery.of(context).devicePixelRatio,
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
