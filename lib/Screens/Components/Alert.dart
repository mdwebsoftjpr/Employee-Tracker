import 'package:flutter/material.dart';

class Alert {
   static Future<void> alert(BuildContext context, message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Employee Tracker')),
          content: Text(message, textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
              child: Text('OK'),
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
