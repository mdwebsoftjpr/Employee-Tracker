import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimpleMapScreen extends StatelessWidget {
  final List<LatLng> points;
  const SimpleMapScreen({Key? key, required this.points}) : super(key: key);

  /// Calculate total distance of all route points in kilometers
  double getTotalDistance(List<LatLng> points) {
    final Distance distance = const Distance();
    double total = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      total += distance.as(LengthUnit.Kilometer, points[i], points[i + 1]);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialPoint = points.isNotEmpty ? points.first : LatLng(0, 0);
    final double totalDistance = getTotalDistance(points);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Visit Map',
          style: TextStyle(
            fontSize:  6* MediaQuery.of(context).devicePixelRatio,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body:
          points.isEmpty
              ? Center(child: Text('No Points Available'))
              : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: initialPoint,
                      initialZoom: 18,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        markers:
                            points.asMap().entries.map((entry) {
                              final index = entry.key;
                              final point = entry.value;

                              return Marker(
                                width: 70,
                                height: 70,
                                point: point,
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      color:
                                          index == 0
                                              ? Colors
                                                  .green // start
                                              : (index == points.length - 1
                                                  ? Colors
                                                      .red // end
                                                  : Colors.orange), // middle
                                      size: 35,
                                    ),
                                    Text(
                                      'V${index + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      child: Text(
                        'Total Distance: ${totalDistance.toStringAsFixed(2)} km',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
