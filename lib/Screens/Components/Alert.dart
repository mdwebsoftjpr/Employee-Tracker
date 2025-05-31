import 'package:flutter/material.dart';

class Alert {
  
  static Future<void> alert(BuildContext context, message) async {
     double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'EmpAttend',
              style: TextStyle(fontSize: ratio*8, fontWeight: FontWeight.bold),
            ),
          ),
          content: Text(message,style: TextStyle(fontSize: ratio*7), textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
              child: Text('OK', style: TextStyle(color: Colors.white)),

              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF03a9f4),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
