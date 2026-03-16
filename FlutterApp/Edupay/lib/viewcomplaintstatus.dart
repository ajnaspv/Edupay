import 'package:flutter/material.dart';
//step1
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//step1
import 'package:edupay/home.dart';

void main() {
  runApp(viewcomplaintstatus());
}

class viewcomplaintstatus extends StatelessWidget {
  const viewcomplaintstatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: viewcomplaintstatussub(),
    );
  }
}

class viewcomplaintstatussub extends StatefulWidget {
  const viewcomplaintstatussub({Key? key}) : super(key: key);

  @override
  State<viewcomplaintstatussub> createState() => _viewcomplaintstatussubState();
}

class _viewcomplaintstatussubState extends State<viewcomplaintstatussub> {
  //step2
  String ComplaintId = "";
  String Title = "";
  String Date = "";
  String Priority = "";
  String Status = "";
  String Department = "";
  String StudentName = "";
  String StudentMobile = "";
  String StaffName = "";
  String StaffReply = "";
  String Attachment = "";

  // ✅ Added (Description + Category) without changing design structure
  String Description = "";
  String Category = "";

  // loading state and timeline storage (used instead of FutureBuilder)
  bool _loading = true;
  List<Joke> _timeline = [];

  @override
  void initState() {
    super.initState();
    _loadComplaint();
  }

  Future<List<Joke>> _getJokes() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String ip = (prefs.getString("ip") ?? "").toString();
      String cid = (prefs.getString("cid") ?? "").toString();

      if (cid.isEmpty || ip.isEmpty) {
        setState(() {
          _timeline = [];
          _loading = false;
        });
        return [];
      }

      var res = await http.post(
        Uri.parse(ip + "/Sview_complaint_status"),
        body: {"cid": cid},
      );

      var jsonData = json.decode(res.body);

      List<Joke> jokes = [];

      setState(() {
        ComplaintId = (jsonData["complaint_id"] ?? "").toString();
        Title = (jsonData["title"] ?? "").toString();
        Date = (jsonData["date"] ?? "").toString();
        Status = (jsonData["status"] ?? "").toString();

        Description = (jsonData["description"] ??
                jsonData["complaint_description"] ??
                jsonData["details"] ??
                jsonData["complaint_desc"] ??
                "")
            .toString();

        Category = (jsonData["category"] ??
                jsonData["complaint_category"] ??
                jsonData["type"] ??
                jsonData["c_category"] ??
                "")
            .toString();

        StaffReply = (jsonData["staff_reply"] ??
                jsonData["reply"] ??
                jsonData["staffreply"] ??
                jsonData["StaffReply"] ??
                jsonData["Staff Reply"] ??
                "")
            .toString();

        Attachment = (jsonData["attachment"] ?? "").toString();
      });

      for (var t in (jsonData["timeline"] ?? [])) {
        jokes.add(Joke(
          (t["step"] ?? "").toString(),
          (t["done"] ?? "0").toString(),
          (t["date"] ?? "").toString(),
        ));
      }

      setState(() {
        _timeline = jokes;
        _loading = false;
      });
      return jokes;
    } catch (e) {
      setState(() {
        _timeline = [
          Joke("Submitted", "0", ""),
          Joke("Viewed by Staff", "0", ""),
          Joke("In Progress", "0", ""),
          Joke("Resolved", "0", ""),
        ];
        _loading = false;
      });
      return _timeline;
    }
  }
  
  // wrapper so initState can call a void async function
  Future<void> _loadComplaint() async {
    await _getJokes();
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
          "Complaint Status",
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

      //step3
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // ✅ Small header card (ID + Title + Status + Date + Category + Description)
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ComplaintId.isEmpty ? "Complaint" : "ID: $ComplaintId",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2A2E35),
                            ),
                          ),
                        ),
                        _statusChip(Status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      Title.isEmpty ? "Complaint Title" : Title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF222222),
                      ),
                    ),

                    // ✅ Added Category (small chip style, matches design)
                    if (Category.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F4FA),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: const Color(0xFFE9ECF2)),
                        ),
                        child: Text(
                          Category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2A2E35),
                          ),
                        ),
                      ),
                    ],

                    // ✅ Added Description (under title/category)
                    const SizedBox(height: 8),
                    Text(
                      Description.isEmpty ? "Complaint Description" : Description,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6A717C),
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded,
                            size: 18, color: Color(0xFF6A717C)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            Date.isEmpty ? "Date: —" : "Date: $Date",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6A717C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ✅ HIGHLIGHTED STAFF REPLY (MAIN)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.support_agent_rounded,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Staff Reply",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            StaffReply.isEmpty ? "No reply yet" : StaffReply,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              height: 1.35,
                            ),
                          ),
                          if (StaffName.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              "— $StaffName",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // ✅ Timeline Card
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
                      "Progress",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF222222),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_timeline.isEmpty) const Text("No progress steps found."),
                    ListView.builder(
                      itemCount: _timeline.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        var i = _timeline[index];
                        bool done = i.Done.toString() == "1";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: done
                                          ? const Color(0xFF2ECC71)
                                          : const Color(0xFFD8DEE8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      done ? Icons.check : Icons.circle,
                                      size: done ? 18 : 10,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (index != _timeline.length - 1)
                                    Container(
                                      width: 3,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE9ECF2),
                                        borderRadius:
                                        BorderRadius.circular(10),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      i.Step.toString(),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF2A2E35),
                                      ),
                                    ),
                                    if (i.StepDate.toString().isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          i.StepDate.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF6A717C),
                                          ),
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
                  ],
                ),
              ),
            ],
          ),
      //step3
    );
  }

  Widget _statusChip(String s) {
    String t = (s.isEmpty ? "Pending" : s).toLowerCase();

    Color bg = const Color(0xFFFFF3E6);
    Color fg = const Color(0xFFFF9800);

    if (t.contains("progress")) {
      bg = const Color(0xFFEAF2FF);
      fg = const Color(0xFF1E6FFF);
    } else if (t.contains("resolve") || t.contains("complete")) {
      bg = const Color(0xFFE8F7EE);
      fg = const Color(0xFF2ECC71);
    } else if (t.contains("reject") || t.contains("fail")) {
      bg = const Color(0xFFFFEAEA);
      fg = const Color(0xFFE53935);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        s.isEmpty ? "Pending" : s,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}

//step5
class Joke {
  final String Step;
  final String Done;
  final String StepDate;

  Joke(this.Step, this.Done, this.StepDate);
}
//step5
