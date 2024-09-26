import 'dart:io';

import 'package:edit_image/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'full_screen.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
   File? image;

  // @override
  // void initState() {
  //   image;
  //   super.initState();
  // }

  bool isSwitched = false;

  Future<void> pickImagefromGallery() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        image = File(pickedImage.path);
        setState(() {});
      } else {
        print('User didn\'t pick any image.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> pickImagefromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          image = File(pickedImage.path);
        });
      } else {
        print('User didn\'t pick any image.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text("Image Edit"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Switch(
              value: isSwitched,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
                setState(() {
                  isSwitched = value;
                });
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
        child: ButtonBar(
          // alignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // background color
              ),
              onPressed: () {
                _showDialog(context);
              },
              child: const Text(
                'Add Image',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      useSafeArea: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick the image'),
          actions: [
            Align(
              alignment: Alignment.center,
              child: MaterialButton(
                color: Colors.blue,
                child: const Text("Pick Image from Gallery",
                    style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await pickImagefromGallery();
                  Navigator.pop(context);
                  _showDialog(context);
                },
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: MaterialButton(
                color: Colors.blue,
                child: const Text("Pick Image from Camera",
                    style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  await pickImagefromCamera();
                  Navigator.pop(context);
                  _showDialog(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 120, right: 10, top: 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                       if (image != null) {

                         Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (context) =>
                                 FullScreen(
                                   image: image!,
                                 ),
                           ),
                         );
                       }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
