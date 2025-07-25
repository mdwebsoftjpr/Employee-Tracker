import 'dart:convert';
import 'dart:io';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
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

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class UpdateEmp extends StatefulWidget {
  final List<dynamic> item;
  UpdateEmp({required this.item, Key? key}) : super(key: key);

  @override
  UpdateEmpState createState() => UpdateEmpState();
}

class UpdateEmpState extends State<UpdateEmp> {
  String comName = 'Company';
  int? comId;
  File? _imageFile;
  DateTime? selectedDate;
  String? formattedDate;
  bool _obscureText = true;
  final _formKey = GlobalKey<FormState>();
  String? TradeName;
  bool isLoading = false;
  String userImg = '';

  // Declare controllers without initial text
  final TextEditingController name = TextEditingController();
  final TextEditingController dob = TextEditingController();
  final TextEditingController panNo = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController designation = TextEditingController();
  List<Map<String, dynamic>> designationList = [];
  final TextEditingController adharNo = TextEditingController();
  final TextEditingController salary = TextEditingController();
  final TextEditingController hours = TextEditingController();
  final TextEditingController joinOfDate = TextEditingController();

  String? selectedValue;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.item.isNotEmpty) {
      var data = widget.item[0];
      setState(() {
        userImg = data['image'];
      });
      name.text = data['name'].toString() ?? '';
      dob.text = data['dob'].toString() ?? '';
      panNo.text = data['pan_card'].toString() ?? '';
      mobile.text = data['mobile_no'].toString() ?? '';
      email.text = data['email'].toString() ?? '';
      address.text = data['address'].toString() ?? '';
      username.text = data['username'].toString() ?? '';
      password.text = data['password'].toString() ?? '';
      designation.text = data['designation'].toString() ?? '';
      adharNo.text = data['aadharcard']?.toString() ?? '';
      salary.text = data['salary']?.toString() ?? '';
      hours.text = data['hours']?.toString() ?? '';
      joinOfDate.text = data['doinofdate'].toString() ?? '';
    }

    _loadUser();
    ShowMaster(context);
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        comId = user['id'] ?? 0;
        TradeName = user['trade_name'] ?? '';
      });
    }
  }

  Future<File?> compressImage(XFile xFile) async {
    setState(() {
      isLoading = true;
    });
    final File file = File(xFile.path);
    final dir = await getTemporaryDirectory();
    final targetPath = join(dir.path, 'compressed_${basename(file.path)}');

    int quality = 70;
    File? compressedFile;
    const int maxSizeInBytes = 100 * 1024; // 100 KB

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
      preferredCameraDevice: CameraDevice.front, imageQuality: 20,
      maxWidth: 600,
      maxHeight: 600,
    );

    if (pickedFile != null) {
      File? compressed = await compressImage(pickedFile);

      setState(() {
        _imageFile = compressed ?? File(pickedFile.path);
      });
    }
  }

  void ShowMaster(context) async {
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/getdesignation.php',
    );
    final Map<String, dynamic> requestBody = {"company_id": comId.toString()};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        setState(() {
          designationList = List<Map<String, dynamic>>.from(
            responseData['data'],
          );
          Alert.alert(context, responseData['message']);
        });
      } else {
        Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      Alert.alert(context, e.toString());
    }
  }

  Future<void> _pickDateDob(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1947),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('yyyy-MM-dd').format(picked);

        dob.text = formattedDate!;
      });
    }
  }

  Future<void> _pickDateJoin(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1975),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        formattedDate = DateFormat('yyyy-MM-dd').format(picked);

        joinOfDate.text = formattedDate!;
      });
    }
  }

  Future<void> Update_Emp(BuildContext context) async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      File? compressedImage;

      // Compress image only if user selected one
      if (_imageFile != null) {
        compressedImage = await compressImage(XFile(_imageFile!.path));
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://testapi.rabadtechnology.com/employee_update.php'),
      );

      request.fields.addAll({
        "company_id": comId.toString(),
        "trade_name": TradeName.toString(),
        "name": name.text,
        "dob": dob.text,
        "pan_card": panNo.text,
        "mobile_no": mobile.text,
        "email": email.text,
        "address": address.text,
        "username": username.text,
        "password": password.text,
        "designation": designation.text,
        "aadharcard": adharNo.text,
        "salary": salary.text,
        "hours": hours.text,
        "emp_id": widget.item[0]['id']?.toString() ?? '',
        "joinofdate": joinOfDate.text,
      });

      // Only add image file if available
      if (compressedImage != null && compressedImage.existsSync()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', compressedImage.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
        Alert.alert(context, 'Successfully ${responseData['message']}');
      } else {
        Alert.alert(context, responseData['message'] ?? 'Update failed');
      }
    } catch (e) {
      Alert.alert(context, 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Update Employee Details',
          style: TextStyle(
            fontSize:ratio*9,
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
                      radius:ratio*25,
                      backgroundImage: AssetImage(
                        'assets/splesh_Screen/Emp_Attend.png',
                      ), // Set the background image here
                    ),

                    SizedBox(height: 5),
                    CircularProgressIndicator(color: Color(0xFF03a9f4)),
                  ],
                ),
              )
              : Container(
                padding: EdgeInsets.only(
                  top: 0,
                  left:deviceWidth* 0.07,
                  right: deviceWidth * 0.07,
                  bottom: 0,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        CircleAvatar(
                          radius: deviceWidth * 0.18,
                          backgroundImage:
                              _imageFile != null
                                  ? FileImage(_imageFile!) as ImageProvider
                                  : NetworkImage(
                                    '$userImg',
                                  ), // Optional: you can leave this if you want a fallback color
                        ),

                        ElevatedButton(
                          onPressed: () => _pickImageFromCamera(),
                          child: Container(
                            width:deviceWidth * 0.37,
                            child: Row(
                              children: [
                                Text(
                                  "Profile Picture",
                                  style: TextStyle(
                                    fontSize: ratio*7,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.edit, color: Colors.black),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: name,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Enter Name',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.person),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: dob,
                          decoration: InputDecoration(
                            labelText: 'Enter Date Of Birth',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.date_range),
                            suffixIcon: IconButton(
                              onPressed: () => _pickDateDob(context),
                              icon: Icon(Icons.calendar_month),
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Date Of Birth';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: designation,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Choose Designation',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                               ratio*7,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.badge),
                            suffixIcon: Icon(Icons.arrow_drop_down),
                          ),
                          onTap: () async {
                            final selected = await showDialog<String>(
                              context: context,
                              builder: (BuildContext context) {
                                return SimpleDialog(
                                  title: Text('Choose Designation'),
                                  children:
                                      designationList.map((option) {
                                        return SimpleDialogOption(
                                          onPressed: () {
                                            Navigator.pop(
                                              context,
                                              option['designationname'],
                                            );
                                          },
                                          child: Text(
                                            option['designationname'],
                                          ),
                                        );
                                      }).toList(),
                                );
                              },
                            );

                            if (selected != null) {
                              designation.text = selected;
                              setState(() {
                                selectedValue = selected;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an option';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: panNo,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                            UpperCaseTextFormatter(),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Enter PAN Card No.',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.credit_card),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Pan Card No.';
                            } else if (value.length != 10) {
                              return 'Pan Card No. must be 10 digits';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          controller: mobile,
                          decoration: InputDecoration(
                            labelText: 'Enter Mobile No.',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                 ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Mobile No.';
                            } else if (value.length != 10) {
                              return 'Mobile number must be 10 digits';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: email,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Enter Email',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.email),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          controller: address,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Enter Address',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.home),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: adharNo,
                          decoration: InputDecoration(
                            labelText: 'Enter Addhar Card No.',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Addhar Card No.';
                            } else if (value.length != 12) {
                              return 'Addhar Card No. must be 12 digits';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          controller: salary,
                          decoration: InputDecoration(
                            labelText: 'Enter Salary',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                 ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                               ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(
                              FontAwesomeIcons.indianRupeeSign,
                              size: 18,
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Salary';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          controller: hours,
                          decoration: InputDecoration(
                            labelText: 'Enter Working Hours',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Working Hours';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: joinOfDate,
                          decoration: InputDecoration(
                            labelText: 'Enter Joinning Date',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.date_range),
                            suffixIcon: IconButton(
                              onPressed: () => _pickDateJoin(context),
                              icon: Icon(Icons.calendar_today),
                            ),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Joinning Date';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: username,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Enter User Name',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ), // Set the border radius
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.account_circle),
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter User Name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: password,
                          inputFormatters: [
                            FilteringTextInputFormatter.deny(RegExp(r'\s')),
                          ],
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: 'Enter Password',
                            contentPadding: EdgeInsets.symmetric(
                              vertical:
                                  ratio*7,
                              horizontal:
                                  ratio*7,
                            ),
                            labelStyle: TextStyle(
                              color: Colors.black,
                              fontSize:
                                  ratio*7,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                ratio*7,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter Password';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () => Update_Emp(context),
                          child: Text(
                            "Update Employee",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  ratio*7,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF03a9f4),
                          ),
                        ),
                        SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
