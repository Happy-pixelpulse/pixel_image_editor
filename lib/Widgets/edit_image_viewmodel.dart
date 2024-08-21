


import 'package:edit_image/full_screen.dart';
import 'package:edit_image/models/text_info.dart';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';



abstract class EditImageViewModel extends State<FullScreen> {
  TextEditingController textEditingController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  List<TextInfo> texts = [];

  // saveToGallery(BuildContext context) {
  //   screenshotController.capture().then((File ? widget.image){
  //   saveImage();
  //   }).catchError((err) => print('err'));
  // }

  // saveImage(Unit8List) async {
  //   final time = DateTime.now().toIso8601String()
  //       .replaceAll('.', '-')
  //       .replaceAll(':', '-');
  //   final name =  "screenshort_$time";
  //   await requestPermission(Permission.storage);
  //   await ImageGallerySaver.saveImage(bytes, name: name);
  // }

  // addNewText(BuildContext context) {
  //   setState(() {
  //     texts.add(
  //       TextInfo(
  //           text: textEditingController.text,
  //           left: 0,
  //           top: 0,
  //           color: Colors.purple,
  //           fontWeight: FontWeight.bold,
  //           fontStyle: FontStyle.italic,
  //           fontSize: 22,
  //           textAlign: TextAlign.center),
  //     );
  //   });
  // }
  //
  // addNewDialog(context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) =>
  //         AlertDialog(
  //           title: Text("Add new Text"),
  //           content: TextFormField(
  //             controller: textEditingController,
  //             maxLines: 3,
  //             decoration: InputDecoration(
  //               suffixIcon: Icon(Icons.edit),
  //               filled: true,
  //               hintText: 'Enter the Text',
  //             ),
  //           ),
  //           actions: <Widget>[
  //             DefultButton(
  //                 onPressed: () => Navigator.of(context).pop(),
  //                 child: Text("Add Text"),
  //                 color: Colors.white,
  //                 textColor: Colors.black),
  //             DefultButton(
  //                 onPressed: () {},
  //                 child: Text("Back"),
  //                 color: Colors.white,
  //                 textColor: Colors.black)
  //           ],
  //         ),
  //   );
  // }
}
