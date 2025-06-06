import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class ConnectivityHelper {
  // Check Internet connection
  static Future<bool> checkInternet(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      _showAlert(context, 'No Internet Connection');
      return false;
    }
    return true;
  }

  // Check Location service and permission
  static Future<bool> checkLocation(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showAlert(context, 'Location services are disabled');
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showAlert(context, 'Location permission denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showAlert(context, 'Location permission permanently denied');
      return false;
    }

    return true;
  }

  // Combined check (Internet + Location)
  static Future<bool> checkInternetAndLocation(BuildContext context) async {
    bool internet = await checkInternet(context);
    bool location = await checkLocation(context);
    return internet && location;
  }

  // Alert dialog
  static void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Alert'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          )
        ],
      ),
    );
  }
}
