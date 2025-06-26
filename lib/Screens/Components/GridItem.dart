import 'package:flutter/material.dart';

class DashboardTile extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final double deviceWidth;
  final double ratio;

  const DashboardTile({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    required this.deviceWidth,
    required this.ratio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: ratio * 7,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Image.asset(
              imagePath,
              width: deviceWidth * 0.4,
              height: deviceWidth * 0.3,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
