// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';
// import 'dart:io' show Platform;
// import 'package:edupay/home.dart';
// import 'package:edupay/mobileotp.dart';
// import 'package:edupay/register.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:background_sms/background_sms.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'dart:math';
// void main(){
//   runApp(login());
// }
//
// class login extends StatelessWidget {
//   const login({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: loginsub(),);
//   }
// }
//
//
// class loginsub extends StatefulWidget {
//   const loginsub({Key? key}) : super(key: key);
//
//   @override
//   State<loginsub> createState() => _loginsubState();
// }
//
// class _loginsubState extends State<loginsub> {
//
//   final mobile = new TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(child:Column(
//         children: [
//
//           TextFormField(controller: mobile,decoration: InputDecoration(hintText: "Mobile Number"),),
//
//           ElevatedButton(onPressed: () async {
//             SharedPreferences sh = await SharedPreferences.getInstance();
//             var data = await http.post(Uri.parse( sh.getString("ip").toString() + "/Ulogin" ),body: {
//               'mobile':mobile.text,
//             });
//             var jsonData = json.decode(data.body);
//             if(jsonData['status'] == "ok") {
//               var status = await Permission.sms.request();
//
//               if (status.isGranted) {
//                 // 2. Send SMS directly without opening the messaging app
//
//                 const _chars = '1234567890';
//                 String randomId = String.fromCharCodes(Iterable.generate(
//                     6, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
//
//                 SharedPreferences sh = await SharedPreferences.getInstance();
//                 sh.setString("otp", randomId);
//                 sh.setString("mobile", mobile.text);
//
//                 SmsStatus result = await BackgroundSms.sendMessage(
//                   phoneNumber: mobile.text,
//                   message: "Your OTP code is: ${randomId}",
//                   // Optional: Specify simSlot for dual-sim phones
//                 );
//
//                 if (result == SmsStatus.sent) {
//                   print("SMS sent successfully!");
//                 } else {
//                   print("Failed to send SMS: $result");
//                 }
//               } else {
//                 print("SMS permission denied.");
//               }
//               Navigator.push(
//                   context, MaterialPageRoute(builder: (context) => mobileotp()));
//             }
//             else{
//                 showDialog(context: context, builder: (context)=>AlertDialog(
//                   content: Text("Register first!!!!"),
//                   actions: [
//                     TextButton(onPressed: (){
//                       Navigator.push(
//                           context, MaterialPageRoute(builder: (context) => register()));
//                     }, child: Text("Ok"))
//                   ],
//                 ));
//             }
//           }, child: Text("Login")),
//
//
//
//           ElevatedButton(onPressed: (){
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>register()));
//
//           }, child: Text("Signup"))
//
//         ],
//       ) ,),
//       appBar: AppBar(title: Text("Login"),leading: IconButton(icon:Icon(Icons.arrow_back),onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));})),
//
//     );
//   }
// }
import 'dart:convert';
import 'package:edupay/home.dart';
import 'package:edupay/mobileotp.dart';
import 'package:edupay/register.dart';
import 'package:edupay/chat_bot.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';
void main() {
  runApp(login());
}

class login extends StatelessWidget {
  const login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: loginsub(),
    );
  }
}

class loginsub extends StatefulWidget {
  const loginsub({Key? key}) : super(key: key);

  @override
  State<loginsub> createState() => _loginsubState();
}

class _loginsubState extends State<loginsub> {
  final mobile = TextEditingController();
  String _validationMessage = '';
  bool _isValid = false;
  bool _showMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB), // light background
      resizeToAvoidBottomInset: false,

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ======================
                // TITLE
                // ======================
                const Text(
                  "EduPay",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "The secured payment app",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 40),

                // ======================
                // PREMIUM ROSE FORM CARD
                // ======================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),

                    // ✅ Premium rose gradient
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFE3E6),
                        Color(0xFFFFCCD2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ======================
                      // MOBILE FIELD
                      // ======================
                      TextFormField(
                        controller: mobile,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Mobile Number",
                          prefixIcon:
                          const Icon(Icons.phone, color: Color(0xFFE53935)),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      // ======================
                      // VALIDATION MESSAGE WITH ICON
                      // ======================
                      if (_showMessage)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            children: [
                              Icon(
                                _isValid ? Icons.check_circle : Icons.cancel,
                                color: _isValid ? Colors.green : Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _validationMessage,
                                style: TextStyle(
                                  color: _isValid ? Colors.green : Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(height: 12),

                      const SizedBox(height: 8),

                      // ======================
                      // LOGIN BUTTON
                      // ======================
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (mobile.text.isEmpty) {
                              setState(() {
                                _validationMessage =
                                'Please enter mobile number';
                                _isValid = false;
                                _showMessage = true;
                              });
                              return;
                            }

                            if (mobile.text.length != 10) {
                              setState(() {
                                _validationMessage =
                                'Mobile number must be 10 digits';
                                _isValid = false;
                                _showMessage = true;
                              });
                              return;
                            }

                            try {
                              SharedPreferences sh =
                              await SharedPreferences.getInstance();

                              var data = await http.post(
                                Uri.parse(
                                    sh.getString("ip").toString() + "/Ulogin"),
                                body: {'mobile': mobile.text},
                              );

                              var jsonData = json.decode(data.body);

                              if (jsonData['status'] == "ok") {
                                setState(() {
                                  _validationMessage = 'Now enter your OTP';
                                  _isValid = true;
                                  _showMessage = true;
                                });

                                const _chars = '1234567890';
                                String randomId = String.fromCharCodes(
                                  Iterable.generate(
                                    6,
                                        (_) => _chars.codeUnitAt(Random().nextInt(_chars.length)),
                                  ),
                                );
                                print(randomId);
                                sh.setString("otp", randomId);
                                sh.setString("mobile", mobile.text);

                                if (!kIsWeb) {
                                  var status = await Permission.sms.request();

                                  if (status.isGranted) {
                                    await BackgroundSms.sendMessage(
                                      phoneNumber: mobile.text,
                                      message: "Your OTP code is: $randomId",
                                    );
                                  }
                                } else {
                                  // Web fallback
                                  print("Web detected — SMS cannot be sent automatically.");
                                }

                                Future.delayed(
                                    const Duration(milliseconds: 800), () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => mobileotp()));
                                });
                              } else {
                                setState(() {
                                  _validationMessage =
                                  '${jsonData['status']}';
                                  _isValid = false;
                                  _showMessage = true;
                                });
                              }
                            } catch (e) {
                              setState(() {
                                _validationMessage = 'Error: ${e.toString()}';
                                _isValid = false;
                                _showMessage = true;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // ======================
                      // SIGNUP BUTTON
                      // ======================
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => register()));
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE53935)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            "SIGNUP",
                            style: TextStyle(
                              color: Color(0xFFE53935),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      const Divider(),

                      // ======================
                      // CHATBOT (non-students)
                      // ======================
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => home()));
                        },
                        icon: const Icon(Icons.smart_toy,
                            color: Color(0xFFE53935)),
                        label: const Text(
                          "Need help? Ask our Chatbot",
                          style: TextStyle(color: Color(0xFFE53935)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
