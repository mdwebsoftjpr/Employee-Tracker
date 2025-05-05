import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

void main() async {
  await _initializeLocalStorage();
  runApp(Empprofile());
}

Future<void> _initializeLocalStorage() async {
  await localStorage.ready; // Wait for the localStorage to be ready
}

final LocalStorage localStorage = LocalStorage('employee_tracker');

class Empprofile extends StatefulWidget {
  EmpprofileState createState() => EmpprofileState();
}

class EmpprofileState extends State<Empprofile> {
  Map<String, dynamic>? userdata;

  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    var userJson = localStorage.getItem('user');
    if (userJson != null) {
      var user = jsonDecode(userJson);

      setState(() {
        userdata = user;
        print(userdata);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widthPercent = screenWidth * 0.9;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF03a9f4), // AppBar background color
          title: Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ), // Custom Title
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ), // Custom back button
            onPressed: () {
              Navigator.pop(context); // Go back to the previous screen
            },
          ),
        ),
        body: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Container(
              margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.07),
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 215, 229, 241),
                borderRadius: BorderRadius.circular(20)
              ),
              child: 
           Padding(
            padding: EdgeInsets.all(20),
           child:Column(
            children: [
              Image.asset('assets/images/LogoMain.jpg',width: MediaQuery.of(context).size.width * 0.4,height: MediaQuery.of(context).size.width * 0.4,),
              Row(
              children: [
                Expanded(child: Text('Company Name:',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),
                Expanded(child: Expanded(child: Text('${userdata!['company_name']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
             Row(
              children: [
                Expanded(child: Text('Role Of This company: ${userdata!['role']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),
                Expanded(child: Expanded(child: Text(' ${userdata!['role']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
            Row(
              children: [
                Expanded(child:Text('Name: ',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),
                Expanded(child: Expanded(child: Text('${userdata!['name']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Email: ',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),
                Expanded(child: Expanded(child: Text(' ${userdata!['db_email']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Mobile No.: ',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),
                Expanded(child: Expanded(child: Text(' ${userdata!['mobile_no']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Pan Card No.: ',style: TextStyle(fontFamily: 'MyFont',fontSize: 20),),),
                Expanded(child: Expanded(child: Text('  ${userdata!['pan_card']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('User Name: ',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),
                Expanded(child: Expanded(child: Text('${userdata!['username']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
            Row(
              children: [
                Expanded(child: Text('Join Date And Time: ',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),
                Expanded(child: Expanded(child: Text('${userdata!['create_at']}',style: TextStyle(fontSize: 6 * MediaQuery.of(context).devicePixelRatio),),),)
              ],
            ),
            ],
           )
           )
            ),
              ],
            )
        ),
    );
  }
}
