import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'module/color_button.dart';
import 'module/drawing_painter.dart';
import 'module/filter_applied_image.dart';
import 'module/options.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({
    super.key,
    required this.image,
  });

  final File image;

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  final _controller = GlobalKey<ExtendedImageEditorState>();
  double? currentRatio;
  FocusNode _focusNode=FocusNode();
  Uint8List? imageBytes;
  Widget? image;
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
    image= Image.memory(
      imageBytes!,
      fit: BoxFit.contain,
    );
    setState(() {

    });
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
            wordSpacing: 5,
            letterSpacing: 2,
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
        ],
      ),
      body: Column(
        children: [
          if (imageBytes != null)
            Flexible(
              flex: 2,
              child: RepaintBoundary(
                key: _repaintBoundary,
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
                            child:
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  userEnteredText =
                                      _textEditingController.text;
                                  _showTextField = false;
                                });
                              },
                              onLongPress: () {
                                setState(() {
                                  userEnteredText = null;
                                });
                              },
                              onScaleUpdate: (details) {
                                setState(() {
                                  textPosition = Offset(
                                    textPosition.dx +
                                        details.focalPointDelta.dx,
                                    textPosition.dy +
                                        details.focalPointDelta.dy,
                                  );
                                });
                                if(_showBrushOptions) {
                                  setState(() {
                                    points.add(details.localFocalPoint);
                                  });
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _cropimage
                                      ? Flexible(
                                    child: ExtendedImage.memory(
                                      imageBytes!,
                                      cacheRawData: false,
                                      fit: BoxFit.contain,
                                      extendedImageEditorKey: _controller,
                                      mode: ExtendedImageMode.editor,
                                      initEditorConfigHandler: (state) {
                                        return EditorConfig(
                                            cropAspectRatio: currentRatio);
                                      },
                                    ),
                                  )
                                      : image!,
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
                                    // child: image,
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
            ),
          if (_showTextField)
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 70,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var color in textColors)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedTextColor = color;
                          });
                        },
                        child: Container(
                          margin:
                          const EdgeInsets.symmetric(
                              horizontal: 5),
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color,
                            border: Border.all(
                              color: selectedTextColor ==
                                  color
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (_showBrushOptions)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.grey,
                child: SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (BrushColor brush in brushOption.colors)
                        ColorButton(
                          color: brush.color,
                          //background: brush.background,
                          onTap: (selectedColor) {
                            brushColor = selectedColor;
                            setState(() {});
                          },
                          isSelected: brushColor == brush.color,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          if (_showfilterlist)
            SizedBox(
              height: 120,
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (var filter in filters)
                          GestureDetector(
                            onTap: () {
                              selectedFilter = filter;
                              setState(() {});
                            },
                            child: Column(
                              children: [
                                Container(
                                  height: 64,
                                  width: 64,
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(48),
                                    border: Border.all(
                                      color: selectedFilter == filter
                                          ? Colors.black
                                          : Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(48),
                                    child: FilterAppliedImage(
                                      key: Key(
                                          'filterPreviewButton:${filter.name}'),
                                      image: imageBytes!,
                                      filter: filter,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  filter.name,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _onBottomNavigationBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (_selectedIndex) {
      case 0:
        {
          _filterOptions();
        }
        break;
      case 1:
        {
          _cropOptions();
        }
        break;
      case 2:
        {
          _rotateLeftOption();
        }
        break;
      case 3:
        {
          _rotateRightOption();
        }
        break;
      case 4:
        {
          _addText();
        }
        break;
      case 5:
        {
          _brushOption();
        }
      default:
        {
          if (kDebugMode) {
            print("Dhanywada");
          }
        }
        break;
    }
  }

  void _filterOptions() {
    setState(() {
      _showfilterlist = !_showfilterlist;
      _cropimage = false;
      _showBrushOptions = false;
      _focusNode.unfocus();
      _showTextField = false;
    });
  }

  void _cropOptions() {
    setState(() {
      _showfilterlist = false;
      _cropimage = !_cropimage;
      _showBrushOptions = false;
      _showTextField = false;
      _focusNode.unfocus();
    });
  }

  void _rotateLeftOption() {
    setState(() {
      _showfilterlist = false;
      _cropimage = false;
      _showBrushOptions = false;
      rotationAngle += math.pi / 4;
      _focusNode.unfocus();
    });
  }

  void _rotateRightOption() {
    setState(() {
      _showfilterlist = false;
      _cropimage = false;
      _showBrushOptions = false;
      rotationAngle -= math.pi / 4;
      _focusNode.unfocus();
    });
  }

  void _addText() {
    setState(() {
      _showTextField = true;
      _showfilterlist = false;
      _cropimage = false;
      _showBrushOptions = false;
    });
    if (_showTextField) {

      setState(() {
        userEnteredText = _textEditingController.text;
        _focusNode.requestFocus();
      });
    }
  }

  void _brushOption() {
    setState(() {
      _showBrushOptions = !_showBrushOptions;
      if (_showBrushOptions) {
        _showfilterlist = false;
        _cropimage = false;
        _showTextField = false;
      }
    });

  }
}

