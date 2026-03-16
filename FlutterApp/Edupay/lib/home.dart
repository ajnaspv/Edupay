// import 'package:edupay/chat_bot.dart';
// import 'package:edupay/feestructure.dart';
// import 'package:edupay/login.dart';
// import 'package:edupay/main.dart';
// import 'package:edupay/missedalert.dart';
// import 'package:edupay/raisecomplaint.dart';
// import 'package:edupay/viewalert.dart';
// import 'package:edupay/viewpayments.dart';
// import 'package:edupay/viewprofile.dart';
// import 'package:flutter/material.dart';
//
// void main(){
//   runApp(home());
// }
//
// class home extends StatelessWidget {
//   const home({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: homesub(),);
//   }
// }
//
//
// class homesub extends StatefulWidget {
//   const homesub({Key? key}) : super(key: key);
//
//   @override
//   State<homesub> createState() => _homesubState();
// }
//
// class _homesubState extends State<homesub> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         child: Column(
//           children: [
//             ListTile(title: Text("Home"),leading: Icon(Icons.home),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//             },),
//             ListTile(title: Text("Profile"),leading: Icon(Icons.account_circle),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewprofile()));
//             },),
//             ListTile(title: Text("Fee Structure"),leading: Icon(Icons.account_balance_wallet_outlined),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>feestructure()));
//             },),
//             ListTile(title: Text("Alerts"),leading: Icon(Icons.add_alert_sharp),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewalert()));
//             },),
//             ListTile(title: Text("Payment History"),leading: Icon(Icons.access_time_filled),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>viewpayments()));
//             },),
//             ListTile(title: Text("Missed Alert"),leading: Icon(Icons.add_alert),onTap: (){
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>missedalert()));
//             },),
//             ListTile(title: Text("Raise Complaaint"),leading: Icon(Icons.add_call),onTap: (){
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>raisecomplaint()));
//             },),
//             ListTile(title: Text("Chat Bot"),leading: Icon(Icons.ad_units),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>chatbot()));
//             },),
//             ListTile(title: Text("Logout"),leading: Icon(Icons.account_circle_rounded),onTap: (){
//               Navigator.push(context, MaterialPageRoute(builder: (context)=>login()));
//             },),
//           ],
//         ),
//       ),
//       appBar: AppBar(title: Text("Home"),),
//     );
//   }
// }
import 'package:edupay/chat_bot.dart';
import 'package:edupay/feestructure.dart';
import 'package:edupay/login.dart';
import 'package:edupay/main.dart';
import 'package:edupay/missedalert.dart';
import 'package:edupay/raisecomplaint.dart';
import 'package:edupay/viewalert.dart';
import 'package:edupay/viewcomplaintstatus.dart';
import 'package:edupay/viewallcomplaints.dart';
import 'package:edupay/viewpayments.dart';
import 'package:edupay/viewprofile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(home());
}

class home extends StatelessWidget {
  const home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: homesub(),
    );
  }
}

class homesub extends StatefulWidget {
  const homesub({Key? key}) : super(key: key);

  @override
  State<homesub> createState() => _homesubState();
}

class _homesubState extends State<homesub> {
  int _idx = 0;
  Timer? _refreshTimer;

  // ✅ Student data from server
  String studentName = "Loading...";
  String courseYear = "Loading...";
  String admissionNo = "";
  String email = "";
  String department = "";
  String semester = "";
  String pendingAmount = "₹0";
  String totalFee = "₹0";
  String paidAmount = "₹0";
  String dueDate = "N/A";
  bool _isLoading = true;
  bool _shownPendingDialog = false; // track whether we've shown pending alert

  // ✅ Recent activity data
  List<Map<String, dynamic>> recentActivity = [];

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
    _fetchRecentActivity();
    
    // ✅ Auto-refresh every 30 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _fetchStudentData();
        _fetchRecentActivity();
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

      if (mobile == null || ip == null) {
        setState(() {
          _isLoading = false;
          studentName = "Error: Mobile/IP not found";
        });
        return;
      }

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

            // Extract student information
            studentName = data['name'] ?? "Unknown";
            admissionNo = data['adm_no'] ?? "";
            email = data['email'] ?? "";
            department = data['course'] ?? "";
            semester = data['sem'] ?? "";

            // Extract fee information
            String total = (data['total_fee'] ?? 0).toString();
            String paid = (data['paid_amount'] ?? 0).toString();
            double pending = double.parse(total) - double.parse(paid);
            sh.setString("pending", pending.toStringAsFixed(2));

            totalFee = "₹$total";
            paidAmount = "₹$paid";
            pendingAmount = "₹${pending.toStringAsFixed(2)}";

