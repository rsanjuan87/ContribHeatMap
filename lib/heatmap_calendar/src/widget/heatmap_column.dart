import 'package:flutter/material.dart';

import '../../../ActivityGraph.dart';
import './heatmap_container.dart';
import '../data/heatmap_color_mode.dart';
import '../util/datasets_util.dart';
import '../util/date_util.dart';

class HeatMapColumn extends StatelessWidget {
  /// The List widgets of [HeatMapContainer].
  ///
  /// It includes every days of the week and
  /// if one week doesn't have 7 days, it will be filled with empty [Container].
  final List<Widget> dayContainers;

  /// The List widgets of empty [Container].
  ///
  /// It only processes when given week's length is not 7.
  final List<Widget> emptySpace;

  /// The date value of first day of given week.
  final DateTime startDate;

  /// The date value of last day of given week.
  final DateTime endDate;

  /// The double value of every [HeatMapContainer]'s width and height.
  final double? size;

  /// The double value of every [HeatMapContainer]'s fontSize.
  final double? fontSize;

  /// The default background color value of [HeatMapContainer].
  final Color? defaultColor;

  /// The datasets which fill blocks based on its value.
  ///
  /// datasets keys have to greater or equal to [startDate] and
  /// smaller or equal to [endDate].
  final Map<DateTime, Map<GitHubConfig, int>>? datasets;

  /// The text color value of [HeatMapContainer].
  final Color? textColor;

  /// The colorsets which give the color value for its thresholds key value.
  ///
  /// Be aware that first Color is the maximum value if [ColorMode] is [ColorMode.opacity].
  final Map<int, Color>? colorsets;

  /// ColorMode changes the color mode of blocks.
  ///
  /// [ColorMode.opacity] requires just one colorsets value and changes color
  /// dynamically based on hightest value of [datasets].
  /// [ColorMode.color] changes colors based on [colorsets] thresholdsc key value.
  final ColorMode colorMode;

  /// The double value of [HeatMapContainer]'s borderRadius.
  final double? borderRadius;

  /// The margin value for every block.
  final EdgeInsets? margin;

  /// Function that will be called when a block is clicked.
  ///
  /// Paratmeter gives clicked [DateTime] value.
  final Function(DateTime, int)? onClick;

  /// The integer value of the maximum value for the highest value of the month.
  final int? maxValue;

  /// Show day text in every blocks if the value is true.
  final bool? showText;

  // The number of day blocks to draw. This should be seven for all but the
  // current week.
  final int numDays;

  /// Function that will be called to generate tooltip.
  String? Function(int, DateTime)? tooltipGenerator;

  final int configsCount;

  HeatMapColumn({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.colorMode,
    required this.configsCount,
    required this.numDays,
    this.size,
    this.fontSize,
    this.defaultColor,
    this.datasets,
    this.textColor,
    this.borderRadius,
    this.margin,
    this.colorsets,
    this.onClick,
    this.maxValue,
    this.showText,
    this.tooltipGenerator,
  })  :
        // Init list.
        dayContainers = List.generate(
          numDays,
          (i) {
            Map<GitHubConfig, int>? map = datasets?[DateTime(startDate.year,
                startDate.month, startDate.day + i - (startDate.weekday % 7))];

            int count = 0;
            map?.forEach((config, c) {
              count += c;
            });

            // int count = (datasets?[DateTime(startDate.year, startDate.month,
            //         startDate.day + i - (startDate.weekday % 7))] ??
            //     0);

            var w = HeatMapContainer(
              configsCount: configsCount,
              colorMode: colorMode,
              maxValue: maxValue,
              map: map??{},
              date: DateUtil.changeDay(startDate, i),
              backgroundColor: defaultColor,
              size: size,
              fontSize: fontSize,
              textColor: textColor,
              borderRadius: borderRadius,
              margin: margin,
              onClick: onClick == null
                  ? null
                  : (d) {
                      onClick.call(d, count);
                    },
              showText: showText,
              // If datasets has DateTime key which is equal to this HeatMapContainer's date,
              // we have to color the matched HeatMapContainer.
              //
              // If datasets is null or doesn't contains the equal DateTime value, send null.
              selectedColor:
                  // datasets?.keys.contains(DateTime(
                  //             startDate.year,
                  //             startDate.month,
                  //             startDate.day - startDate.weekday % 7 + i)) ??
                  //         false
                  count != 0
                      // If colorMode is ColorMode.opacity,
                      ? getColor(
                          colorMode,
                          colorsets,
                          maxValue,
                          defaultColor,
                          count
                        )
                      : null,
            );
            String? tooltipText =
                tooltipGenerator?.call(count, startDate.add(Duration(days: i)));
            return (tooltipText == null)
                ? w
                : Tooltip(
                    message: tooltipText,
                    child: w,
                  );
          },
        ),
        // Fill emptySpace list only if given wek doesn't have 7 days.
        emptySpace = (numDays != 7)
            ? List.generate(
                7 - numDays,
                (i) => Container(
                    margin: margin ?? const EdgeInsets.all(2),
                    width: size ?? 42,
                    height: size ?? 42),
              )
            : [],
        super(key: key);

  static getColor(ColorMode colorMode, Map<int, Color>? colorsets,
      int? maxValue, defaultColor, int value) {
    Color? color;
    var cMode = colorMode;
    if ((colorsets?.keys.length ?? 0) == 1 && colorMode == ColorMode.color) {
      cMode = ColorMode.light;
    }

    double v = /*(datasets?[DateTime(startDate.year, startDate.month,
                        startDate.day + i - (startDate.weekday % 7))]
                    as Map<GitHubConfig, int>? ??
                {})
            .total*/
    value /
        (maxValue ?? 1);
    switch (cMode) {
      case ColorMode.lightOpacity:
      case ColorMode.light:
        color = colorsets?.values.first;
        var vv = 1 - (v);
        color = vv == 1 ? null : color?.lighten(vv.clamp(0, 1) / 2.0);
        break;
      case ColorMode.opacity:
        color = colorsets?.values.first.withOpacity(v);
        break;
      case ColorMode.color:
        color = colorsets?.values.first;
        break;
    }

    if (colorMode == ColorMode.lightOpacity && v != 1) {
      color = color?.withOpacity((.5 + v).clamp(0, 1));
    }

    return color;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[...dayContainers, ...emptySpace],
    );
  }
}

extension ColorExt on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  MaterialStateProperty<Color> get material =>
      MaterialStateProperty.all<Color>(this);
}

extension ext1 on Map<GitHubConfig, int> {
  int get total {
    return values.reduce((a, b) => a + b);
  }
}
