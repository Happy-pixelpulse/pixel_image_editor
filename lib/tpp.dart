import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'full_screen.dart';
import 'module/drawing_painter.dart';
import 'module/options.dart';


class _FullScreenState extends State<FullScreen> {
  final _controller = GlobalKey<ExtendedImageEditorState>();
  double? currentRatio;
  FocusNode _focusNode = FocusNode();
  late Uint8List imageBytes;  // Removed the nullability
  late Widget image;          // Removed the nullability
  int _selectedIndex = 0;
  final GlobalKey _repaintBoundary = GlobalKey();
  bool _showfilterlist = false;
  bool _cropimage = false;
  bool _showBrushOptions = false;
  bool _showTextField = false;
  Color selectedTextColor = Colors.black;
  ColorFilterGenerator selectedFilter = PresetFilters.none;
  double rotationAngle = 0;
  late List<ColorFilterGenerator> filters;
  String? userEnteredText;
  Offset textPosition = const Offset(50, 50);
  final TextEditingController _textEditingController = TextEditingController();
  List<Offset?> points = [];
  double strokeWidth = 3.0;
  Color brushColor = Colors.white;

  BrushOption brushOption = const BrushOption();
  final List<Color> textColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.indigo,
    Colors.lightGreenAccent,
    const Color.fromRGBO(236, 153, 255, 1)
  ];

  @override
  void initState() {
    filters = [PresetFilters.none, ...presetFiltersList.sublist(1)];
    loadBytes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    super.initState();
  }

  void loadBytes() async {
    imageBytes = await widget.image.readAsBytes();
    image = Image.memory(
      imageBytes,
      fit: BoxFit.contain,
    );
    setState(() {});
  }

  void _sharePressed() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundary.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/shared_image.png').create();
      await file.writeAsBytes(pngBytes);

      final result =
      await Share.shareXFiles([XFile(file.path)], text: 'Great picture 😊');
      if (result.status == ShareResultStatus.success) {
        if (kDebugMode) {
          print('Thank you for sharing the picture!');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _SaveImage() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundary.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final params = SaveFileDialogParams(
        data: pngBytes,
        fileName: "pixel_image_editor_${DateTime.now()}.png",
      );
      final filePath = await FlutterFileDialog.saveFile(params: params);

      if (filePath != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Image saved to $filePath')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save image')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _onCheckPressed() async {
    if (_cropimage) {
      try {
        final editorState = _controller.currentState;
        final cropRect = editorState?.getCropRect();
        if (cropRect != null) {
          final newBytes = await cropImageWithThread(
            imageBytes: imageBytes,
            rect: cropRect,
          );

          if (newBytes != null) {
            setState(() {
              imageBytes = newBytes;
              image = Image.memory(imageBytes);  // Re-initialize without null check
              _cropimage = false;
            });
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cropping image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.edit, color: Colors.black), label: 'Filter'),
          BottomNavigationBarItem(
              icon: Icon(Icons.crop, color: Colors.black), label: 'Crop'),
          BottomNavigationBarItem(
              icon: Icon(Icons.rotate_left, color: Colors.black),
              label: 'Rotate Left'),
          BottomNavigationBarItem(
              icon: Icon(Icons.rotate_right, color: Colors.black),
              label: 'Rotate Right'),
          BottomNavigationBarItem(
              icon: Icon(Icons.text_fields, color: Colors.black),
              label: 'Text'),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit, color: Colors.black), label: 'Brush'),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        onTap: _onBottomNavigationBarTap,
      ),
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Edit Image",
          style: TextStyle(
            wordSpacing: 4,
            // letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _SaveImage,
            icon: const Icon(Icons.download),
            iconSize: 24,
          ),
          IconButton(
            onPressed: _sharePressed,
            icon: const Icon(Icons.share),
            iconSize: 24,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _onCheckPressed,
            iconSize: 24,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_cropimage)
            Flexible(
              child: RepaintBoundary(
                key: _repaintBoundary,
                child: ExtendedImage.file(
                  widget.image,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  extendedImageEditorKey: _controller,
                  initEditorConfigHandler: (state) {
                    return EditorConfig(
                      cropRectPadding: const EdgeInsets.all(20.0),
                      cropAspectRatio: currentRatio,
                    );
                  },
                ),
              ),
            ),
          if (!_cropimage)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Transform.rotate(
                  angle: rotationAngle,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(selectedFilter.matrix),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                userEnteredText = _textEditingController.text;
                                _showTextField = false;
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                userEnteredText = null;
                              });
                            },
                            onScaleUpdate: (details) {
                              if (_showTextField) {
                                setState(() {
                                  textPosition = Offset(
                                    textPosition.dx +
                                        details.focalPointDelta.dx,
                                    textPosition.dy +
                                        details.focalPointDelta.dy,
                                  );
                                });
                              }
                              if (_showBrushOptions) {
                                setState(() {
                                  points.add(details.localFocalPoint);
                                });
                              }
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                image,
                                if (_showTextField)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: TextField(
                                      focusNode: _focusNode,
                                      controller: _textEditingController,
                                      decoration: const InputDecoration(
                                          hintText: "Enter text"),
                                    ),
                                  ),
                                Positioned(
                                  top: textPosition.dy,
                                  left: textPosition.dx,
                                  child: userEnteredText != null
                                      ? Text(
                                    userEnteredText!,
                                    style: TextStyle(
                                      color: selectedTextColor,
                                      fontSize: 20,
                                    ),
                                  )
                                      : const SizedBox(),
                                ),
                                CustomPaint(
                                  painter: DrawingPainter(
                                      points, strokeWidth, brushColor),
                                  size: Size.infinite,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_showTextField)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: textColors.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTextColor = textColors[index];
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: textColors[index],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onBottomNavigationBarTap(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          _showfilterlist = !_showfilterlist;
          _cropimage = false;
          _showBrushOptions = false;
          _showTextField = false;
          break;
        case 1:
          _cropimage = !_cropimage;
          _showfilterlist = false;
          _showBrushOptions = false;
          _showTextField = false;
          break;
        case 2:
          setState(() {
            rotationAngle -= pi / 2;
          });
          break;
        case 3:
          setState(() {
            rotationAngle += pi / 2;
          });
          break;
        case 4:
          _showTextField = !_showTextField;
          _focusNode.requestFocus();
          _showfilterlist = false;
          _showBrushOptions = false;
          _cropimage = false;
          break;
        case 5:
          _showBrushOptions = !_showBrushOptions;
          _showTextField = false;
          _showfilterlist = false;
          _cropimage = false;
          break;
      }
    });
  }
}
