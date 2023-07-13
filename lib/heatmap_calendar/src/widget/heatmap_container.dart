import 'dart:math';

import 'dart:math';

import 'package:activity_graph/heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:activity_graph/heatmap_calendar/src/widget/heatmap_column.dart';
import 'package:flutter/material.dart';

import '../../../ActivityGraph.dart';
import '../data/heatmap_color.dart';

class HeatMapContainer extends StatelessWidget {
  final DateTime date;
  final double? size;
  final double? fontSize;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final EdgeInsets? margin;
  final bool? showText;
  final Function(DateTime dateTime)? onClick;
  final Map<GitHubConfig, int> map;
  final int? maxValue;
  final ColorMode colorMode;
  final int configsCount;

  const HeatMapContainer({
    Key? key,
    required this.date,
    this.margin,
    this.size,
    this.fontSize,
    this.borderRadius,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.onClick,
    this.showText,
    required this.map,
    required this.maxValue,
    required this.colorMode,
    this.configsCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var w = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? HeatMapColor.defaultColor,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 5)),
      ),
      child: Stack(
        children: [
          ...map.keys
              .map(
                (e) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  width: (size ?? 0),
                  // / max(sqrt(configsCount).round() as double, 2) ,//(map.isEmpty ? 1 : map.length),
                  height: (size ?? 0),
                  // / max(sqrt(configsCount).round() as double, 2) , //(map.isEmpty ? 1 : map.length),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: map[e] != 0
                        // If colorMode is ColorMode.opacity,
                        ? HeatMapColumn.getColor(
                      colorMode,
                            {0: e.color ?? Colors.green.shade700},
                            maxValue,
                            backgroundColor,
                            map[e] ?? 0,
                          )
                        : null,
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius ?? 5)),
                  ),
                ),
              )
              .toList()
              .reversed
              .toList(),
          if (showText ?? true)
            Center(
              child: Text(
                date.day.toString(),
                style: TextStyle(
                    color: textColor ?? const Color(0xFF8A8A8A),
                    fontSize: fontSize),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
    return Padding(
      padding: margin ?? const EdgeInsets.all(2),
      child: selectedColor == null
          ? IgnorePointer(
              child: w,
            )
          : GestureDetector(
              child: w,
              onTap: onClick == null
                  ? null
                  : () {
                      onClick?.call(date);
                    },
            ),
    );
  }
}
