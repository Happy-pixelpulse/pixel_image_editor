// import 'dart:io';
// import 'dart:math' as math;
//
// import 'package:colorfilter_generator/colorfilter_generator.dart';
// import 'package:colorfilter_generator/presets.dart';
// import 'package:edit_image/data/layer.dart';
// import 'package:extended_image/extended_image.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_file_dialog/flutter_file_dialog.dart';
// import 'package:image/image.dart' as img;
// //import 'package:screenshot/screenshot.dart';
// import 'package:share_plus/share_plus.dart';
//
// // import 'data/image_item.dart';
// //import 'filter/options.dart' as o;
//
// List<Layer> layers = [], undoLayers = [], removedLayers = [];
//
// class FullScreen extends StatefulWidget {
//   const FullScreen({
//     super.key,
//     required this.image,
//   });
//
//   final File image;
//
//   @override
//   State<FullScreen> createState() => _FullScreenState();
// }
//
// class _FullScreenState extends State<FullScreen> {
//   // List<ImageItem> images = [];
//
//   final _controller = GlobalKey<ExtendedImageEditorState>();
//   double? currentRatio;
//
//   Uint8List? imageBytes;
//
//   void loadBytes() async {
//     imageBytes = await widget.image.readAsBytes();
//   }
//
//   void _sharePressed() async {
//     final result = await Share.shareXFiles([XFile(widget.image.path)],
//         text: 'Great picture 😊');
//     if (result.status == ShareResultStatus.success) {
//       if (kDebugMode) {
//         print('Thank you for sharing the picture!');
//       }
//     }
//   }
//
//   Future<void> _saveImage(BuildContext context) async {
//     String? message;
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     try {
//       final params = SaveFileDialogParams(sourceFilePath: widget.image.path);
//       final finalPath = await FlutterFileDialog.saveFile(params: params);
//
//       if (finalPath != null) {
//         message = 'Image saved to disk';
//       }
//     } catch (e) {
//       message = 'An error occurred while saving the image';
//     }
//
//     if (message != null) {
//       scaffoldMessenger.showSnackBar(SnackBar(content: Text(message)));
//     }
//   }
//
//   // ScreenshotController screenshotController = ScreenshotController();
//   int _selectedIndex = 0;
//   bool _showfilterlist = false;
//   bool _cropimage = false;
//   ColorFilterGenerator selectedFilter = PresetFilters.none;
//   double filterOpacity = 1;
//   double rotationAngle = 0;
//
//   // Uint8List resizedImage = Uint8List.fromList([]);
//   // List<CubicPath> undoList = [];
//   Uint8List? filterAppliedImage;
//   late List<ColorFilterGenerator> filters;
//   double flipValue = 0;
//   int rotateValue = 0;
//
//   // double x = 0;
//   // double y = 0;
//   // double z = 0;
//   //
//   // double lastScaleFactor = 1, scaleFactor = 1;
//   // double widthRatio = 1, heightRatio = 1, pixelRatio = 1;
//
//   // Future<Uint8List?> getMergedImage([
//   //   o.OutputFormat format = o.OutputFormat.png,
//   // ]) async {
//   //   Uint8List? image;
//   //
//   //   if (flipValue != 0 || rotateValue != 0 || layers.length > 1) {
//   //     image = await screenshotController.capture(pixelRatio: pixelRatio);
//   //   } else if (layers.length == 1) {
//   //     if (layers.first is BackgroundLayerData) {
//   //       image = (layers.first as BackgroundLayerData).image.bytes;
//   //     } else if (layers.first is ImageLayerData) {
//   //       image = (layers.first as ImageLayerData).image.bytes;
//   //     }
//   //   }
//   //
//   //   // conversion for non-png
//   //   if (image != null && format == o.OutputFormat.jpeg) {
//   //     var decodedImage = img.decodeImage(image);
//   //
//   //     if (decodedImage == null) {
//   //       throw Exception('Unable to decode image for conversion.');
//   //     }
//   //
//   //     return img.encodeJpg(decodedImage);
//   //   }
//   //
//   //   return image;
//   // }
//
//   @override
//   void initState() {
//     filters = [PresetFilters.none, ...presetFiltersList.sublist(1)];
//     // images = widget.images.map((e) => ImageItem(e)).toList();
//     loadBytes();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {});
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationBar(
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.edit, color: Colors.black), label: 'Filter'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.crop, color: Colors.black), label: 'Croup'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.rotate_left, color: Colors.black),
//               label: 'Rotate Left'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.rotate_right, color: Colors.black),
//               label: 'Rotate Right'),
//         ],
//         currentIndex: _selectedIndex,
//         backgroundColor: Colors.white,
//         selectedItemColor: Colors.black,
//         onTap: _onBottomNavigationBarTap,
//       ),
//       appBar: AppBar(
//         title: const Text("Edit Image"),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             onPressed: () {
//               _saveImage(context);
//             },
//             icon: const Icon(Icons.download),
//             iconSize: 24,
//           ),
//           IconButton(
//             onPressed: _sharePressed,
//             icon: const Icon(Icons.share),
//             iconSize: 24,
//           ),
//           IconButton(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             icon: const Icon(Icons.check),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           if (imageBytes != null)
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Transform.rotate(
//                   angle: rotationAngle,
//                   child: ColorFiltered(
//                     colorFilter: ColorFilter.matrix(selectedFilter.matrix),
//                     child: Center(
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: _cropimage ?  Flexible(
//                           child: ExtendedImage.memory(
//                             imageBytes!,
//                             cacheRawData: true,
//                             fit: BoxFit.contain,
//                             extendedImageEditorKey: _controller,
//                             mode: ExtendedImageMode.editor,
//                             initEditorConfigHandler: (state) {
//                               return EditorConfig(
//                                 cropAspectRatio: currentRatio,
//                               );
//                             },
//                           ),
//                         ) :
//                         Image.memory(
//                           imageBytes!,
//                           fit: BoxFit.contain,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           if (_showfilterlist)
//             SizedBox(
//               height: 120,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     height: 120,
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       children: [
//                         for (var filter in filters)
//                           GestureDetector(
//                             onTap: () {
//                               selectedFilter = filter;
//                               setState(() {});
//                             },
//                             child: Column(children: [
//                               Container(
//                                 height: 64,
//                                 width: 64,
//                                 margin: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 12,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(48),
//                                   border: Border.all(
//                                     color: selectedFilter == filter
//                                         ? Colors.black
//                                         : Colors.white,
//                                     width: 2,
//                                   ),
//                                 ),
//                                 child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(48),
//                                   child: FilterAppliedImage(
//                                     key: Key(
//                                         'filterPreviewButton:${filter.name}'),
//                                     image: imageBytes!,
//                                     filter: filter,
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               ),
//                               Text(
//                                 (filter.name),
//                                 style: const TextStyle(fontSize: 12),
//                               ),
//                             ]),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           // if (_cropimage)
//           //   Flexible(
//           //     child: Transform.rotate(
//           //       angle: rotationAngle,
//           //       child: ExtendedImage.memory(
//           //         imageBytes!,
//           //         cacheRawData: true,
//           //         fit: BoxFit.contain,
//           //         extendedImageEditorKey: _controller,
//           //         mode: ExtendedImageMode.editor,
//           //         initEditorConfigHandler: (state) {
//           //           return EditorConfig(
//           //             cropAspectRatio: currentRatio,
//           //           );
//           //         },
//           //       ),
//           //     ),
//           //   ),
//           // if (_cropimage)
//           //   // Container(
//           //   //   color: Colors.black,
//           //   //   child: ExtendedImage.memory(
//           //   //     imageBytes,
//           //   //     cacheRawData: true,
//           //   //     fit: BoxFit.contain,
//           //   //     extendedImageEditorKey: _controller,
//           //   //     mode: ExtendedImageMode.editor,
//           //   //     initEditorConfigHandler: (state) {
//           //   //       return EditorConfig(
//           //   //         cropAspectRatio: currentRatio,
//           //   //       );
//           //   //     },
//           //   //   ),
//           //   // ),
//           //   SafeArea(
//           //     child: SizedBox(
//           //       height: 80,
//           //       child: Column(
//           //         children: [
//           //           // IconButton(
//           //           //   padding: const EdgeInsets.symmetric(horizontal: 8),
//           //           //   icon: const Icon(Icons.check),
//           //           //   onPressed: () async {
//           //           //     var state = _controller.currentState;
//           //           //
//           //           //     if (state == null || state.getCropRect() == null) {
//           //           //       Navigator.pop(context);
//           //           //     }
//           //           //
//           //           //     var data = await cropImageWithThread(
//           //           //       imageBytes: state!.rawImageData,
//           //           //       rect: state.getCropRect()!,
//           //           //     );
//           //           //
//           //           //     if (mounted) Navigator.pop(context, data);
//           //           //   },
//           //           // ),
//           //           Container(
//           //             height: 80,
//           //             decoration: const BoxDecoration(
//           //               boxShadow: [
//           //                 BoxShadow(
//           //                   color: Colors.black12,
//           //                   blurRadius: 10,
//           //                 ),
//           //               ],
//           //             ),
//           //             child: SingleChildScrollView(
//           //               scrollDirection: Axis.horizontal,
//           //               child: Row(
//           //                 mainAxisAlignment: MainAxisAlignment.center,
//           //                 children: [
//           //                   // if (widget.reversible &&
//           //                   //     currentRatio != null &&
//           //                   //     currentRatio != 1)
//           //                   //   IconButton(
//           //                   //     padding: const EdgeInsets.symmetric(
//           //                   //       horizontal: 8,
//           //                   //       vertical: 4,
//           //                   //     ),
//           //                   //     icon: Icon(
//           //                   //       Icons.portrait,
//           //                   //       color: isLandscape ? Colors.grey : Colors.white,
//           //                   //     ),
//           //                   //     onPressed: () {
//           //                   //       currentRatio = 1 / currentRatio!;
//           //                   //
//           //                   //       setState(() {});
//           //                   //     },
//           //                   //   ),
//           //                   // if (widget.reversible &&
//           //                   //     currentRatio != null &&
//           //                   //     currentRatio != 1)
//           //                   //   IconButton(
//           //                   //     padding: const EdgeInsets.symmetric(
//           //                   //       horizontal: 8,
//           //                   //       vertical: 4,
//           //                   //     ),
//           //                   //     icon: Icon(
//           //                   //       Icons.landscape,
//           //                   //       color: isLandscape ? Colors.white : Colors.grey,
//           //                   //     ),
//           //                   //     onPressed: () {
//           //                   //       currentRatio = 1 / currentRatio!;
//           //                   //
//           //                   //       setState(() {});
//           //                   //     },
//           //                   //   ),
//           //                   for (var ratio in widget.availableRatios)
//           //                     TextButton(
//           //                       onPressed: () {
//           //                         currentRatio = ratio.ratio;
//           //                         setState(() {});
//           //                       },
//           //                       child: Container(
//           //                           padding: const EdgeInsets.symmetric(
//           //                               horizontal: 8, vertical: 4),
//           //                           child: Text(
//           //                             (ratio.title),
//           //                             style: TextStyle(
//           //                               color: currentRatio == ratio
//           //                                   ? Colors.white
//           //                                   : Colors.black,
//           //                             ),
//           //                           )),
//           //                     )
//           //                 ],
//           //               ),
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //     ),
//           //   ),
//         ],
//       ),
//     );
//   }
//
//   void _onBottomNavigationBarTap(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//     switch (_selectedIndex) {
//       case 0:
//         {
//           _filterOptions();
//         }
//         break;
//       case 1:
//         {
//           _cropOptions();
//         }
//         break;
//       case 2:
//         {
//           _rotateLeftOption();
//         }
//         break;
//       case 3:
//         {
//           _rotateRightOption();
//         }
//         break;
//       default:
//         {
//           if (kDebugMode) {
//             print("Options");
//           }
//         }
//         break;
//     }
//   }
//
//   void _filterOptions() {
//     setState(() {
//       _showfilterlist = !_showfilterlist;
//     });
//   }
//
//   _cropOptions() {
//     setState(() {
//       _cropimage = !_cropimage;
//     });
//   }
//
//   _rotateLeftOption() {
//     setState(() {
//       rotationAngle += math.pi / 2;
//     });
//   }
//
//   _rotateRightOption() {
//     setState(() {
//       rotationAngle -= math.pi / 2;
//     });
//   }
// }
//
// class FilterAppliedImage extends StatefulWidget {
//   final Uint8List image;
//   final ColorFilterGenerator filter;
//   final BoxFit? fit;
//   final Function(Uint8List)? onProcess;
//   final double opacity;
//
//   const FilterAppliedImage({
//     super.key,
//     required this.image,
//     required this.filter,
//     this.fit,
//     this.onProcess,
//     this.opacity = 1,
//   });
//
//   @override
//   State<FilterAppliedImage> createState() => _FilterAppliedImageState();
// }
//
// class _FilterAppliedImageState extends State<FilterAppliedImage> {
//   @override
//   initState() {
//     super.initState();
//
//     // process filter in background
//     if (widget.onProcess != null) {
//       // no filter supplied
//       if (widget.filter.filters.isEmpty) {
//         widget.onProcess!(widget.image);
//         return;
//       }
//
//       var filterTask = img.Command();
//       filterTask.decodeImage(widget.image);
//
//       var matrix = widget.filter.matrix;
//
//       filterTask.filter((image) {
//         for (final pixel in image) {
//           pixel.r = matrix[0] * pixel.r +
//               matrix[1] * pixel.g +
//               matrix[2] * pixel.b +
//               matrix[3] * pixel.a +
//               matrix[4];
//
//           pixel.g = matrix[5] * pixel.r +
//               matrix[6] * pixel.g +
//               matrix[7] * pixel.b +
//               matrix[8] * pixel.a +
//               matrix[9];
//
//           pixel.b = matrix[10] * pixel.r +
//               matrix[11] * pixel.g +
//               matrix[12] * pixel.b +
//               matrix[13] * pixel.a +
//               matrix[14];
//
//           pixel.a = matrix[15] * pixel.r +
//               matrix[16] * pixel.g +
//               matrix[17] * pixel.b +
//               matrix[18] * pixel.a +
//               matrix[19];
//         }
//
//         return image;
//       });
//
//       filterTask.getBytesThread().then((result) {
//         if (widget.onProcess != null && result != null) {
//           widget.onProcess!(result);
//         }
//       }).catchError((err, stack) {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.filter.filters.isEmpty) {
//       return Image.memory(
//         widget.image,
//         fit: widget.fit,
//       );
//     }
//
//     return Opacity(
//       opacity: widget.opacity,
//       child: widget.filter.build(
//         Image.memory(
//           widget.image,
//           fit: widget.fit,
//         ),
//       ),
//     );
//   }
// }
//
// // Future<Uint8List?> cropImageWithThread({
// //   required Uint8List imageBytes,
// //   required Rect rect,
// // }) async {
// //   img.Command cropTask = img.Command();
// //   cropTask.decodeImage(imageBytes);
// //
// //   cropTask.copyCrop(
// //     x: rect.topLeft.dx.ceil(),
// //     y: rect.topLeft.dy.ceil(),
// //     height: rect.height.ceil(),
// //     width: rect.width.ceil(),
// //   );
// //
// //   img.Command encodeTask = img.Command();
// //   encodeTask.subCommand = cropTask;
// //   encodeTask.encodeJpg();
// //
// //   return encodeTask.getBytesThread();
// // }

//  void _takeScreenShort () async {
//   RepaintBoundary boundary = _repaintBoundary.currentContext!.findRenderObject() as RepaintBoundary;
//   ui.Image image = await boundary.toImage(pixelRatio : 3.0);
//   ByteData? bytes =  await image.toByteData(format:ui.ImageByteFormat.png);
//   setState(() {
//     imageBytes=bytes!.buffer.asUint8List();
//   });
// }

// _takescrshot() async {
//   RenderRepaintBoundary boundary = _repaintBoundary.currentContext.findRenderObject(); // the key provided
//   var image = await boundary.toImage();
//   var byteData = await image.toByteData(format: ImageByteFormat.png);
//   var pngBytes = byteData.buffer.asUint8List();
//   print(pngBytes);
// }
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:colorfilter_generator/colorfilter_generator.dart';
import 'package:colorfilter_generator/presets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
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
  GlobalKey _repaintBoundary = GlobalKey();
  bool _showfilterlist = false;
  bool _cropimage = false;
  ColorFilterGenerator selectedFilter = PresetFilters.none;
  double rotationAngle = 0;
  late List<ColorFilterGenerator> filters;
  String? userEnteredText;
  Offset textPosition = Offset(50, 50); // Default position for the text
  TextEditingController _textEditingController = TextEditingController();

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
      RenderRepaintBoundary boundary =
      _repaintBoundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/shared_image.png').create();
      await file.writeAsBytes(pngBytes);

      final result = await Share.shareXFiles([XFile(file.path)], text: 'Great picture 😊');
      if (result.status == ShareResultStatus.success) {
        if (kDebugMode) {
          print('Thank you for sharing the picture!');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _captureAndSaveImage() async {
    try {
      RenderRepaintBoundary boundary =
      _repaintBoundary.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final params = SaveFileDialogParams(
        data: pngBytes,
        fileName: "pixel_image_editor_${DateTime.now()}.png",
      );
      final filePath = await FlutterFileDialog.saveFile(params: params);

      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image saved to $filePath')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save image')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.edit, color: Colors.black), label: 'Filter'),
          BottomNavigationBarItem(icon: Icon(Icons.crop, color: Colors.black), label: 'Crop'),
          BottomNavigationBarItem(icon: Icon(Icons.rotate_left, color: Colors.black), label: 'Rotate Left'),
          BottomNavigationBarItem(icon: Icon(Icons.rotate_right, color: Colors.black), label: 'Rotate Right'),
          BottomNavigationBarItem(icon: Icon(Icons.text_fields, color: Colors.black), label: 'Text'),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        onTap: _onBottomNavigationBarTap,
      ),
      appBar: AppBar(
        elevation: 0,
        title: const Text("Edit Image"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _captureAndSaveImage,
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
      body: GestureDetector(
        onTap: () {
          // Hide filter and crop options when tapping outside
          setState(() {
            _showfilterlist = false;
            _cropimage = false;
          });
        },
        child: Column(
          children: [
            if (imageBytes != null)
              Flexible(
                child: RepaintBoundary(
                  key: _repaintBoundary,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Transform.rotate(
                      angle: rotationAngle,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix(selectedFilter.matrix),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
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
                                      return EditorConfig(cropAspectRatio: currentRatio);
                                    },
                                  ),
                                )
                                    : Image.memory(
                                  imageBytes!,
                                  fit: BoxFit.contain,
                                ),
                                if (userEnteredText != null)
                                  Positioned(
                                    left: textPosition.dx,
                                    top: textPosition.dy,
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        setState(() {
                                          textPosition += details.delta;
                                        });
                                      },
                                      child: Text(
                                        userEnteredText!,
                                        style: TextStyle(
                                          fontSize: 30,
                                          color: Colors.white,
                                          backgroundColor: Colors.black.withOpacity(0.5),
                                        ),
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
                                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(48),
                                      border: Border.all(
                                        color: selectedFilter == filter ? Colors.black : Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(48),
                                      child: FilterAppliedImage(
                                        key: Key('filterPreviewButton:${filter.name}'),
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
    });
  }

  void _cropOptions() {
    setState(() {
      _showfilterlist = false;
      _cropimage = !_cropimage;
    });
  }

  void _rotateLeftOption() {
    setState(() {
      _showfilterlist = false;
      _cropimage = false;
      rotationAngle -= math.pi / 2;
    });
  }

  void _rotateRightOption() {
    setState(() {
      _showfilterlist = false;
      _cropimage = false;
      rotationAngle += math.pi / 2;
    });
  }

  void _addText() {
    setState(() {
      _showfilterlist = false;
      _cropimage = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Text"),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(hintText: "Enter text"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userEnteredText = _textEditingController.text;
                });
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
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

    // process filter in background
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