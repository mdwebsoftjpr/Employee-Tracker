import 'dart:async';
import 'package:employee_tracker/Screens/Components/Alert.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:localstorage/localstorage.dart';
import 'package:employee_tracker/Screens/Home%20Screen/AdminHome.dart';
import 'package:employee_tracker/Screens/Home%20Screen/EmpHome.dart';
import 'main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalStorage localStorage = LocalStorage('employee_tracker');
  late VideoPlayerController _videoController;
  bool? _internetAvailable;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    _videoController = VideoPlayerController.asset('assets/Videos/WelCome.mp4')
      ..initialize().then((_) {
        setState(() {});
        _videoController.setLooping(false);
        _videoController.play();
      });
   _checkInternetAndProceed();
  }

  void navigateUser() async {
    await localStorage.ready;

    String? user = localStorage.getItem("user");
    String? role = localStorage.getItem("role");

    role = role?.toString().replaceAll('"', '').trim().toLowerCase();

    Widget targetScreen;

    if (user != null && user != '') {
      if (role == 'admin') {
        targetScreen = AdminHome();
      } else if (role == 'employee') {
        targetScreen = EmpHome();
      } else {
        targetScreen = CreateScreen();
      }
    } else {
      targetScreen = CreateScreen();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => targetScreen),
      (route) => false, // removes all previous routes
    );
  }

Future<void> _checkInternetAndProceed() async {
  Timer(Duration(seconds: 5), () async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _internetAvailable = false;
      });
      Alert.alert(context, "Please On Internet");
    } else {
      navigateUser();
    }
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 49, 42, 35),
      body:
          _videoController.value.isInitialized
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