            // show popup if student's subscription/fee is pending
            if (pending > 0 && !_shownPendingDialog) {
              _shownPendingDialog = true;
              // schedule after build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Pending Fee'),
                    content: Text(
                        'You have ₹${pending.toStringAsFixed(2)} pending. Please pay to avoid issues.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('OK'))
                    ],
                  ),
                );
              });
            }

            // Extract due date
            dueDate = data['due_date'] ?? "N/A";

            // Construct course year
            courseYear = "$department | Semester $semester";

            // Save total fee for payment page
            sh.setString("total", total);

            _isLoading = false;
          } else {
            setState(() {
              _isLoading = false;
              studentName = "Error loading data";
            });
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          studentName = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      print("Error fetching student data: $e");
      setState(() {
        _isLoading = false;
        studentName = "Error: $e";
      });
    }
  }

  // ✅ Fetch recent activity/transactions from Django server
  Future<void> _fetchRecentActivity() async {
    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String? mobile = sh.getString("mobile");
      String? ip = sh.getString("ip");

      if (mobile == null || ip == null) {
        return;
      }

      // ✅ Fetch payments/transactions from backend
      var response = await http.post(
        Uri.parse("$ip/Uview_payments"),
        body: {'mobile': mobile},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        setState(() {
          if (jsonData['status'] == 'User View payments' && jsonData['data'] != null) {
            List<Map<String, dynamic>> activities = [];
            List<dynamic> payments = jsonData['data'];
            
            // Limit to last 3 transactions
            for (int i = 0; i < (payments.length > 3 ? 3 : payments.length); i++) {
              var payment = payments[i];
              activities.add({
                'type': payment['Status']?.toString().toLowerCase() == 'success' ? 'payment' : 'reminder',
                'title': payment['Status'] == 'success' ? 'Payment Successful' : 'Payment Pending',
                'amount': '₹${payment['Amount']}',
                'date': payment['Date'] ?? '',
                'description': '${payment['course'] ?? 'Fee'} - Sem ${payment['sem'] ?? ''}'
              });
            }
            
            recentActivity = activities;
          } else {
            recentActivity = [];
          }
        });
      }
    } catch (e) {
      print("Error fetching recent activity: $e");
      setState(() {
        recentActivity = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),

      drawer: Drawer(
        child: Column(
          children: [
            const SizedBox(height: 30),
            ListTile(
              title: const Text("Home", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.home),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => home()));
              },
            ),
            ListTile(
              title: const Text("Profile", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.account_circle),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => viewprofile()));
              },
            ),
            ListTile(
              title:
              const Text("Fee Structure", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.account_balance_wallet_outlined),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => feestructure()));
              },
            ),
            ListTile(
              title: const Text("Alerts", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.add_alert_sharp),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => viewalert()));
              },
            ),
            ListTile(
              title:
              const Text("Payment History", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.access_time_filled),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => viewpayments()));
              },
            ),
            ListTile(
              title: const Text("Missed Alert", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.add_alert),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => missedalert()));
              },
            ),
            ListTile(
              title: const Text("Raise Complaaint",
                  style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.add_call),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => raisecomplaint()));
              },
            ),
            ListTile(
              title: const Text("My Complaints", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.assignment_outlined),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => viewallcomplaints()));
              },
            ),
            ListTile(
              title: const Text("Chat Bot", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.ad_units),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyChatApp()));
              },
            ),
            ListTile(
              title: const Text("Logout", style: TextStyle(fontSize: 14)),
              leading: const Icon(Icons.account_circle_rounded),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => login()));
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 6),
            _logo(),
            const SizedBox(width: 10),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => viewalert()));
                },
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53935),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "1",
                    style: TextStyle(
                      fontSize: 9, // reduced
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => viewprofile()));
              },
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFFEDEFF5),
                child: Icon(Icons.person, color: Color(0xFF444444)),
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _welcomeBlock(),
              const SizedBox(height: 14),
              _pendingFeeCard(),
              const SizedBox(height: 14),
              _quickActionsRow(),
              const SizedBox(height: 18),
              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 16, // reduced
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF222222),
                ),
              ),
              const SizedBox(height: 10),
              _recentActivityCard(),
              const SizedBox(height: 14),
              _chatBubble(),
            ],
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _chatFab(),

      bottomNavigationBar: _bottomNav(),

      // ✅ removed bottomSheet pay now bar
      // bottomSheet: _payNowBar(),
    );
  }

  // ===== UI Pieces =====

  Widget _logo() {
    return Row(
      children: const [
        Icon(Icons.school_rounded,
            color: Color(0xFFE53935), size: 20), // reduced
        SizedBox(width: 6),
        Text(
          "EduPay",
          style: TextStyle(
            fontSize: 18, // reduced
            fontWeight: FontWeight.w900,
            color: Color(0xFFE53935),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _welcomeBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hello, $studentName",
          style: const TextStyle(
            fontSize: 20, // reduced
            fontWeight: FontWeight.w900,
            color: Color(0xFF2A2E35),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          courseYear,
          style: const TextStyle(
            fontSize: 13, // reduced
            fontWeight: FontWeight.w600,
            color: Color(0xFF6A717C),
          ),
        ),
      ],
    );
  }

  Widget _pendingFeeCard() {
    return Container(
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pending Fees",
            style: TextStyle(
              fontSize: 14, // reduced
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            pendingAmount,
            style: const TextStyle(
              fontSize: 34, // reduced
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Due Date: $dueDate",
            style: const TextStyle(
              fontSize: 13, // reduced
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => feestructure()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFE53935),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                "PAY NOW",
                style: TextStyle(
                  fontSize: 14, // reduced
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
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
      child: Row(
        children: [
          Expanded(
            child: _actionItem(
              icon: Icons.receipt_long_rounded,
              label: "Fee Details",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => feestructure()));
              },
            ),
          ),
          _dividerV(),
          Expanded(
            child: _actionItem(
              icon: Icons.receipt_rounded,
              label: "Transactions",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => viewpayments()));
              },
            ),
          ),
          _dividerV(),
          Expanded(
            child: _actionItem(
              icon: Icons.download_rounded,
              label: "Download Receipt",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => viewpayments()));
              },
            ),
          ),
          _dividerV(),
          Expanded(
            child: _actionItem(
              icon: Icons.smart_toy_rounded,
              label: "Chat with EduBot",
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyChatApp()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionItem(
      {required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, // reduced
              height: 40, // reduced
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: const Color(0xFFE53935), size: 20), // reduced
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11, // reduced
                fontWeight: FontWeight.w700,
                color: Color(0xFF2A2E35),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dividerV() {
    return Container(
      width: 1,
      height: 58,
      color: const Color(0xFFE9ECF2),
    );
  }

  Color _getActivityIconBg(String? type) {
    switch (type?.toLowerCase()) {
      case 'payment':
        return const Color(0xFFE8F7EE);
      case 'reminder':
        return const Color(0xFFFFEAEA);
      case 'notice':
        return const Color(0xFFFFF3E6);
      default:
        return const Color(0xFFE8F7EE);
    }
  }

  IconData _getActivityIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'payment':
        return Icons.check_circle_rounded;
      case 'reminder':
        return Icons.notifications_active_rounded;
      case 'notice':
        return Icons.campaign_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  Color _getActivityIconColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'payment':
        return const Color(0xFF2ECC71);
      case 'reminder':
        return const Color(0xFFE53935);
      case 'notice':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF2ECC71);
    }
  }

  Widget _recentActivityCard() {
    if (recentActivity.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
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
        child: const Center(
          child: Text(
            "No recent activity",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6A717C),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
          for (int i = 0; i < recentActivity.length; i++) ...[
            _activityRow(
              iconBg: _getActivityIconBg(recentActivity[i]['type']),
              icon: _getActivityIcon(recentActivity[i]['type']),
              iconColor: _getActivityIconColor(recentActivity[i]['type']),
              title: recentActivity[i]['title'] ?? "Activity",
              trailing: recentActivity[i]['amount'] ?? "",
              subtitle: recentActivity[i]['date'] ?? recentActivity[i]['description'] ?? "",
            ),
            if (i < recentActivity.length - 1)
              const Divider(height: 18, color: Color(0xFFE9ECF2)),
          ],
        ],
      ),
    );
  }

  Widget _activityRow({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String trailing,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 38, // reduced
          height: 38, // reduced
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20), // reduced
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 13, // reduced
                color: Color(0xFF2A2E35),
              ),
              children: [
                TextSpan(
                  text: title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (trailing.isNotEmpty)
                  TextSpan(
                    text: "  $trailing",
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                TextSpan(
                  text: "  $subtitle",
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6A717C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _chatBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 14,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Chat with EduBot",
              style: TextStyle(
                fontSize: 13, // reduced
                fontWeight: FontWeight.w800,
                color: Color(0xFF2A2E35),
              ),
            ),
            SizedBox(width: 8),
            CircleAvatar(
              radius: 10,
              backgroundColor: Color(0xFFFFEAEA),
              child: Icon(Icons.arrow_forward_ios_rounded,
                  size: 12, color: Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatFab() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyChatApp()));
      },
      child: Container(
        width: 58, // reduced
        height: 58, // reduced
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFE53935),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.white, width: 5),
        ),
        child: Stack(
          children: [
            const Center(
              child: Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 26), // reduced
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 9, // reduced
                height: 9, // reduced
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // keep method (not used) to avoid changing structure; you asked remove down button
  Widget _payNowBar() {
    return const SizedBox.shrink();
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: _idx,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFE53935),
      unselectedItemColor: const Color(0xFF6A717C),
      selectedLabelStyle:
      const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
      unselectedLabelStyle:
      const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      onTap: (v) {
        setState(() => _idx = v);

        if (v == 0) {
          // Home stays
        } else if (v == 1) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => viewalert()));
        } else if (v == 2) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => viewpayments()));
        } else if (v == 3) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => viewprofile()));
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded), label: "Notifications"),
        BottomNavigationBarItem(
            icon: Icon(Icons.download_rounded), label: "Downloads"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), label: "Profile"),
      ],
    );
  }
}
