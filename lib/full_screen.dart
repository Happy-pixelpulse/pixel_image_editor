import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:edit_image/filter/options.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
 import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  Uint8List? imageBytes;
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
  //List<DrawingPoint> savedBrushStrokes = [];

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
                        colorFilter:
                            ColorFilter.matrix(selectedFilter.matrix),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                _cropimage
                                    ? Flexible(
                                        child: ExtendedImage.memory(
                                          imageBytes!,
                                          cacheRawData: true,
                                          fit: BoxFit.contain,
                                          extendedImageEditorKey: _controller,
                                          mode: ExtendedImageMode.editor,
                                          initEditorConfigHandler: (state) {
                                            return EditorConfig(
                                                cropAspectRatio:
                                                    currentRatio);
                                          },
                                        ),
                                      )
                                    : Image.memory(
                                        imageBytes!,
                                        fit: BoxFit.contain,
                                      ),
                                if (_showBrushOptions)
                                  GestureDetector(
                                    onScaleStart: (details) {
                                      if (_showBrushOptions) {
                                        setState(() {
                                          points.add(details.localFocalPoint);
                                        });
                                      }
                                    },
                                    onScaleUpdate: (details) {
                                      if (_showBrushOptions) {
                                        setState(() {
                                          points.add(details.localFocalPoint);
                                        });
                                      } else if (userEnteredText != null) {
                                        setState(() {
                                          textPosition = Offset(
                                            textPosition.dx + details.focalPointDelta.dx,
                                            textPosition.dy + details.focalPointDelta.dy,
                                          );
                                        });
                                      }
                                    },
                                    onScaleEnd: (details) {
                                      if (_showBrushOptions) {
                                        setState(() {
                                          points.add(null);
                                        });
                                      }
                                    },
                                    child: CustomPaint(
                                      painter: DrawingPainter(
                                          points, strokeWidth, brushColor),
                                      size: Size.infinite,
                                    ),
                                  ),
                                if (_showTextField)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      right: 8,
                                    ),
                                    child: TextField(
                                      controller: _textEditingController,
                                      decoration: const InputDecoration(
                                          hintText: "Enter text"),
                                    ),
                                  ),
                                Positioned(
                                  top: textPosition.dy,
                                  left: textPosition.dx,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        userEnteredText =
                                            _textEditingController.text;
                                        _showTextField = false;
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
                                    },
                                    onDoubleTap: () {
                                      setState(() {
                                        userEnteredText = null;
                                      });
                                    },
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
                                                margin: const EdgeInsets
                                                    .symmetric(horizontal: 5),
                                                width: 40,
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: color,
                                                  border: Border.all(
                                                    color:
                                                    selectedTextColor ==
                                                        color
                                                        ? Colors.white
                                                        : Colors
                                                        .transparent,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
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
      _showTextField = false;
    });
  }
  void _cropOptions() {
    setState(() {
      _showfilterlist = false;
      _cropimage = !_cropimage;
      _showBrushOptions = false;
      _showTextField = false;
    });
  }
  void _rotateLeftOption() {
    setState(() {
      _showfilterlist = false;
      _cropimage = false;
      _showBrushOptions = false;
      rotationAngle += math.pi / 4;
    });
  }
  void _rotateRightOption() {
    setState(() {
      _showfilterlist = false;
      _cropimage = false;
      _showBrushOptions = false;
      rotationAngle -= math.pi / 4;
    });
  }
  void _addText() {
    setState(() {
      _showTextField = !_showTextField;
      _showfilterlist = false;
      _cropimage = false;
      _showBrushOptions = false;
    });
    if (!_showTextField) {
      setState(() {
        userEnteredText = _textEditingController.text;
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
    if (!_showBrushOptions) {
      setState(() {
        // Save the current brush strokes or update them
        //savedBrushStrokes = List.from(points); // Assuming 'points' holds the current brush strokes
      });
    }

  }
}
class FilterAppliedImage extends StatefulWidget {
  final Uint8List image;
  final ColorFilterGenerator filter;
  final BoxFit? fit;
  final Function(Uint8List)? onProcess;
  final double opacity;

  const FilterAppliedImage({
    super.key,
    required this.image,
    required this.filter,
    this.fit,
    this.onProcess,
    this.opacity = 1,
  });

  @override
  State<FilterAppliedImage> createState() => _FilterAppliedImageState();
}

class _FilterAppliedImageState extends State<FilterAppliedImage> {
  @override
  initState() {
    super.initState();

    if (widget.onProcess != null) {
      // no filter supplied
      if (widget.filter.filters.isEmpty) {
        widget.onProcess!(widget.image);
        return;
      }

      var filterTask = img.Command();
      filterTask.decodeImage(widget.image);

      var matrix = widget.filter.matrix;

      filterTask.filter((image) {
        for (final pixel in image) {
          pixel.r = matrix[0] * pixel.r +
              matrix[1] * pixel.g +
              matrix[2] * pixel.b +
              matrix[3] * pixel.a +
              matrix[4];

          pixel.g = matrix[5] * pixel.r +
              matrix[6] * pixel.g +
              matrix[7] * pixel.b +
              matrix[8] * pixel.a +
              matrix[9];

          pixel.b = matrix[10] * pixel.r +
              matrix[11] * pixel.g +
              matrix[12] * pixel.b +
              matrix[13] * pixel.a +
              matrix[14];

          pixel.a = matrix[15] * pixel.r +
              matrix[16] * pixel.g +
              matrix[17] * pixel.b +
              matrix[18] * pixel.a +
              matrix[19];
        }
        return image;
      });
      filterTask.getBytesThread().then((result) {
        if (widget.onProcess != null && result != null) {
          widget.onProcess!(result);
        }
      }).catchError((err, stack) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filter.filters.isEmpty) {
      return Image.memory(
        widget.image,
        fit: widget.fit,
      );
    }

    return Opacity(
      opacity: widget.opacity,
      child: widget.filter.build(
        Image.memory(
          widget.image,
          fit: widget.fit,
        ),
      ),
    );
  }
}

class ColorButton extends StatelessWidget {
  final Color color;
  final Function(Color) onTap;
  final bool isSelected;

  const ColorButton({
    super.key,
    required this.color,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(color);
      },
      child: Container(
        height: 34,
        width: 34,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 23),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.yellowAccent : Colors.white54,
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset?> points;
  final double strokeWidth;
  final Color brushColor;

  DrawingPainter(this.points, this.strokeWidth, this.brushColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = brushColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [points[i]!], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
