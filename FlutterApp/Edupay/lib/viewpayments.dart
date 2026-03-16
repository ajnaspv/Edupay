// import 'package:edupay/home.dart';
// import 'package:flutter/material.dart';
// //step1
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// //step1
// void main(){
//   runApp(viewpayments());
// }
//
// class viewpayments extends StatelessWidget {
//   const viewpayments({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: viewpaymentssub(),);
//   }
// }
//
//
// class viewpaymentssub extends StatefulWidget {
//   const viewpaymentssub({Key? key}) : super(key: key);
//
//   @override
//   State<viewpaymentssub> createState() => _viewpaymentssubState();
// }
//
// class _viewpaymentssubState extends State<viewpaymentssub> {
//   //step2
//   Future<List<Joke>> _getJokes() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String b = prefs.getString("lid").toString();
//     String foodimage="";
//     var data =
//     await http.post(Uri.parse(prefs.getString("ip").toString()+"/Uview_payments"),
//         body: {"mobile": prefs.getString("mobile")}
//     );
//
//     var jsonData = json.decode(data.body);
// //    print(jsonData);
//     List<Joke> jokes = [];
//     for (var joke in jsonData["data"]) {
//       print(joke);
//       Joke newJoke = Joke(
//           joke["Date"].toString(),
//           joke["Note"].toString(),
//           joke["Amount"].toString(),
//           joke["Status"].toString(),
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
//                             _buildRow("Date:", i.Date.toString()),
//                             _buildRow("Note:", i.Note.toString()),
//                             _buildRow("Amount:", i.Amount.toString()),
//                             _buildRow("Status:", i.Status.toString()),
//                             ElevatedButton(onPressed: (){}, child: Text("Download"))
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
//       appBar: AppBar(title: Text("Payments"),leading: IconButton(icon:Icon(Icons.arrow_back),onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));})),
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
//   final String Date;
//   final String Note;
//   final String Amount;
//   final String Status;
//
//
//
//
//
//   Joke(this.Date,this.Note, this.Amount,this.Status);
// //  print("hiiiii");
// }
// //step5
//
import 'dart:io';

import 'package:edupay/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// PDF/printing packages
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(viewpayments());
}

class viewpayments extends StatelessWidget {
  const viewpayments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: viewpaymentssub(),
    );
  }
}

class viewpaymentssub extends StatefulWidget {
  const viewpaymentssub({Key? key}) : super(key: key);

  @override
  State<viewpaymentssub> createState() => _viewpaymentssubState();
}

class _viewpaymentssubState extends State<viewpaymentssub> {

  final TextEditingController _search = TextEditingController();

  String _query = "";
  String _filter = "All";

  // ================= API =================
  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = await http.post(
      Uri.parse(prefs.getString("ip").toString()+"/Uview_payments"),
      body: {"mobile": prefs.getString("mobile")},
    );

    var jsonData = json.decode(data.body);

    List<Joke> jokes = [];

    for (var joke in jsonData["data"]) {
      jokes.add(Joke(
        joke["Date"].toString(),
        // joke["Note"].toString(),
        joke["Amount"].toString(),
        joke["Status"].toString(),
      ));
    }

    return jokes;
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Payments",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(context,
                MaterialPageRoute(builder: (context)=>home()));
          },
        ),
      ),

      body: FutureBuilder(
        future: _getJokes(),
        builder: (context, snapshot) {

          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Joke> data = snapshot.data!;

          // ================= CALCULATIONS =================
          double paid = 0, pending = 0, failed = 0;

          for (var p in data) {
            double amt = double.tryParse(p.Amount.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

            final s = p.Status.toLowerCase();

            if (s.contains("paid") || s.contains("success")) paid += amt;
            else if (s.contains("pending")) pending += amt;
            else failed += amt;
          }

          // ================= FILTER =================
          List<Joke> filtered = data.where((p) {

            final q = _query.toLowerCase();

            bool matchSearch =
                // p.Note.toLowerCase().contains(q) ||
                    p.Date.toLowerCase().contains(q) ||
                    p.Amount.contains(q);

            bool matchFilter = true;

            if (_filter != "All") {
              matchFilter = p.Status.toLowerCase().contains(_filter.toLowerCase());
            }

            return matchSearch && matchFilter;

          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [

              // ================= TOP SUMMARY CARD =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFFF5252)],
                  ),
                ),
                child: Row(
                  children: [
                    _stat("Paid", paid),
                    _stat("Pending", pending),
                    _stat("Failed", failed),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ================= SEARCH =================
              TextField(
                controller: _search,
                onChanged: (v)=>setState(()=>_query=v),
                decoration: InputDecoration(
                  hintText: "Search payments...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ================= FILTER CHIPS =================
              Row(
                children: [
                  _chip("All"),
                  _chip("Success"),
                  _chip("Pending"),
                  _chip("Failed"),
                ],
              ),

              const SizedBox(height: 12),

              // ================= LIST =================
              ...filtered.map((i) {

                final bool success =
                    i.Status.toLowerCase().contains("paid") ||
                        i.Status.toLowerCase().contains("success");

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x11000000),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              "₹ ${i.Amount}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: success
                                  ? const Color(0xFFE8F7EE)
                                  : const Color(0xFFFFEAEA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              i.Status,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: success
                                    ? Colors.green
                                    : const Color(0xFFE53935),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      _row("Date", i.Date),
                      // _row("Note", i.Note),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _downloadReceipt(i),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text("DOWNLOAD RECEIPT"),
                        ),
                      ),
                    ],
                  ),
                );

              }).toList(),
            ],
          );
        },
      ),
    );
  }

  // ================= HELPERS =================
  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(l, style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  // ================= PDF generation =================
  Future<void> _downloadReceipt(Joke payment) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // college header
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text('De Paul Arts and Science College',
                          style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 4),
                      pw.Text('Edathotty Kakkayangad PO Kannur-670673',
                          style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Phone: +919562442408', style: pw.TextStyle(fontSize: 12)),
                      pw.Text('Email: depaulkannur@gmail.com', style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.Divider(height: 32),

                pw.Text('EduPay Receipt', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Date: ${payment.Date}'),
                pw.SizedBox(height: 8),
                pw.Text('Amount: ₹ ${payment.Amount}'),
                pw.SizedBox(height: 8),
                pw.Text('Status: ${payment.Status}'),
                // add more fields if available
              ],
            ),
          );
        },
      ),
    );

    // save file to Downloads directory
    try {
      final bytes = await doc.save();
      final dir = await getDownloadsDirectory();
      if (dir != null) {
        final fileName = 'receipt_${payment.Date.replaceAll('/', '-')}.pdf';
        final file = File('${dir.path}/$fileName');
        await file.writeAsBytes(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved PDF: $fileName'), duration: const Duration(seconds: 3)),
        );
      } else {
        throw Exception('Downloads directory not available');
      }
    } catch (e) {
      // simply show error when save fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to save PDF: $e'), duration: const Duration(seconds: 3)),
      );
    }
  }

  Widget _chip(String text) {
    bool active = _filter == text;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(text),
        selected: active,
        selectedColor: const Color(0xFFFFEAEA),
        onSelected: (_) => setState(()=>_filter=text),
      ),
    );
  }

  Widget _stat(String title, double value) {
    return Expanded(
      child: Column(
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 4),
          Text("₹ ${value.toStringAsFixed(0)}",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
        ],
      ),
    );
  }
}

// ================= MODEL =================
class Joke {
  final String Date;
  // final String Note;
  final String Amount;
  final String Status;

  Joke(this.Date,this.Amount,this.Status);
}
