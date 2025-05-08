import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SimpleMapScreen extends StatelessWidget {
  final Map<String, LatLng> locations;

  const SimpleMapScreen(this.locations, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final start = locations['start'];
    final end = locations['end'];
    print("$start,$end");
    final points = [if (start != null) start, if (end != null) end];
    print("sahil$points");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title: Text(
          'Employee Detail',
          style: TextStyle(
            color: Colors.white,
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: points.isNotEmpty ? points.first : LatLng(0, 0),
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: points.asMap().entries.map((entry) {
                    final index = entry.key;
                    final location = entry.value;

                    String label = index == 0
                        ? "Start Location"
                        : "End Location";

                    return Marker(
                      point: location,
                      width: 80.0,
                      height: 80.0,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text("Location Info"),
                              content: Text("$label\nLat: ${location.latitude}, Lng: ${location.longitude}"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    );
                  }).toList(),
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
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (start != null)
                  Text(
                    "Start: Lat ${start.latitude}, Lng ${start.longitude}",
                    style: TextStyle(color: Colors.white),
                  ),
                if (end != null)
                  Text(
                    "End: Lat ${end.latitude}, Lng ${end.longitude}",
                    style: TextStyle(color: Colors.white),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
