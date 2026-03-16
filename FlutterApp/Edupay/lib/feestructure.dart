import 'dart:async';

import 'package:edupay/home.dart';
import 'package:edupay/paymentpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main(){
  runApp(feestructure());
}

class feestructure extends StatelessWidget {
  const feestructure({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: feestructuresub(),
    );
  }
}

class feestructuresub extends StatefulWidget {
  const feestructuresub({Key? key}) : super(key: key);

  @override
  State<feestructuresub> createState() => _feestructuresubState();
}

class _feestructuresubState extends State<feestructuresub> {

  String totalamountpaid = "0";
  String totalamount = "0";
  String pendingamount = "0";

  String _firstFeeId = "";
  Timer? _refreshTimer;



  @override
  void initState() {
    super.initState();
    _fetchStudentData();

    // ✅ Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchStudentData();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ✅ Fetch student information from Django server
  Future<void> _fetchStudentData() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? mobile = sh.getString("mobile");
      String? ip = sh.getString("ip");



      // ✅ Fetch student data from backend
      var response = await http.post(
        Uri.parse("$ip/getstudentdata"),
        body: {'mobile': mobile},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        setState(() {
          if (jsonData['status'] == 'ok' && jsonData['data'] != null) {
            var data = jsonData['data'];



            // Extract fee information
            String total = (data['total_fee'] ?? 0).toString();
            String paid = (data['paid_amount'] ?? 0).toString();
            double pending = double.parse(total) - double.parse(paid);
            sh.setString("pending", pending.toStringAsFixed(2));


            // Save total fee for payment page
            sh.setString("total", total);


          } else {

          }
        });
      } else {

      }
    } catch (e) {
      print("Error fetching student data: $e");

    }
  }


  Future<List<Joke>> _getJokes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    var data = await http.post(
      Uri.parse(prefs.getString("ip").toString()+"/UFeestructure"),
      body: {"mobile":prefs.get("mobile")},
    );

    var jsonData = json.decode(data.body);

    List<Joke> jokes = [];

    setState(() {
      totalamountpaid = jsonData['totalamountpaid'].toString();
      pendingamount = prefs.getString("pending").toString();
      totalamount = jsonData['totalamount'].toString();
    });

    for (var joke in jsonData["data"]) {
      jokes.add(Joke(
        joke["id"].toString(),
        joke["fee"].toString(),
        joke["sem"].toString(),
        joke["more"],
      ));
    }

    if (jokes.isNotEmpty) {
      _firstFeeId = jokes[0].id.toString();
    }

    return jokes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Fee Structure",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
          },
        ),
      ),

      body: FutureBuilder(
        future: _getJokes(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {

          if (snapshot.data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              const SizedBox(height: 12),

              // ✅ GRADIENT STATS BOX - At the top (outside ListView)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE53935), Color(0xFFFF5252)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 14,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _statBox("Total", "₹ $totalamount")),
                      const SizedBox(width: 10),
                      Expanded(child: _statBox("Paid", "₹ $totalamountpaid")),
                      const SizedBox(width: 10),
                      Expanded(child: _statBox("Pending", "₹ $pendingamount")),
                    ],
                  ),
                ),
              ),

              // ✅ ListView for semester cards
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {

                    var i = snapshot.data![index];

                    // ✅ Format semester text
                    String semNo = i.Semester.toString().replaceAll(RegExp(r'[^0-9]'), '');
                    String semesterText = semNo.isEmpty ? i.Semester.toString() : "Semester $semNo";

                    return Container(
                      width: double.infinity,
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

                          Text(
                            semesterText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ✅ Fee rows from 'more' array
                          ...(i.More as List? ?? []).map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['title'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF444444),
                                    ),
                                  ),
                                ),
                                Text(
                                  "₹ ${item['fee']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),

                          const SizedBox(height: 12),

                          // ✅ Total Amount strip
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEAEA),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFFC7C7)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.receipt_long, color: Color(0xFFE53935)),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Text(
                                    "Total Amount",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2A2E35),
                                    ),
                                  ),
                                ),
                                Text(
                                  "₹ ${i.Fee}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      // ✅ Bottom Sheet - PAY NOW Button
      bottomSheet: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () async {
              SharedPreferences sh = await SharedPreferences.getInstance();
              sh.setString("fid", _firstFeeId);
              sh.setString("total", pendingamount);
              Navigator.push(context, MaterialPageRoute(builder: (context)=>paymentpage()));
            },
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  colors: [Color(0xFFE53935), Color(0xFFFF5252)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "PAY NOW  ₹ $pendingamount",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Glass stat box used inside gradient container
  Widget _statBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Kept for reference (not used)
  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Text(value),
      ],
    );
  }
}

class Joke {
  final String id;
  final String Fee;
  final String Semester;
  List<dynamic>? More;

  Joke(this.id,this.Fee,this.Semester,this.More);
}