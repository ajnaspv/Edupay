// import 'dart:convert';
//
// import 'package:edupay/home.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// void main(){
//   runApp(raisecomplaint());
// }
//
// class raisecomplaint extends StatelessWidget {
//   const raisecomplaint({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: raisecomplaintsub(),);
//   }
// }
//
//
// class raisecomplaintsub extends StatefulWidget {
//   const raisecomplaintsub({Key? key}) : super(key: key);
//
//   @override
//   State<raisecomplaintsub> createState() => _raisecomplaintsubState();
// }
//
// class _raisecomplaintsubState extends State<raisecomplaintsub> {
//
//   final title = new TextEditingController();
//   final category = new TextEditingController();
//   final description = new TextEditingController();
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Form(child:Column(
//         children: [
//
//
//
//           TextFormField(controller: title,decoration: InputDecoration(hintText: "Title"),),
//
//           TextFormField(controller: category,decoration: InputDecoration(hintText: "Category"),),
//
//           TextFormField(controller:description,decoration: InputDecoration(hintText: "Description"),),
//
//           ElevatedButton(onPressed: () async {SharedPreferences sh = await SharedPreferences.getInstance();}, child: Text("Choose")),
//
//           ElevatedButton(onPressed: () async {
//             SharedPreferences sh = await SharedPreferences.getInstance();
//             var data = await http.post(Uri.parse( sh.getString("ip").toString() + "/Uraise_complaint" ),body: {
//               'title':title.text,
//               'category':category.text,
//               'description':description.text,
//               "mobile":sh.getString("mobile"),
//
//             });
//             var jsonData = json.decode(data.body);
//
//             Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));
//           }, child: Text("Raise Complaint"))
//
//         ],
//       ) ,),
//       appBar: AppBar(title: Text("Complaint"),leading: IconButton(icon:Icon(Icons.arrow_back),onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context)=>home()));})),
//     );
//   }
// }
import 'dart:convert';
import 'dart:io';

import 'package:edupay/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(raisecomplaint());
}

class raisecomplaint extends StatelessWidget {
  const raisecomplaint({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: raisecomplaintsub(),
    );
  }
}

class raisecomplaintsub extends StatefulWidget {
  const raisecomplaintsub({Key? key}) : super(key: key);

  @override
  State<raisecomplaintsub> createState() => _raisecomplaintsubState();
}

class _raisecomplaintsubState extends State<raisecomplaintsub> {
  final title = TextEditingController();
  final category = TextEditingController();
  final description = TextEditingController();

  // dynamic hint for description field
  String _descriptionHint = "Description";

  // ✅ dropdown data (college-related)
  final List<String> _categories = [
    "Canteen",
    "Payment / Fees",
    "Library",
    "Hostel",
    "Classroom / Lab",
    "Exam / Result",
    "Transport / Bus",
    "Sports / Arts",
    "Office / Staff",
    "Scholarship / Concession",
    "ID Card / Certificate",
    "Other",
  ];

  String _selectedCategory = "Canteen";

  // ✅ Image picker & file storage
  final ImagePicker _imagePicker = ImagePicker();
  List<File> _selectedImages = []; // List to store multiple images
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    category.text = _selectedCategory;
    // set initial description hint based on default category
    if (_selectedCategory.toLowerCase().contains('payment')) {
      _descriptionHint = 'Describe Complaint With transaction ID';
    }
  }

  @override
  void dispose() {
    title.dispose();
    category.dispose();
    description.dispose();
    super.dispose();
  }

  // ✅ Capture from camera
  Future<void> _captureFromCamera() async {
    try {
      final XFile? photo =
      await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      print("Camera error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera error: $e")),
      );
    }
  }

  // ✅ Pick from gallery/files
  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      print("Gallery error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gallery error: $e")),
      );
    }
  }

  // ✅ Remove image from list
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // ✅ Upload images to Django server with multipart/form-data
  Future<void> _uploadComplaint() async {
    if (title.text.isEmpty || description.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      SharedPreferences sh = await SharedPreferences.getInstance();
      String ip = sh.getString("ip") ?? "http://localhost:8000";
      String mobile = sh.getString("mobile") ?? "";

      // ✅ Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$ip/Uraise_complaint"),
      );

      // Add form fields
      request.fields['title'] = title.text;
      request.fields['category'] = category.text;
      request.fields['description'] = description.text;
      request.fields['mobile'] = mobile;

      // Add images
      for (int i = 0; i < _selectedImages.length; i++) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'images', // Backend expects 'images' (or customize field name)
            _selectedImages[i].path,
          ),
        );
      }

      // ✅ Send request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonData = json.decode(responseBody);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complaint raised successfully!")),
        );

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => home()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload error: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
          "Complaint",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            children: [
              // Header card
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
                  "Raise Your Complaint",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Form card
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
                    // Title
                    TextFormField(
                      controller: title,
                      decoration: InputDecoration(
                        hintText: "Title",
                        prefixIcon: const Icon(Icons.title),
                        filled: true,
                        fillColor: const Color(0xFFF4F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Category Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories
                            .map((c) => DropdownMenuItem<String>(
                          value: c,
                          child: Text(c),
                        ))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _selectedCategory = v;
                            category.text = v;
                            // change description hint when category is payment
                            if (v.toLowerCase().contains('payment')) {
                              _descriptionHint = 'Describe Complaint With transaction ID';
                            } else {
                              _descriptionHint = 'Description';
                            }
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Description
                    TextFormField(
                      controller: description,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: _descriptionHint,
                        prefixIcon: const Icon(Icons.description),
                        filled: true,
                        fillColor: const Color(0xFFF4F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ✅ Image selection buttons
                    Text(
                      "Add Images (${_selectedImages.length})",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Camera button
                        ElevatedButton.icon(
                          onPressed: _captureFromCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text("Camera"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        // Gallery button
                        ElevatedButton.icon(
                          onPressed: _pickFromGallery,
                          icon: const Icon(Icons.image),
                          label: const Text("Gallery"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),

                        // Plus button for more images
                        FloatingActionButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt),
                                      title: const Text("Capture from Camera"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _captureFromCamera();
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.image),
                                      title: const Text("Pick from Gallery"),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickFromGallery();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          backgroundColor: const Color(0xFFE53935),
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ✅ Display selected images
                    if (_selectedImages.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                // Image
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),

                                // Delete button
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => _removeImage(index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),

                    // Raise Complaint button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _uploadComplaint,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          "RAISE COMPLAINT",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
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
