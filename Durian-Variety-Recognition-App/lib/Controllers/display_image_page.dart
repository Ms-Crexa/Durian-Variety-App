import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:durian_app/Pages/result_page.dart';
import '../../Controllers/select_image_controller.dart';
import 'package:get/get.dart';

class DisplayImagePage extends StatefulWidget {
  final String imagePath;

  const DisplayImagePage({super.key, required this.imagePath});

  @override
  State<DisplayImagePage> createState() => _DisplayImagePageState();
}

class _DisplayImagePageState extends State<DisplayImagePage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  SelectImageController selectImageController =
      Get.put(SelectImageController());

  bool isLoading = false;

  Future<void> identifyImage(BuildContext context) async {
    if (widget.imagePath.isEmpty) {
      print('No image selected');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      File imageFile = File(widget.imagePath);
      String fileName = basename(imageFile.path);

      var uri = Uri.parse('https://d056-143-44-184-180.ngrok-free.app/predict');
      var request = http.MultipartRequest('POST', uri);

      // Add image file to the request
      var multipartFile = await http.MultipartFile.fromPath(
          'image', imageFile.path,
          filename: fileName);
      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var responseData = json.decode(responseBody);

        var predictedClass = responseData['predicted_class'];
        print('Predicted class: $predictedClass');

        await storePrediction(predictedClass);

        // Navigate to result page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(result: predictedClass),
          ),
        );
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error during request: $error');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> storePrediction(String predictedClass) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      print('No user logged in');
      return;
    }

    // Reference to the user's durian varieties collection
    DocumentReference userRef = firestore.collection('users').doc(user.uid);
    CollectionReference varietiesRef = userRef.collection('varieties');

    try {
      // Check if the predicted class is already stored for the user
      var querySnapshot =
          await varietiesRef.where('name', isEqualTo: predictedClass).get();

      if (querySnapshot.docs.isEmpty) {
        // If not found, add the predicted class
        await varietiesRef.add({
          'name': predictedClass,
          'unlocked_at': FieldValue.serverTimestamp(),
        });
        print('New variety stored: $predictedClass');
      } else {
        print('Variety already unlocked: $predictedClass');
      }
    } catch (e) {
      print('Error storing prediction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FFAA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: AppBar(
          backgroundColor: const Color(0xFFFFEFBF),
          elevation: 0,
          titleSpacing: 0,
          title: const Text(
            'Captured Image',
            style: TextStyle(
              fontFamily: 'KodeMono',
              fontWeight: FontWeight.w600,
              color: Color(0xFF464653),
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: Color(0xFF464653),
              size: 30,
            ),
            onPressed: () =>
                selectImageController.showImagesPickerDialog(context),
          ),
          shape: const RoundedRectangleBorder(
            side: BorderSide(color: Color(0xFF464653), width: 5),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFF464653),
                    width: 4.0,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFEFBF),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: const TextStyle(
                    fontFamily: 'KodeMono',
                    fontSize: 24,
                    fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                side: const BorderSide(
                  color: Color(0xFF464653),
                  width: 3,
                ),
              ),
              onPressed: isLoading ? null : () => identifyImage(context),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Color(0xFF464653),
                        strokeWidth: 3,
                      ),
                    )
                  : const Text('Identify'),
            ),
          ],
        ),
      ),
    );
  }
}
