import 'package:flutter/material.dart';

void main(){
  runApp(Attendancerep());
}

class Attendancerep extends StatefulWidget{
  AttendancerepState createState()=>AttendancerepState();
}

class AttendancerepState extends State<Attendancerep>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        backgroundColor:  Color(0xFF03a9f4),
        elevation: 0,
        title: Text(
          'Attendance Report',
          style: TextStyle(
            color: Color.fromARGB(255, 254, 255, 255),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),    color: Color(0xFF03a9f4),),
      
          margin: EdgeInsets.all(10),
          child: 
          Column(
            children: [
              Row(
            mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text("04/09/2025",style: TextStyle(fontSize: 15),),
                      Text('16:45:05',style: TextStyle(fontSize: 15),)
                    ],
                  ),SizedBox(width: 30,),
                  Text("Out:17:36:41"),
                  SizedBox(width: 30,),
                 /*  "abc"?Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.red
                      ),
                      child: 
                      Padding(
                        padding: EdgeInsets.only(left: 15,top: 8),
                      child: Text('P',style: TextStyle(fontSize: 20,color: Colors.white),),)
                      ),Text('Hours:0.92')
                    ],:  */Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green
                      ),
                      child: 
                      Padding(
                        padding: EdgeInsets.only(left: 15,top: 8),
                      child: Text('P',style: TextStyle(fontSize: 20,color: Colors.white),),)
                      ),Text('Hours:0.92')
                    ],
                  ),SizedBox(width: 30,),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

