// import 'package:edupay/home.dart';
// import 'package:flutter/material.dart';
// //step1
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// //step1
// void main(){
//   runApp(viewalert());
// }
//
// class viewalert extends StatelessWidget {
//   const viewalert({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewalertsub(),);
//   }
// }
//
//
// class viewalertsub extends StatefulWidget {
//   const viewalertsub({Key? key}) : super(key: key);
//
//   @override
//   State<viewalertsub> createState() => _viewalertsubState();
// }
//
// class _viewalertsubState extends State<viewalertsub> {
//   //step2
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/Uviewalert"),
//         body: {"mobile" : prefs.getString("mobile")}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//           joke["From Date"].toString(),
//           joke["Note"].toString(),
//           joke["Fine Date"].toString(),
//           joke["Fine Amount"].toString(),
//           joke["TYPE"].toString(),
//       );
//       jokes.add(newJoke);
//     }
//     return jokes;
//   }
//
//
//
//   //step2
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
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
//                             _buildRow("From Date:", i.From_Date.toString()),
//                             _buildRow("Note:", i.Note.toString()),
//                             _buildRow("Fine Date:", i.Fine_Date.toString()),
//                             _buildRow("Fine Amount:", i.Fine_Amount.toString()),
//                             _buildRow("Type:", i.Type.toString()),
//                             ElevatedButton(onPressed: (){}, child: Text("Make Payment"))
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
//       //  step3
//       appBar: AppBar(title: Text("Alert"),leading: IconButton(icon:Icon(Icons.arrow_back),onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));})),
//     );
//   }
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
//   final String From_Date;
//   final String Note;
//   final String Fine_Date;
//   final String Fine_Amount;
//   final String Type;
//
//
//
//   Joke(this.From_Date,this.Note, this.Fine_Date,this.Fine_Amount,this.Type);
// //  print("hiiiii");
// }
// //step5
import 'package:edupay/home.dart';
import 'package:flutter/material.dart';
//step1
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'feestructure.dart';
//step1

void main(){
  runApp(viewalert());
}

class viewalert extends StatelessWidget {
  const viewalert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: viewalertsub(),
    );
  }
}

class viewalertsub extends StatefulWidget {
  const viewalertsub({Key? key}) : super(key: key);

  @override
  State<viewalertsub> createState() => _viewalertsubState();
}

class _viewalertsubState extends State<viewalertsub> {

  //step2
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data =
    await http.post(Uri.parse(prefs.getString("ip").toString()+"/Uviewalert"),
        body: {"mobile" : prefs.getString("mobile")}
    );

    var jsonData = json.decode(data.body);

    List<Joke> jokes = [];
    for (var joke in jsonData["data"]) {
      Joke newJoke = Joke(
        joke["From Date"].toString(),
        joke["Note"].toString(),
        joke["Fine Date"].toString(),
        joke["Fine Amount"].toString(),
        joke["TYPE"].toString(),
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
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Alert",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            )),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
            }),
      ),

      //  step3
      body: FutureBuilder(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {

          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {

              var i = snapshot.data![index];

              bool hasFine = i.Fine_Amount != "0" && i.Fine_Amount != "0.0";

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
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
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // header
                    Row(
                      children: [

                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: hasFine
                                ? const Color(0xFFFFEAEA)
                                : const Color(0xFFFFF3E6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            hasFine ? Icons.warning : Icons.notifications,
                            color: hasFine
                                ? const Color(0xFFE53935)
                                : const Color(0xFFFF9800),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            i.Type,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),

                    _buildRow("From Date:", i.From_Date),
                    _buildRow("Note:", i.Note),
                    _buildRow("Fine Date:", i.Fine_Date),
                    _buildRow("Fine Amount:", i.Fine_Amount),

                    const SizedBox(height: 12),

                    // premium button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>feestructure()));

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          "MAKE PAYMENT",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  //  step4 (unchanged)
  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

//step5 (unchanged)
class Joke {
  final String From_Date;
  final String Note;
  final String Fine_Date;
  final String Fine_Amount;
  final String Type;

  Joke(this.From_Date,this.Note, this.Fine_Date,this.Fine_Amount,this.Type);
}
