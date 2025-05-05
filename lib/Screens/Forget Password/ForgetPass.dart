import 'package:flutter/material.dart';

void main(){
  runApp(ForgetPassword());
}

class ForgetPassword extends StatefulWidget{
  ForgetPassState createState()=>ForgetPassState();
}
class ForgetPassState extends State<ForgetPassword>{

 String comName = 'Compamy';
  int? comId;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  
  
  void forget() async {
    String Email = email.text;
    print("Forget");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF03a9f4),
        title:Text(
              'Forget Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: MediaQuery.of(context).size.width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
       body: Padding(padding: EdgeInsets.all(10),
      child: Container(
        padding: EdgeInsets.only(
          top: 0,
          left: MediaQuery.of(context).size.width * 0.07,
          right: MediaQuery.of(context).size.width * 0.07,
          bottom: 0,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
          'Add Designation',
          style: TextStyle(
            color: Colors.black,
            fontSize: 8 * MediaQuery.of(context).devicePixelRatio,
            fontWeight: FontWeight.bold,
          ),),
                SizedBox(height: 10),
                 TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    labelText: 'Enter Your Email',
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 4 * MediaQuery.of(context).devicePixelRatio,
                      horizontal: 4 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    labelStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 5 * MediaQuery.of(context).devicePixelRatio,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        4 * MediaQuery.of(context).devicePixelRatio,
                      ), // Set the border radius
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    prefixIcon: Icon(Icons.person),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter Your Email';
                    }
                    return null;
                  },
                ),
               
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => forget(),
                  child: Text(
                    "Forget Password",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

}