import 'package:edupay/home.dart';
import 'package:edupay/viewcomplaintstatus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(viewallcomplaints());
}

class viewallcomplaints extends StatelessWidget {
  const viewallcomplaints({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: viewallcomplaintssub(),
    );
  }
}

class viewallcomplaintssub extends StatefulWidget {
  const viewallcomplaintssub({Key? key}) : super(key: key);

  @override
  State<viewallcomplaintssub> createState() => _viewallcomplaintssubState();
}

class _viewallcomplaintssubState extends State<viewallcomplaintssub> {
  Future<List<ComplaintItem>> _fetchComplaints() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String ip = prefs.getString("ip") ?? "";
    String mobile = prefs.getString("mobile") ?? "";
    if (ip.isEmpty || mobile.isEmpty) return [];

    try {
      var res = await http.post(Uri.parse(ip + "/Uview_complaints"),
          body: {"mobile": mobile});
      var jsonData = json.decode(res.body);
      if (jsonData['status'] == 'ok' && jsonData['data'] != null) {
        List<ComplaintItem> list = [];
        for (var c in jsonData['data']) {
          list.add(ComplaintItem(
            id: c['id'].toString(),
            title: c['title'] ?? '',
            date: c['date'] ?? '',
            status: c['status'] ?? '',
            category: c['category'] ?? '',
          ));
        }
        return list;
      }
    } catch (e) {
      print("Error fetching complaints: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF222222)),
        title: const Text(
          "My Complaints",
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
      body: FutureBuilder<List<ComplaintItem>>(
        future: _fetchComplaints(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          var list = snapshot.data ?? [];
          if (list.isEmpty) {
            return const Center(child: Text("No complaints found"));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              var item = list[index];
              return GestureDetector(
                onTap: () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  prefs.setString("cid", item.id);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => viewcomplaintstatus()));
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title.isEmpty ? "Untitled" : item.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 16),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text("Date: ${item.date}"),
                            const SizedBox(width: 12),
                            _statusChip(item.status),
                          ],
                        ),
                        if (item.category.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text("Category: ${item.category}"),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusChip(String s) {
    Color bg = const Color(0xFFF4F5F9);
    Color fg = const Color(0xFF6A717C);
    if (s.toLowerCase() == "pending") {
      bg = const Color(0xFFFFF3E6);
      fg = const Color(0xFFFF9800);
    } else if (s.toLowerCase() == "resolved") {
      bg = const Color(0xFFE8F7EE);
      fg = const Color(0xFF2ECC71);
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        s.isEmpty ? "-" : s,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}

class ComplaintItem {
  final String id;
  final String title;
  final String date;
  final String status;
  final String category;

  ComplaintItem(
      {required this.id,
      required this.title,
      required this.date,
      required this.status,
      required this.category});
}
