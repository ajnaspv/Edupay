// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'RazorpayScreen.dart';
// class paymentpage extends StatelessWidget {
//   const paymentpage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: paymentpagesub(),);
//   }
// }
// class paymentpagesub extends StatefulWidget {
//   const paymentpagesub({Key? key}) : super(key: key);
//
//   @override
//   State<paymentpagesub> createState() => _paymentpagesubState();
// }
//
// class _paymentpagesubState extends State<paymentpagesub> {
//
//   final amt = new TextEditingController();
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(child: Column(
//         children: [
//           TextFormField(decoration: InputDecoration(hintText: "Total Fee"),),
//
//           TextFormField(controller: amt,decoration: InputDecoration(hintText: "Enter Amount"),),
//           ElevatedButton(onPressed: () async {
//             SharedPreferences sh = await SharedPreferences.getInstance();
//
//             sh.setString("amt", amt.text);
//
//             var data = await http.post(Uri.parse( sh.getString("ip").toString() + "/paid" ),body: {
//               'amt':amt.text,"mobile" : sh.getString("mobile")
//             });
//             var jsonData = json.decode(data.body);
//
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>RazorpayScreen()));
//           }, child: Text("Pay Now"))
//         ],
//       ),),
//
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'RazorpayScreen.dart';
import 'home.dart'; // ✅ for navigator

class paymentpage extends StatelessWidget {
  const paymentpage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: paymentpagesub(),
    );
  }
}

class paymentpagesub extends StatefulWidget {
  const paymentpagesub({Key? key}) : super(key: key);

  @override
  State<paymentpagesub> createState() => _paymentpagesubState();
}

class _paymentpagesubState extends State<paymentpagesub> {
  final amt = TextEditingController();
  final tot = TextEditingController();

  String total = "0";
  bool _isAmountValid = false;
  String _errorMessage = "";

  @override
  void dispose() {
    amt.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loapendingamount();
    // ✅ Listen to amount changes for validation
    amt.addListener(_validateAmount);
  }

  // ✅ Validate amount doesn't exceed total
  void _validateAmount() {
    setState(() {
      if (amt.text.isEmpty) {
        _isAmountValid = false;
        _errorMessage = "";
      } else {
        try {
          double enteredAmount = double.parse(amt.text);
          double totalAmount = double.parse(total);

          if (enteredAmount > totalAmount) {
            _isAmountValid = false;
            _errorMessage = "Amount cannot exceed ₹$total";
          } else if (enteredAmount <= 0) {
            _isAmountValid = false;
            _errorMessage = "Amount must be greater than 0";
          } else {
            _isAmountValid = true;
            _errorMessage = "";
          }
        } catch (e) {
          _isAmountValid = false;
          _errorMessage = "Invalid amount or total. Please check.";
          print("Validation error: $e, total: $total, amount: ${amt.text}");
        }
      }
    });
  }

  Future<void> loapendingamount() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      String? tempTotal = sh.getString("total");
      // ✅ Handle null or invalid total
      total = tempTotal ?? "0";
      // Validate that total can be parsed as double
      try {
        double.parse(total);
      } catch (e) {
        total = "0";
      }
    });
    tot.text = total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ APPBAR ADDED
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Payment",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),

        // ✅ NAVIGATE TO HOME
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => home()),
            );
          },
        ),
      ),

      backgroundColor: const Color(0xFFF7F8FB),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            children: [
              // ✅ Premium Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFFF5252)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text(
                  "Pay Your Fees Securely",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Payment Card
              Container(
                padding: const EdgeInsets.all(18),
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
                  children: [
                    /// Total Fee
                    TextFormField(
                      controller: tot,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Total Fee",
                        prefixIcon: const Icon(Icons.receipt_long),
                        filled: true,
                        fillColor: const Color(0xFFF4F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    /// Enter Amount
                    TextFormField(
                      controller: amt,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter Amount",
                        prefixIcon: const Icon(Icons.currency_rupee),
                        filled: true,
                        fillColor: const Color(0xFFF4F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    // ✅ Show error message if amount is invalid
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    /// Pay Now Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isAmountValid
                            ? () async {
                          SharedPreferences sh =
                          await SharedPreferences.getInstance();

                          sh.setString("amt", amt.text);

                          var data = await http.post(
                            Uri.parse(
                                sh.getString("ip").toString() + "/paid"),
                            body: {
                              'amt': amt.text,
                              "mobile": sh.getString("mobile")
                            },
                          );

                          var jsonData = json.decode(data.body);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RazorpayScreen()),
                          );
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isAmountValid
                              ? const Color(0xFFE53935)
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "PAY NOW",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Payments are processed securely via Razorpay",
                      style: TextStyle(
                        color: Color(0xFF6A717C),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
