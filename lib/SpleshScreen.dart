import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:localstorage/localstorage.dart';
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:employee_tracker/Screens/EmployeeReports/EmpHome.dart';
import 'main.dart'; // for CreateScreen()

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalStorage localStorage = LocalStorage('employee_tracker');
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/Videos/WelCome.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(false);
        _videoController.play();
      });

    Timer(Duration(seconds: 5), navigateUser);
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void navigateUser() async {
    await localStorage.ready;

    String? user = localStorage.getItem("user");
    String? role = localStorage.getItem("role");

    role = role?.toString().replaceAll('"', '').trim().toLowerCase();

    if (user != null && user != '') {
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AdminHome()),
        );
      } else if (role == 'employee') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => EmpHome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => CreateScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CreateScreen()),
      );
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Color.fromARGB(255, 49, 42, 35),
    body: _videoController.value.isInitialized
        ? Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.1, // 10% radius
              ),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.5,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                ),
              ),
            ),
          )
        : Center(child: CircularProgressIndicator(color: Colors.white)),
  );
}


}
