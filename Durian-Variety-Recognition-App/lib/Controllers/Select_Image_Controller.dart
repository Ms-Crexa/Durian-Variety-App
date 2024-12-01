import 'package:durian_app/Controllers/display_image_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';

class SelectImageController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  RxList<XFile> selectedImages = <XFile>[].obs;
  final FirebaseStorage storageRef = FirebaseStorage.instance;
  bool isPickerActive = false; // Track the picker status

  // Show image picker dialog
  Future<void> showImagesPickerDialog(BuildContext context) async {
    if (kIsWeb) {
      // Web logic here...
    } else {
      PermissionStatus status;
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;

      // Request storage/media permission based on Android version
      status = (androidDeviceInfo.version.sdkInt <= 86)
          ? await Permission.storage.request()
          : await Permission.mediaLibrary.request();

      // If permission granted, show the dialog to pick image source
      if (status.isGranted) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              backgroundColor: Color(0xFFF8F0D8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Color(0xFF464653),
                  width: 3,
                ),
              ),
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "To proceed, please choose an image source:",
                  style: TextStyle(
                    color: Color(0xFF464653),
                    fontFamily: 'KodeMono',
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFEFBF),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF464653),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Color(0xFF464653),
                        width: 3,
                      ),
                    ),
                    onPressed: () {
                      if (!isPickerActive) {
                        selectImages('camera', context);
                      }
                    },
                    child: const Text(
                      'Camera',
                      style: TextStyle(color: Color(0xFF464653)),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFEFBF),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      textStyle: TextStyle(
                        fontFamily: 'KodeMono',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF464653),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Color(0xFF464653),
                        width: 3,
                      ),
                    ),
                    onPressed: () {
                      if (!isPickerActive) {
                        selectImages('gallery', context);
                      }
                    },
                    child: const Text(
                      'Gallery',
                      style: TextStyle(color: Color(0xFF464653)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        print('Permission denied, please allow permission for further usage');
        openAppSettings();
      }
    }
  }

  // Select images from camera or gallery
  Future<void> selectImages(String type, BuildContext context) async {
    if (isPickerActive) return; // Prevent multiple pickers from opening
    isPickerActive = true;

    try {
      if (kIsWeb) {
        // Web-specific image selection
        final List<XFile> images =
            await _picker.pickMultiImage(imageQuality: 80);
        if (images.isNotEmpty) {
          selectedImages.addAll(images);
          print("Selected image path on web: ${images.first.path}");
          navigateToDisplayPage(context, images.first.path);
        } else {
          print('No image selected from gallery');
        }
      } else {
        if (type == 'gallery') {
          List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
          if (images.isNotEmpty) {
            selectedImages.addAll(images);
            print("Selected image path from gallery: ${images.first.path}");
            navigateToDisplayPage(context, images.first.path);
          } else {
            print('No image selected from gallery');
          }
        } else {
          final XFile? img = await _picker.pickImage(
              source: ImageSource.camera, imageQuality: 80);
          if (img != null) {
            selectedImages.add(img);
            print("Selected image path from camera: ${img.path}");
            navigateToDisplayPage(context, img.path);
          } else {
            print('No image selected from camera');
          }
        }
      }
    } catch (error) {
      print('Error selecting images: $error');
    } finally {
      isPickerActive = false; // Reset after image selection is done
    }
  }

  // Navigate to display page with selected image
  void navigateToDisplayPage(BuildContext context, String imagePath) {
    print("Navigating to DisplayImagePage with image path: $imagePath");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayImagePage(imagePath: imagePath),
      ),
    );
  }
}

// class DisplayImagePage extends StatelessWidget {
//   final String imagePath;

//   const DisplayImagePage({super.key, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Selected Image')),
//       body: Center(
//         child: Image.file(
//           File(imagePath), // Display selected image
//         ),
//       ),
//     );
//   }
// }
