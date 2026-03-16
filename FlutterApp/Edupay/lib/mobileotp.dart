import 'dart:async';
import 'dart:math'; // Required for Random()
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart';

import 'home.dart';
import 'login.dart';

class mobileotp extends StatelessWidget {
  const mobileotp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const mobileotpsub(),
    );
  }
}

class mobileotpsub extends StatefulWidget {
  const mobileotpsub({Key? key}) : super(key: key);

  @override
  State<mobileotpsub> createState() => _mobileotpsubState();
}

class _mobileotpsubState extends State<mobileotpsub> {
  final otp = TextEditingController();

  // 6 digit controllers
  final TextEditingController _o1 = TextEditingController();
  final TextEditingController _o2 = TextEditingController();
  final TextEditingController _o3 = TextEditingController();
  final TextEditingController _o4 = TextEditingController();
  final TextEditingController _o5 = TextEditingController();
  final TextEditingController _o6 = TextEditingController();

  final FocusNode _f1 = FocusNode();
  final FocusNode _f2 = FocusNode();
  final FocusNode _f3 = FocusNode();
  final FocusNode _f4 = FocusNode();
  final FocusNode _f5 = FocusNode();
  final FocusNode _f6 = FocusNode();

  Timer? _timer;
  int _seconds = 30;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    otp.dispose();
    _o1.dispose(); _o2.dispose(); _o3.dispose(); _o4.dispose(); _o5.dispose(); _o6.dispose();
    _f1.dispose(); _f2.dispose(); _f3.dispose(); _f4.dispose(); _f5.dispose(); _f6.dispose();
    super.dispose();
  }

  void _syncOtpText() {
    otp.text = (_o1.text + _o2.text + _o3.text + _o4.text + _o5.text + _o6.text).trim();
  }

  void _fillFromPaste(String v) {
    final s = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (s.isEmpty) return;
    _o1.text = s.length >= 1 ? s[0] : "";
    _o2.text = s.length >= 2 ? s[1] : "";
    _o3.text = s.length >= 3 ? s[2] : "";
    _o4.text = s.length >= 4 ? s[3] : "";
    _o5.text = s.length >= 5 ? s[4] : "";
    _o6.text = s.length >= 6 ? s[5] : "";
    _syncOtpText();
    FocusScope.of(context).unfocus();
  }

  void _showInvalidOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 70, width: 70,
                  decoration: const BoxDecoration(color: Color(0xFFFFEAEA), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 36, color: Color(0xFFE53935)),
                ),
                const SizedBox(height: 16),
                const Text("Invalid OTP", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text("Please enter the correct 6-digit code", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity, height: 45,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _otpBox({required TextEditingController c, required FocusNode f, FocusNode? next, FocusNode? prev}) {
    return SizedBox(
      width: 46, height: 54,
      child: TextFormField(
        controller: c,
        focusNode: f,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: const Color(0xFFF7F8FB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        ),
        onChanged: (v) {
          if (v.length > 1) { _fillFromPaste(v); return; }
          if (v.isNotEmpty) {
            _syncOtpText();
            if (next != null) FocusScope.of(context).requestFocus(next);
          } else {
            _syncOtpText();
            if (prev != null) FocusScope.of(context).requestFocus(prev);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Login", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login())),
        ),
      ),
      body: SafeArea(
        child: AnimatedPadding(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.only(bottom: bottomInset),
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  // TOP GRADIENT BOX
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFFF5252)]),
                      boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("OTP Verification", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Enter the 6-digit OTP sent to your mobile", style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // OTP CARD
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(18),
                      boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 16, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2A2E35))),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _otpBox(c: _o1, f: _f1, next: _f2),
                            _otpBox(c: _o2, f: _f2, next: _f3, prev: _f1),
                            _otpBox(c: _o3, f: _f3, next: _f4, prev: _f2),
                            _otpBox(c: _o4, f: _f4, next: _f5, prev: _f3),
                            _otpBox(c: _o5, f: _f5, next: _f6, prev: _f4),
                            _otpBox(c: _o6, f: _f6, prev: _f5),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _seconds == 0 ? "You can resend OTP now" : "Resend in 00:${_seconds.toString().padLeft(2, '0')}",
                              style: const TextStyle(color: Colors.black54, fontSize: 12),
                            ),
                            TextButton(
                              onPressed: _seconds == 0 ? () async {
                                SharedPreferences sh = await SharedPreferences.getInstance();
                                var status = await Permission.sms.request();
                                if (status.isGranted) {
                                  String randomId = (100000 + Random().nextInt(900000)).toString();
                                  await sh.setString("otp", randomId);
                                  await BackgroundSms.sendMessage(
                                    phoneNumber: sh.getString("mobile") ?? "",
                                    message: "Your OTP code is: $randomId",
                                  );
                                  _startTimer();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP resent")));
                                }
                              } : null,
                              child: const Text("Resend OTP", style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity, height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              _syncOtpText();
                              SharedPreferences sh = await SharedPreferences.getInstance();
                              if (otp.text == sh.getString("otp")) {
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => home()));
                              } else {
                                _showInvalidOtpDialog();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text("SUBMIT", style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
    );
  }
}