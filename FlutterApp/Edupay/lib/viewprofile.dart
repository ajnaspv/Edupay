// import 'package:edupay/home.dart';
// import 'package:flutter/material.dart';
// //step1
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// //step1
//
// void main(){
//   runApp(viewprofile());
// }
//
// class viewprofile extends StatelessWidget {
//   const viewprofile({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewprofilesub(),);
//   }
// }
//
//
// class viewprofilesub extends StatefulWidget {
//   const viewprofilesub({Key? key}) : super(key: key);
//
//   @override
//   State<viewprofilesub> createState() => _viewprofilesubState();
// }
//
// class _viewprofilesubState extends State<viewprofilesub> {
//   //step2
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/Uviewprofile"),
//         body: {"mobile":prefs.getString("mobile")}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//           joke["Name"].toString(),
//           joke["Course"].toString(),
//           joke["Department"].toString(),
//           joke["Batch"].toString(),
//           joke["Sem"].toString(),
//           joke["Email"].toString(),
//           joke["Phone"].toString()
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//
//
//   //step2
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       //  step3
//       body:
//
//
//       Container(
//
//         child:
//         FutureBuilder(
//           future: _getJokes(),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
// //              print("snapshot"+snapshot.toString());
//             if (snapshot.data == null) {
//               return Container(
//                 child: Center(
//                   child: Text("Loading..."),
//                 ),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   var i = snapshot.data![index];
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Card(
//                       elevation: 3,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         side: BorderSide(color: Colors.grey.shade300),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//
//                             SizedBox(height: 10),
//                             _buildRow("Name:", i.Name.toString()),
//                             _buildRow("Course:", i.Course.toString()),
//                             _buildRow("Department:", i.Department.toString()),
//                             _buildRow("Batch:", i.Batch.toString()),
//                             _buildRow("Semester:", i.Sem.toString()),
//                             _buildRow("Email:", i.Email.toString()),
//                             _buildRow("Phone:", i.Phone.toString()),
//
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               );
//
//
//             }
//           },
//
//
//         ),
//
//
//
//
//
//       ),
//
//       //
//       appBar: AppBar(title: Text("Profile"),leading: IconButton(icon:Icon(Icons.arrow_back),onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));})),
//     );
//   }
//
//   //  step4
//   Widget _buildRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           SizedBox(width: 5),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: Colors.grey.shade800,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
// //  step4
// }
// //step5
// class Joke {
//   final String Name;
//   final String Course;
//   final String Department;
//   final String Batch;
//   final String Sem;
//   final String Email;
//   final String Phone;
//
//
//
//
//   Joke(this.Name,this.Course, this.Department,this.Batch,this.Sem,this.Email,this.Phone);
// //  print("hiiiii");
// }
// //step5
import 'package:edupay/home.dart';
import 'package:flutter/material.dart';
//step1
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//step1

void main() {
  runApp(viewprofile());
}

class viewprofile extends StatelessWidget {
  const viewprofile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: viewprofilesub(),
    );
  }
}

class viewprofilesub extends StatefulWidget {
  const viewprofilesub({Key? key}) : super(key: key);

  @override
  State<viewprofilesub> createState() => _viewprofilesubState();
}

class _viewprofilesubState extends State<viewprofilesub> {
  //step2
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String b = prefs.getString("lid").toString();
    String foodimage = "";
    var data = await http.post(
      Uri.parse(prefs.getString("ip").toString() + "/Uviewprofile"),
      body: {"mobile": prefs.getString("mobile")},
    );

    var jsonData = json.decode(data.body);
    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      print(joke);
      Joke newJoke = Joke(
        joke["Name"].toString(),
        joke["Course"].toString(),
        joke["Department"].toString(),
        joke["Batch"].toString(),
        joke["Sem"].toString(),
        joke["Email"].toString(),
        joke["Phone"].toString(),
      );
      jokes.add(newJoke);
    }
    return jokes;
  }
  //step2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Color(0xFF222222),
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => home()));
          },
        ),
      ),

      body: FutureBuilder(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                var i = snapshot.data![index];

                return Column(
                  children: [
                    // Top Profile Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE53935),
                            Color(0xFFFF5252),
                          ],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 2,
                              ),
                            ),
                            child: const Icon(Icons.person_rounded,
                                color: Colors.white, size: 30),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  i.Name.toString(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${i.Course.toString()} • Sem ${i.Sem.toString()}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.92),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  i.Department.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x11000000),
                            blurRadius: 16,
                            offset: Offset(0, 8),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE9ECF2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Student Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF222222),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildRow("Name:", i.Name.toString()),
                          _buildRow("Course:", i.Course.toString()),
                          _buildRow("Department:", i.Department.toString()),
                          _buildRow("Batch:", i.Batch.toString()),
                          _buildRow("Semester:", i.Sem.toString()),
                          _buildRow("Email:", i.Email.toString()),
                          _buildRow("Phone:", i.Phone.toString()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ✅ Added Buttons Row (Edit Profile + Logout)
                    Row(
                      children: [
                        Expanded(
                          child: _primaryBtn(
                            text: "EDIT PROFILE",
                            icon: Icons.edit_rounded,
                            onTap: () {
                              // TODO: Replace with your Edit Profile page route
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Edit Profile clicked")),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _outlineBtn(
                            text: "LOGOUT",
                            icon: Icons.logout_rounded,
                            onTap: () async {
                              // clear saved data if you want
                              SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                              // keep ip? (optional). comment if you want keep ip
                              // String? ip = prefs.getString("ip");
                              await prefs.clear();
                              // if you want keep ip: prefs.setString("ip", ip ?? "");

                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => home()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Quick Actions (same style)
                    Row(
                      children: [
                        Expanded(
                          child: _smallAction(
                            icon: Icons.account_balance_wallet_rounded,
                            label: "Fees",
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (c) => home()));
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _smallAction(
                            icon: Icons.receipt_long_rounded,
                            label: "Payments",
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (c) => home()));
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }

  // step4 (kept name as-is)
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF2A2E35),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF6A717C),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ New: Primary gradient button (matches Home design)
  Widget _primaryBtn(
      {required String text,
        required IconData icon,
        required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color(0xFFE53935),
              Color(0xFFFF5252),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ New: Outline button (logout)
  Widget _outlineBtn(
      {required String text,
        required IconData icon,
        required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE53935), width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFE53935)),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // helper widget
  Widget _smallAction(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECF2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFE53935), size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A2E35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//step5
class Joke {
  final String Name;
  final String Course;
  final String Department;
  final String Batch;
  final String Sem;
  final String Email;
  final String Phone;

  Joke(this.Name, this.Course, this.Department, this.Batch, this.Sem,
      this.Email, this.Phone);
}
//step5
