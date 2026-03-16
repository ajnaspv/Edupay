import 'package:edupay/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(){
  runApp(mains());
}

class mains extends StatelessWidget {
  const mains({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: mainssub(),);
  }
}


class mainssub extends StatefulWidget {
  const mainssub({Key? key}) : super(key: key);

  @override
  State<mainssub> createState() => _mainssubState();
}

class _mainssubState extends State<mainssub> {

 final ip = new TextEditingController(text: "10.196.83.211");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(child:Column(
        children: [

          TextFormField(controller: ip,decoration: InputDecoration(hintText: "Enter IP Address"),),


          ElevatedButton(onPressed: () async {
            SharedPreferences sh = await SharedPreferences.getInstance();
            sh.setString("ip", "http://${ip.text}:4000");
            Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
          }, child: Text("Add"))

        ],
      ) ,),
    );
  }
}

