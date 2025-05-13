import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimpleMapScreen extends StatelessWidget {
  final List<LatLng> points;
  const SimpleMapScreen({Key? key, required this.points}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print(points);
    return Scaffold(
      appBar: AppBar(title: Text('Visit Map')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: points.isNotEmpty ? points.first : LatLng(0, 0),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: points,
                strokeWidth: 4.0,
                color: Colors.blue,
              ),
            ],
          ),
          MarkerLayer(
            markers: points.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;

              return Marker(
                width: 40,
                height: 40,
                point: point,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 30,
                    ),
                    Positioned(
                      top: 8,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}', // Serial number starts at 1
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}




















/* import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimpleMapScreen extends StatelessWidget {
  // List of marker positions
  final List<LatLng> markerPositions = [
    LatLng(37.7749, -122.4194),
    LatLng(34.0522, -118.2437),
    LatLng(40.7128, -74.0060),
    LatLng(51.5074, -0.1278),
    LatLng(48.8566, 2.3522),
    LatLng(35.6895, 139.6917),
    LatLng(-33.8688, 151.2093),
    LatLng(55.7558, 37.6173),
    LatLng(28.6139, 77.2090),
    LatLng(19.0760, 72.8777),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF03a9f4),
        title: const Text(
          'Visit Route',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          center:
              markerPositions.isNotEmpty ? markerPositions.first : LatLng(0, 0),
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),

          if (markerPositions.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: markerPositions,
                  strokeWidth: 4.0,
                  color: Colors.blue,
                ),
              ],
            ),
          MarkerLayer(
            markers:
                markerPositions.map((position) {
                  return Marker(
                    width: 40,
                    height: 40,
                    point: position,
                    child: Stack(
                      children: [
                        Icon(Icons.location_on, color: Colors.red, size: 40),
                        Container(
                          width: 20,
                          height: 20,
                          padding: EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(child: Text('1'),)
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),

          // Only show polyline if there are at least two markers
        ],
      ),
    );
  }
}
 */