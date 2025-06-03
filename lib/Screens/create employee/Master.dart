import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeLocalStorage();
  runApp(MaterialApp(home: Master()));
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready;
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Master extends StatefulWidget {
  @override
  MasterState createState() => MasterState();
}

class MasterState extends State<Master> {
  String comName = 'Company';
  int? comId;
  List<dynamic> designationList = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController designation = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);
      setState(() {
        comName = user['company_name'] ?? 'Default Company';
        comId = user['id'] ?? 0;
        ShowMaster(); // Only call after comId is loaded
      });
    }
  }

  void ShowMaster() async {
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
          isLoading = false;
          designationList = responseData['data'];
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Alert.alert(context, e);
    }
  }

  void UpdateMaster(String designation, int id) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/updatedesignation.php',
    );
    final Map<String, dynamic> requestBody = {
      "company_id": comId.toString(),
      "designationname": designation,
      "designation_id": id,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        ShowMaster();
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, responseData['message']);
      } else {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Alert.alert(context, e);
    }
  }

  void DeleteMaster(int id) async {
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse(
      'https://testapi.rabadtechnology.com/deletedesignation.php',
    );
    final Map<String, dynamic> requestBody = {"designation_id": id};

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      final responseData = jsonDecode(response.body);
      if (responseData['success']) {
        ShowMaster();
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, responseData['message']);
      } else {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, responseData['message']);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Alert.alert(context, e);
    }
  }

  void AddMaster() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState?.validate() ?? false) {
      final url = Uri.parse(
        'https://testapi.rabadtechnology.com/designationmaster.php',
      );
      final Map<String, dynamic> requestBody = {
        "company_id": comId.toString(),
        "designationname": designation.text,
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            isLoading = false;
          });
          designation.clear();
          ShowMaster();
          Alert.alert(context, responseData['message']);
        }
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        Alert.alert(context, e);
      }
    }
  }

  void _openDropdown(String currentDesignation, int Id) async {
    final TextEditingController _updateController = TextEditingController(
      text: currentDesignation,
    );
    final GlobalKey<FormState> _updateFormKey = GlobalKey<FormState>();
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Designation'),
          content: SingleChildScrollView(
            child: Form(
              key: _updateFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _updateController,
                    decoration: InputDecoration(
                      labelText: 'Enter Your Designation',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: ratio * 7,
                        horizontal: ratio * 7,
                      ),
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontSize: ratio * 7,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          ratio * 7,
                        ), // Set the border radius
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter Working Hours';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      if (_updateFormKey.currentState!.validate()) {
                        Navigator.pop(context); // Close the dialog
                        UpdateMaster(_updateController.text, Id); // Call update
                      }
                    },
                    child: Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF03a9f4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Create Designation',
          style: TextStyle(
            fontSize: ratio * 9,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Add Designation',
              style: TextStyle(
                fontSize: ratio * 8,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: designation,
                decoration: InputDecoration(
                  labelText: 'Enter Your Designation',
                  contentPadding: EdgeInsets.symmetric(
                    vertical: ratio * 7,
                    horizontal: ratio * 7,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: ratio * 7,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      ratio * 7,
                    ), // Set the border radius
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter Your Designation';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: AddMaster,
              child: Text(
                "Create Designation",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child:
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
                      : designationList.isEmpty
                      ? Center(
                        child: Text(
                          "Designation Not Found",
                          style: TextStyle(fontSize: ratio * 8),
                        ),
                      )
                      : ListView.builder(
                        itemCount: designationList.length,
                        itemBuilder: (context, index) {
                          final item = designationList[index];
                          return Container(
                            margin: EdgeInsets.symmetric(
                              vertical: ratio * 1,
                              horizontal: ratio * 1,
                            ),
                            padding: EdgeInsets.all(
                              3 * MediaQuery.of(context).devicePixelRatio,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 215, 229, 241),
                              borderRadius: BorderRadius.circular(ratio * 6),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Expanded left column with text
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        "Designation:",
                                        style: TextStyle(
                                          fontSize: ratio * 7,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${item['designationname']}",
                                        style: TextStyle(fontSize: ratio * 7),
                                      ),
                                    ],
                                  ),
                                ),

                                // Buttons section
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        onPressed:
                                            () => _openDropdown(
                                              item['designationname'],
                                              item['id'],
                                            ),
                                        icon: Column(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.arrowsRotate,
                                              size: ratio * 9,
                                              color: Colors.blue,
                                            ),
                                            Text(
                                              "Update",
                                              style: TextStyle(
                                                fontSize: ratio * 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed:
                                            () => DeleteMaster(item['id']),
                                        icon: Column(
                                          children: [
                                            Icon(
                                              FontAwesomeIcons.trash,
                                              size: ratio * 9,
                                              color: Colors.deepOrangeAccent,
                                            ),
                                            Text(
                                              "Delete",
                                              style: TextStyle(
                                                fontSize: ratio * 4,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
