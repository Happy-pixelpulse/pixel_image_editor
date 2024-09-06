import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../data/layer.dart';


class TextEditorImage extends StatefulWidget {
  const TextEditorImage({super.key});

  @override
  createState() => _TextEditorImageState();
}

class _TextEditorImageState extends State<TextEditorImage> {
  TextEditingController name = TextEditingController();
  Color currentColor = Colors.black;
  double slider = 32.0;
  TextAlign align = TextAlign.left;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.alignLeft,
                color: align == TextAlign.left
                    ? Colors.red
                    : Colors.red.withAlpha(80)
            ),
            onPressed: () {
              setState(() {
                align = TextAlign.left;
              });
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.alignCenter,
                color: align == TextAlign.center
                    ? Colors.blue
                    : Colors.blue.withAlpha(80)),
            onPressed: () {
              setState(() {
                align = TextAlign.center;
              });
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.alignRight,
                color: align == TextAlign.right
                    ? Colors.green
                    : Colors.green.withAlpha(80)),
            onPressed: () {
              setState(() {
                align = TextAlign.right;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(
                context,
                TextLayerData(
                  background: Colors.transparent,
                  text: name.text,
                  color: currentColor,
                  size: slider.toDouble(),
                  align: align,
                ),
              );
            },
            color: Colors.blueAccent,
            padding: const EdgeInsets.all(15),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            SizedBox(
              height: size.height / 2.2,
              child: TextField(
                controller: name,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding:  EdgeInsets.all(10),
                  hintText:('Insert Your Message'),
                  hintStyle:  TextStyle(color: Colors.white),
                  alignLabelWithHint: true,
                ),
                scrollPadding: const EdgeInsets.all(20.0),
                keyboardType: TextInputType.multiline,
                minLines: 5,
                maxLines: 99999,
                style: TextStyle(
                  color: currentColor,
                ),
                autofocus: true,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}