import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:background_sms/background_sms.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'login.dart';

class register extends StatelessWidget {
  const register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: registersub(),
    );
  }
}

class registersub extends StatefulWidget {
  const registersub({Key? key}) : super(key: key);

  @override
  State<registersub> createState() => _registersubState();
}

class _registersubState extends State<registersub> {
  // ✅ Form Key for Validation
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final adm_no = TextEditingController();
  final email = TextEditingController();
  final mobile = TextEditingController();
  final otp = TextEditingController();

  bool _showOtpBox = false;
  bool _isOtpCorrect = false;

  Timer? _timer;
  int _seconds = 30;
  bool _otpButtonVisible = true; // Controls OTP button visibility

  String? _selectedBatch;
  String? _selectedSemester;
  String? _selectedCourse;
  List<String> _coursesList = [];
  Map<String, String> _courseNameToId = {};
  Map<String, String> _courseIdToName = {}; // id -> name reverse map for selecting original course
  bool _loadingCourses = false;

  @override
  void initState() {
    super.initState();
    otp.addListener(_validateOtpLogic);
    _fetchCourses();
  }

  // ✅ Timer & SMS Logic
  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 30;
      _otpButtonVisible = false; // ✅ Hide OTP button when timer starts
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds <= 0) {
        t.cancel();
        // ❌ Removed: _otpButtonVisible = true; // Button stays hidden even after timer expires
        setState(() {}); // Update UI to show "Ready to resend" text
      }
      else {
        setState(() => _seconds--);
      }
    });
  }

  Future<void> _sendOtpSms() async {
    // Validate mobile before sending
    if (mobile.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter a valid 10-digit mobile number")));
      return;
    }

    SharedPreferences sh = await SharedPreferences.getInstance();
    var status = await Permission.sms.request();

    if (status.isGranted) {
      String randomId = (100000 + Random().nextInt(900000)).toString();
      await sh.setString("otp", randomId);
      await BackgroundSms.sendMessage(phoneNumber: mobile.text, message: "Your EduPay OTP is: $randomId");
      _startTimer();
      setState(() => _showOtpBox = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP Sent")));
    }
  }

  void _validateOtpLogic() async {
    SharedPreferences sh = await SharedPreferences.getInstance();
    setState(() {
      _isOtpCorrect = (sh.getString("otp") == otp.text) && otp.text.isNotEmpty;
    });
  }

  void _fetchCourses() async {
    setState(() => _loadingCourses = true);
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      var response = await http.get(Uri.parse(sh.getString("ip").toString() + "/getcourses"));
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          _coursesList = [];
          List coursesData = (jsonData is List) ? jsonData : (jsonData['courses'] ?? []);
          _courseNameToId.clear();
          _courseIdToName.clear();
          for (var course in coursesData) {
            String cName = course['course'] ?? course['name'] ?? '';
            String cId = course['id']?.toString() ?? '';
            if (cName.isNotEmpty) {
              _coursesList.add(cName);
              _courseNameToId[cName] = cId;
              if (cId.isNotEmpty) _courseIdToName[cId] = cName;
            }
          }

          // If an original course id/name was saved previously, preselect it
          String origCourse = sh.getString('original_course') ?? sh.getString('course') ?? '';
          if (origCourse.isNotEmpty) {
            // If origCourse is an id present in map, use that
            if (_courseIdToName.containsKey(origCourse)) {
              _selectedCourse = _courseIdToName[origCourse];
            } else if (_coursesList.contains(origCourse)) {
              // origCourse stored as name
              _selectedCourse = origCourse;
            }
          }
        });
      }
    } catch (e) { print(e); }
    setState(() => _loadingCourses = false);
  }

  @override
  void dispose() {
    _timer?.cancel();
    name.dispose();
    adm_no.dispose();
    email.dispose();
    mobile.dispose();
    otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text("Register", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>login()))
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey, // ✅ Attach Form Key
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFFFF5252)]),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("Fill in your details to get started", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Form Fields
                _inputBox(
                    controller: name,
                    hint: "Full Name",
                    icon: Icons.person,
                    validator: (v) => v!.isEmpty ? "Enter your name" : null
                ),
                const SizedBox(height: 12),

                _inputBox(
                    controller: adm_no,
                    hint: "Admission No",
                    icon: Icons.badge,
                    validator: (v) => v!.isEmpty ? "Enter Admission No" : null
                ),
                const SizedBox(height: 12),

                _inputBox(
                    controller: email,
                    hint: "Email Address",
                    icon: Icons.email,
                    validator: (v) => !v!.contains("@") ? "Enter a valid email" : null
                ),
                const SizedBox(height: 12),

                // Mobile + OTP Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _inputBox(
                          controller: mobile,
                          hint: "Mobile",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (v) => v!.length != 10 ? "10 digits required" : null
                      ),
                    ),
                    const SizedBox(width: 10),

                    // ✅ Show OTP button only once (when first visible)
                    if (_otpButtonVisible)
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: _sendOtpSms,
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE53935)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                          ),
                          child: const Text(
                            "OTP",
                            style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                    // ✅ Show empty container when button is hidden (no timer display)
                      const SizedBox(width: 70), // Maintain spacing
                  ],
                ),

                if (_showOtpBox) ...[
                  const SizedBox(height: 12),
                  _inputBox(
                    controller: otp,
                    hint: "Enter 6-digit OTP",
                    icon: Icons.lock,
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_seconds == 0 ? "Ready to resend" : "Resend in $_seconds s",
                          style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      TextButton(
                        onPressed: _seconds == 0 ? _sendOtpSms : null,
                        child: const Text("Resend OTP"),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 12),
                _buildDropdown(
                    "Batch",
                    Icons.calendar_today,
                    _selectedBatch,
                    ["2023", "2024", "2025"],
                        (v) => setState(() => _selectedBatch = v)
                ),
                const SizedBox(height: 12),
                _buildDropdown(
                    "Semester",
                    Icons.school,
                    _selectedSemester,
                    ["Semester1", "Semester2", "Semester3", "Semester4", "Semester5", "Semester6", "Semester7", "Semester8"],
                        (v) => setState(() => _selectedSemester = v)
                ),
                const SizedBox(height: 12),
                _loadingCourses
                    ? const CircularProgressIndicator()
                    : _buildDropdown(
                    "Course",
                    Icons.menu_book,
                    _selectedCourse,
                    _coursesList,
                        (v) => setState(() => _selectedCourse = v)
                ),

                const SizedBox(height: 24),

                // ✅ Register Button with Validation Check
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isOtpCorrect ? () async {
                      if (_formKey.currentState!.validate()) {
                        // All fields valid AND OTP correct -> Send to Server
                        SharedPreferences sh = await SharedPreferences.getInstance();
                        await http.post(
                          Uri.parse(sh.getString("ip").toString() + "/Uregister"),
                          body: {
                            'name': name.text,
                            'adm_no': adm_no.text,
                            'email': email.text,
                            'mobile': mobile.text,
                            'batch': _selectedBatch ?? '',
                            'sem': _selectedSemester ?? '',
                            'course': _courseNameToId[_selectedCourse] ?? '',
                          },
                        );
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => login()));
                      }
                    } : null, // Disabled if OTP is wrong
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOtpCorrect ? const Color(0xFFE53935) : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Helper widgets with Validator support
  Widget _inputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFE53935)),
        filled: true,
        fillColor: enabled ? const Color(0xFFF7F8FB) : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Color(0xFFE53935)),
      ),
    );
  }

  Widget _buildDropdown(String hint, IconData icon, String? value, List<String> items, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? "Required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFE53935)),
        filled: true,
        fillColor: const Color(0xFFF7F8FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}