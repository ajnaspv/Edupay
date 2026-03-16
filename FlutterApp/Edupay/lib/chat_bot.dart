// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'home.dart';
//
//
// void main() {
//   runApp(const MyChatApp());
// }
//
// class MyChatApp extends StatelessWidget {
//   const MyChatApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyChatPage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }
//
// class MyChatPage extends StatefulWidget {
//   const MyChatPage({super.key, required this.title});
//
//
//
//   final String title;
//
//   @override
//   State<MyChatPage> createState() => _MyChatPageState();
// }
//
// class ChatMessage {
//   String messageContent;
//   String messageType;
//
//   ChatMessage({required this.messageContent, required this.messageType});
// }
//
// class _MyChatPageState extends State<MyChatPage> {
//   int _counter = 0;
//   String name = "";
//   bool _isD = false;
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _isD = true;
//     super.dispose();
//   }
//   _MyChatPageState() {
//     Timer.periodic(Duration(seconds: 2), (_) {
//       if(_isD==false){
//         view_message();
//       }
//     });
//   }
//
//   List<ChatMessage> messages = [];
//
//   void _incrementCounter() {
//     setState(() {
//
//       _counter++;
//     });
//   }
//
//   TextEditingController te_message = TextEditingController();
//
//   List<String> from_id_ = <String>[];
//   List<String> message_ = <String>[];
//   List<String> date_ = <String>[];
//   List<String> type_ = <String>[];
//   // List<String> time_ = <String>[];
//
//   Future<void> view_message() async {
//     final pref = await SharedPreferences.getInstance();
//     name = "Hello" ;pref.getString("name").toString();
//
//
//     List<String> from_id = <String>[];
//     List<String> message = <String>[];
//     List<String> date = <String>[];
//     List<String> type = <String>[];
//
//     // List<String> time = <String>[];
//
//     try {
//       final pref = await SharedPreferences.getInstance();
//       String urls = pref.getString('ip').toString();
//       String url = '$urls/user_viewchat';
//
//       var data = await http.post(Uri.parse(url), body: {
//         'from_id': pref.getString("mobile").toString(),
//         // 'to_id': pref.getString("did").toString()
//       });
//       var jsondata = json.decode(data.body);
//       String status = jsondata['status'];
//       print(status);
//
//       var arr = jsondata["data"];
//       print(arr);
//
//
//       messages.clear();
//
//
//       for (int i = 0; i < arr.length; i++) {
//         from_id.add(arr[i]['from'].toString());
//         // to_id.add(arr[i]['to'].toString());
//         message.add(arr[i]['msg']);
//         date.add(arr[i]['date'].toString());
//         type.add(arr[i]['type'].toString());
//
//         if ("user" == arr[i]['type'].toString()) {
//           messages.add(ChatMessage(
//               messageContent: arr[i]['msg'], messageType: "sender"));
//         } else {
//           messages.add(ChatMessage(
//               messageContent: arr[i]['msg'], messageType: "receiver"));
//         }
//       }
//
//
//       setState(() {
//         from_id_ = from_id;
//         // to_id_ = to_id;
//         message_ = message;
//         date_ = date;
//         type_=type;
//         // time_ = time;
//
//         messages = messages;
//       });
//
//       print(status);
//     } catch (e) {
//       print("Error ------------------- " + e.toString());
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return WillPopScope(
//       onWillPop: () async{
//         Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: Color.fromARGB(255, 228, 213, 231),
//
//         appBar: AppBar(
//             title: new Text(
//               name,
//               style: new TextStyle(color: Colors.white),
//             ),
//             leading: new IconButton(
//               icon: new Icon(Icons.arrow_back),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//                 // print("Hello");
//
//               },
//             )),
//         body: Stack(
//           children: <Widget>[
//             ListView.builder(
//               itemCount: messages.length,
//               shrinkWrap: true,
//               padding: EdgeInsets.only(top: 10, bottom: 50),
//               physics: ScrollPhysics(),
//               itemBuilder: (context, index) {
//                 return Container(
//                   padding:
//                   EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
//                   child: Align(
//                     alignment: (messages[index].messageType == "receiver"
//                         ? Alignment.topLeft
//                         : Alignment.topRight),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         color: (messages[index].messageType == "receiver"
//                             ? Colors.grey.shade200
//                             : Colors.blue[200]),
//                       ),
//                       padding: EdgeInsets.all(16),
//                       child: Text(
//                         messages[index].messageContent,
//                         style: TextStyle(fontSize: 15),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//             Align(
//               alignment: Alignment.bottomLeft,
//               child: Container(
//                 padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
//                 height: 60,
//                 width: double.infinity,
//                 color: Colors.white,
//                 child: Row(
//                   children: <Widget>[
//                     GestureDetector(
//                       onTap: () {},
//                       child: Container(
//                         height: 30,
//                         width: 30,
//                         decoration: BoxDecoration(
//                           color: Colors.cyan,
//                           borderRadius: BorderRadius.circular(30),
//                         ),
//                         child: Icon(
//                           Icons.add,
//                           color: Colors.white,
//                           size: 20,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 15,
//                     ),
//                     Expanded(
//                       child: TextField(
//                         controller: te_message,
//                         decoration: InputDecoration(
//                             hintText: "Write message...",
//                             hintStyle: TextStyle(color: Colors.black54),
//                             border: InputBorder.none),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 15,
//                     ),
//                     FloatingActionButton(
//                       onPressed: () async {
//                         String fid = "";
//                         String toid = "";
//                         String message = te_message.text.toString();
//
//                         /////
//                         try {
//                           final pref = await SharedPreferences.getInstance();
//                           String ip = pref.getString("ip").toString();
//
//                           String url = ip + "/user_sendchat";
//
//                           var data = await http.post(Uri.parse(url), body: {
//                             'message': message,
//                             'from_id': pref.getString("mobile").toString(),
//                             // 'to_id': pref.getString("did").toString()
//                           });
//                           var jsondata = json.decode(data.body);
//                           String status = jsondata['status'];
//
//                           te_message.text = "";
//
//                           var arr = jsondata["data"];
//
//                           setState(() {});
//
//                           print("");
//                         } catch (e) {
//                           print("Error ------------------- " + e.toString());
//                           //there is error during converting file image to base64 encoding.
//                         }
//                         ////
//
//                         // print("Hiiiiii");
//                         //
//                         // setState(() {
//                         //
//                         //   List<ChatMessage> messages1= messages;
//                         //   messages1.add(ChatMessage(messageContent: "Hello, Fadhil", messageType: "receiver"));
//                         //   setState(() {
//                         //
//                         //     messages=messages1;
//                         //   });
//                         //
//                         // });
//                       },
//                       child: Icon(
//                         Icons.send,
//                         color: Colors.white,
//                         size: 18,
//                       ),
//                       backgroundColor: Colors.cyan,
//                       elevation: 0,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         // This trailing comma makes auto-formatting nicer for build methods.
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home.dart';

void main() {
  runApp(const MyChatApp());
}

class MyChatApp extends StatelessWidget {
  const MyChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      home: const MyChatPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyChatPage extends StatefulWidget {
  const MyChatPage({super.key, required this.title});

  final String title;

  @override
  State<MyChatPage> createState() => _MyChatPageState();
}

class ChatMessage {
  String messageContent;
  String messageType;

  ChatMessage({required this.messageContent, required this.messageType});
}

class _MyChatPageState extends State<MyChatPage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  String name = "";
  bool _isD = false;

  // EduPay style colors (from your screenshot)
  final Color brandRed = const Color(0xFFE53935);
  final Color brandRedDark = const Color(0xFFD32F2F);
  final Color pageBg = const Color(0xFFF6F7FB);

  // loading indicators
  bool _isLoadingMessages = false;
  bool _isSending = false;

  // typing dots animation
  late final AnimationController _dotController;

  // ✅ keep scroll position + auto scroll bottom
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _isD = true;
    _dotController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _MyChatPageState() {
    Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isD == false) {
        view_message();
      }
    });
  }

  List<ChatMessage> messages = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  TextEditingController te_message = TextEditingController();

  List<String> from_id_ = <String>[];
  List<String> message_ = <String>[];
  List<String> date_ = <String>[];
  List<String> type_ = <String>[];

  // ✅ scroll to bottom safely
  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> view_message() async {
    if (_isLoadingMessages) return;

    setState(() {
      _isLoadingMessages = true;
    });

    final pref = await SharedPreferences.getInstance();
    name = "Hello";
    pref.getString("name").toString();

    List<String> from_id = <String>[];
    List<String> message = <String>[];
    List<String> date = <String>[];
    List<String> type = <String>[];

    try {
      final pref = await SharedPreferences.getInstance();
      String urls = pref.getString('ip').toString();
      String url = '$urls/user_viewchat';

      var data = await http.post(Uri.parse(url), body: {
        'from_id': pref.getString("mobile").toString(),
      });

      var jsondata = json.decode(data.body);
      String status = jsondata['status'];
      print(status);

      var arr = jsondata["data"];
      print(arr);

      messages.clear();

      for (int i = 0; i < arr.length; i++) {
        from_id.add(arr[i]['from'].toString());
        message.add(arr[i]['msg']);
        date.add(arr[i]['date'].toString());
        type.add(arr[i]['type'].toString());

        if ("user" == arr[i]['type'].toString()) {
          messages.add(ChatMessage(
              messageContent: arr[i]['msg'], messageType: "sender"));
        } else {
          messages.add(ChatMessage(
              messageContent: arr[i]['msg'], messageType: "receiver"));
        }
      }

      setState(() {
        from_id_ = from_id;
        message_ = message;
        date_ = date;
        type_ = type;
        messages = messages;
      });

      // ✅ after messages load, keep at bottom (no jump to top)
      _scrollToBottom();
    } catch (e) {
      print("Error ------------------- " + e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMessages = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showTyping = _isLoadingMessages || _isSending;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context) => home()));
        return true;
      },
      child: Scaffold(
        backgroundColor: pageBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => home()));
            },
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: brandRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.smart_toy_rounded, color: brandRed),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "EduPay Assistant",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert, color: Colors.black54),
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Row(
                children: const [
                  Icon(Icons.circle, size: 12, color: Color(0xFF2ECC71)),
                  SizedBox(width: 8),
                  Text(
                    "Online",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController, // ✅ important
                itemCount: messages.length + (showTyping ? 1 : 0),
                padding: const EdgeInsets.only(top: 6, bottom: 12),
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  if (showTyping && index == messages.length) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _botAvatar(),
                          const SizedBox(width: 8),
                          _typingBubble(),
                        ],
                      ),
                    );
                  }

                  final isBot = messages[index].messageType == "receiver";

                  // ✅ reply-coming animation: fade + slide
                  return _AnimatedAppear(
                    key: ValueKey(
                        "${index}_${messages[index].messageType}_${messages[index].messageContent}"),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 14, right: 14, top: 10, bottom: 10),
                      child: Row(
                        mainAxisAlignment: isBot
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (isBot) _botAvatar(),
                          if (isBot) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isBot ? Colors.white : null,
                                gradient: isBot
                                    ? null
                                    : LinearGradient(
                                  colors: [brandRed, brandRedDark],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isBot ? 4 : 18),
                                  bottomRight: Radius.circular(isBot ? 18 : 4),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 14,
                                    offset: const Offset(0, 10),
                                  )
                                ],
                                border: isBot
                                    ? Border.all(color: Colors.black12)
                                    : null,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              child: Text(
                                messages[index].messageContent,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700,
                                  color: isBot ? Colors.black87 : Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (!isBot) const SizedBox(width: 8),
                          if (!isBot) _userMiniDot(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x11000000),
                      blurRadius: 18,
                      offset: Offset(0, -6),
                    )
                  ],
                ),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: brandRed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: brandRed.withOpacity(0.25)),
                        ),
                        child: Icon(Icons.add, color: brandRed, size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: pageBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black12),
                        ),
                        alignment: Alignment.centerLeft,
                        child: TextField(
                          controller: te_message,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) async {
                            // ✅ close keyboard on submit
                            FocusScope.of(context).unfocus();
                          },
                          decoration: const InputDecoration(
                            hintText: "Type your message...",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    SizedBox(
                      width: 48,
                      height: 48,
                      child: FloatingActionButton(
                        onPressed: _isSending
                            ? null
                            : () async {
                          // ✅ close keyboard immediately
                          FocusScope.of(context).unfocus();

                          String fid = "";
                          String toid = "";
                          String message = te_message.text.toString();

                          if (message.trim().isEmpty) return;

                          setState(() {
                            _isSending = true;
                          });

                          // ✅ keep user at bottom
                          _scrollToBottom();

                          try {
                            final pref =
                            await SharedPreferences.getInstance();
                            String ip = pref.getString("ip").toString();
                            String url = ip + "/user_sendchat";

                            var data =
                            await http.post(Uri.parse(url), body: {
                              'message': message,
                              'from_id':
                              pref.getString("mobile").toString(),
                            });

                            var jsondata = json.decode(data.body);
                            String status = jsondata['status'];

                            te_message.text = "";

                            setState(() {});
                            print(status);

                            // refresh messages after send
                            await view_message();
                          } catch (e) {
                            print("Error ------------------- " +
                                e.toString());
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isSending = false;
                              });
                              _scrollToBottom();
                            }
                          }
                        },
                        backgroundColor: brandRed,
                        elevation: 0,
                        shape: const CircleBorder(),
                        child: _isSending
                            ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                          ),
                        )
                            : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botAvatar() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: brandRed.withOpacity(0.12),
        shape: BoxShape.circle,
        border: Border.all(color: brandRed.withOpacity(0.25)),
      ),
      child: Icon(Icons.smart_toy_rounded, color: brandRed, size: 18),
    );
  }

  Widget _userMiniDot() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: brandRed, shape: BoxShape.circle),
    );
  }

  Widget _typingBubble() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _dot(0),
          const SizedBox(width: 6),
          _dot(1),
          const SizedBox(width: 6),
          _dot(2),
          const SizedBox(width: 10),
          const Text(
            "Processing...",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black54,
            ),
          )
        ],
      ),
    );
  }

  Widget _dot(int i) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        final t = _dotController.value; // 0..1
        final phase = (t + i * 0.18) % 1.0;
        final scale = 0.7 + (phase < 0.5 ? phase : (1 - phase)) * 0.9;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: brandRed, shape: BoxShape.circle),
          ),
        );
      },
    );
  }
}

// ✅ message appear animation widget
class _AnimatedAppear extends StatelessWidget {
  final Widget child;

  const _AnimatedAppear({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      builder: (context, v, _) {
        final dy = (1 - v) * 10; // slide up
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, dy),
            child: child,
          ),
        );
      },
    );
  }
}
