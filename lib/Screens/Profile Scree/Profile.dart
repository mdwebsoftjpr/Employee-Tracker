import 'package:flutter/material.dart';

void main() {
  runApp(ProfileApp());
}

class ProfileApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double widthPercent = screenWidth * 0.9;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar( backgroundColor:  Color(0xFF03a9f4), // AppBar background color
        title: Text('Profile', style: TextStyle(color: Colors.white,fontSize: 24, fontWeight: FontWeight.bold)), // Custom Title
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Custom back button
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),),
        body: 
        Center(child: 
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 5,bottom: 5,left: 7,right: 7),
            child: Column(
              children: [
                _buildNotification(
                  'Admin/User',
                  'Md Websoft',
                  '5sd1asa45we',
                  "8239974064",
                  'assets/LogoMain.jpg'
                )
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

  Widget _buildNotification(String type,String Cname,String Gst, String mobile, String imagePath) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(10),
      child:Column( 
        children: [
          SizedBox(height: 20,),
          CircleAvatar(
            radius: 100,
            
            backgroundImage: AssetImage(imagePath), // Use an image asset or icon
          ),
           SizedBox(height: 10,),
          Text(
                  "User Type...  "+ type,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          SizedBox(height: 10,),
          Text(
                  "Hello...  "+ Cname,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20,),
          Text(
                  "Your GSTNO...  "+ Gst,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10,),
                Text(
                  "Your Mobile No...  "+ mobile,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10,),
                
                SizedBox(height: 30,),
          Directionality(
            textDirection: TextDirection.rtl,
            child: ElevatedButton(
              onPressed: () => sahil("Logout"),
              child: Icon(Icons.logout,size: 30,),
            ),
          ),
    ]
    )
    );
  }

  void sahil(name) {
    print("Delete: $name");
  }
}
