import 'package:employee_tracker/Screens/image%20FullScreen/fullScreenImage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:employee_tracker/Screens/Admin Report/VisitRepMap.dart';
import 'package:latlong2/latlong.dart';

class Mainvisit extends StatefulWidget {
  final dynamic visits; // Replace 'dynamic' with proper type if possible

  const Mainvisit(this.visits, {Key? key}) : super(key: key);

  MainvisitState createState() => MainvisitState();
}

class MainvisitState extends State<Mainvisit> {
  Future<void> showDetail(
    BuildContext context,
    Map<String, dynamic> visitList,
  ) async {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    // Calculate ratio
    double ratio =
        deviceWidth < deviceHeight
            ? deviceHeight / deviceWidth
            : deviceWidth / deviceHeight;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8 * ratio),
          ),
          title: Center(
            child: Text(
              "Visit Details",
              style: TextStyle(
                fontSize: ratio * 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: ratio * 200, // Adjust max height if needed
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: ratio * 2,
                      horizontal: ratio * 1,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (visitList['imagev'] != null)
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8 * ratio),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => FullScreenImageViewer(
                                            imageUrl: visitList['imagev'],
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: ratio * 40,
                                  height: ratio * 40,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                  ),
                                  child: Image.network(
                                    visitList['imagev'],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                          Icons.broken_image,
                                          size: 40 * ratio,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 5 * ratio),
                        buildTextDetail(
                          "Organization",
                          visitList['NameOfCustomer'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Concerned Person",
                          visitList['concernedperson'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Mobile No.",
                          visitList['phoneno'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Date",
                          formatDateSimple(visitList['date']),
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Start Time",
                          visitList['time'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "End Time",
                          visitList['end'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Transport",
                          visitList['transport'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Probability",
                          visitList['probablity'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Prospects",
                          visitList['prospects'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Address",
                          visitList['address'],
                          context,
                          ratio,
                        ),
                        buildTextDetail(
                          "Location Address",
                          visitList['address2'],
                          context,
                          ratio,
                        ),
                        Divider(thickness: 1 * ratio, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 5 * ratio,
                    horizontal: 8 * ratio,
                  ),
                  textStyle: TextStyle(fontSize: 8 * ratio),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Close"),
              ),
            ),
          ],
        );
      },
    );
  }

  String formatDateSimple(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';

    try {
      DateTime parsedDate = DateTime.parse(dateStr);
      String day = parsedDate.day.toString().padLeft(2, '0');
      String month = parsedDate.month.toString().padLeft(2, '0');
      String year = parsedDate.year.toString();
      return "$day $month $year";
    } catch (e) {
      return dateStr; // fallback to original if parsing fails
    }
  }

  Widget buildTextDetail(
    String label,
    String value,
    BuildContext context,
    double ratio,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2 * ratio, horizontal: ratio * 1),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black, fontSize: 7 * ratio),
          children: [
            TextSpan(
              text: "$label: ",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.visits['data'];
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    var ratio;
    if (deviceWidth < deviceHeight) {
      ratio = deviceHeight / deviceWidth;
    } else {
      ratio = deviceWidth / deviceHeight;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Color(0xFF03a9f4),
          title: Text(
            'Visit Report',
            style: TextStyle(
              fontSize: ratio * 9,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final visit = data[index];
            return Container(
              margin: EdgeInsets.symmetric(vertical: ratio*2, horizontal: ratio*7),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 247, 239, 230),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: ratio * 12,
                    height: ratio * 12,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(ratio * 10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      children: [
                        Image.network(
                          visit['image'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) =>
                                  const Icon(Icons.broken_image, size: 50),
                          cacheWidth: (ratio * 25).toInt(),
                          cacheHeight: (ratio * 30).toInt(),
                        ),
                        Text(
                          formatDateSimple(visit['date']),
                          style: TextStyle(fontSize: ratio * 6),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Concerned Person',
                          style: TextStyle(
                            fontSize: ratio * 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          (visit['concernedperson'] ?? 'No Name')
                                      .toString()
                                      .length >
                                  20
                              ? '${visit['concernedperson'].toString().substring(0, 20)}...'
                              : visit['concernedperson'] ?? 'No Name',
                          style: TextStyle(fontSize: ratio * 6),
                        ),
                        Text(
                          'Name Of Customer',
                          style: TextStyle(
                            fontSize: ratio * 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          (visit['NameOfCustomer'] ?? 'No Name')
                                      .toString()
                                      .length >
                                  20
                              ? '${visit['NameOfCustomer'].toString().substring(0, 20)}...'
                              : visit['NameOfCustomer'] ?? 'No Name',
                          style: TextStyle(fontSize: ratio * 6),
                        ),
                        Row(
                          children: [
                            Text(
                              'Phone:',
                              style: TextStyle(
                                fontSize: ratio * 6,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${visit['phoneno'] ?? 'N/A'}',
                              style: TextStyle(fontSize: ratio * 6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => showDetail(context, visit),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF03a9f4),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.06,
                            vertical:
                                MediaQuery.of(context).size.height * 0.006,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              MediaQuery.of(context).size.width * 0.07,
                            ),
                          ),
                          elevation: 4,
                        ),
                        child: Text("More"),
                      ),
                      IconButton(
                        onPressed: () {
                          final startLocationRaw = visit['start_Location']
                              ?.toString()
                              .replaceAll('"', '');
                          final endLocationRaw = visit['end_Location']
                              ?.toString()
                              .replaceAll('"', '');

                          LatLng? parseCoord(String? coordStr) {
                            if (coordStr == null || coordStr.isEmpty)
                              return null;
                            final parts =
                                coordStr
                                    .split(',')
                                    .map((e) => e.trim())
                                    .toList();
                            if (parts.length == 2) {
                              final lat = double.tryParse(parts[0]);
                              final lng = double.tryParse(parts[1]);
                              if (lat != null && lng != null)
                                return LatLng(lat, lng);
                            }
                            return null;
                          }

                          final startLatLng = parseCoord(startLocationRaw);
                          final endLatLng = parseCoord(endLocationRaw);

                          List<LatLng> points = [];

                          if (startLatLng != null) points.add(startLatLng);
                          if (endLatLng != null) points.add(endLatLng);

                          if (points.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        SimpleMapScreen(points: points),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No valid coordinates found'),
                              ),
                            );
                          }
                        },
                        icon: Icon(
                          FontAwesomeIcons.mapLocationDot,
                          color: Color(0xFF03a9f4),
                          size: ratio * 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
