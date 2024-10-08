import 'package:flutter/material.dart';

class BlurOption {
  const BlurOption();
}

class BrushOption {
  /// show background image on draw screen

  final List<BrushColor> colors;

  const BrushOption({

    this.colors = const [
      BrushColor(color: Colors.black, background: Colors.white),
      BrushColor(color: Colors.blue),
      BrushColor(color: Colors.green),
      BrushColor(color: Colors.pink),
      BrushColor(color: Colors.purple),
      BrushColor(color: Colors.brown),
      BrushColor(color: Colors.indigo),
      BrushColor(color: Colors.deepOrange),
      BrushColor(color: Colors.red),
      BrushColor(color: Colors.deepPurple),
    ],
  });
}



class BrushColor {
  /// Color of brush
  final Color color;

  /// Background color while brush is active only be used when showBackground is false
  final Color background;

  const BrushColor({
    required this.color,
    this.background = Colors.black,
  });
}
