import 'package:employee_tracker/SpleshScreen.dart';
import 'package:flutter/material.dart';

class InternetNotConnectedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Please check your internet settings and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplashScreen(),
                    ),
                  ); // ✅ Correctly pops this screen
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
