import 'package:colorfilter_generator/colorfilter_generator.dart';


enum OutputFormat {
  /// merge all layers and return jpeg encoded bytes
  jpeg,

  /// convert all layers into json and return the list
  json,

  /// merge all layers and return png encoded bytes
  png
}

class AspectRatio {
  final String title;
  final double? ratio;

  const AspectRatio({required this.title, this.ratio});
}

class CropOption {
  final bool reversible;

  /// List of availble ratios
  final List<AspectRatio> ratios;

  const CropOption({
    this.reversible = true,
    this.ratios = const [
      AspectRatio(title: 'Freeform'),
      AspectRatio(title: '1:1', ratio: 1),
      AspectRatio(title: '4:3', ratio: 4 / 3),
      AspectRatio(title: '5:4', ratio: 5 / 4),
      AspectRatio(title: '7:5', ratio: 7 / 5),
      AspectRatio(title: '16:9', ratio: 16 / 9),
    ],
  });
}


class FiltersOption {
  final List<ColorFilterGenerator>? filters;
  const FiltersOption({this.filters});
}
