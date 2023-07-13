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
      child: Wrap(
        children: map.keys
            .map((e) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOutQuad,
                  width: (size ?? 0) / (map.isEmpty ? 1 : map.length),
                  height: (size ?? 0) / (map.isEmpty ? 1 : map.length),
                  alignment: Alignment.center,
                  child: (showText ?? true)
                      ? Text(
                          date.day.toString(),
                          style: TextStyle(
                              color: textColor ?? const Color(0xFF8A8A8A),
                              fontSize: fontSize),
                        )
                      : null,
                  decoration: BoxDecoration(
                    color: e.color,
                    borderRadius:
                        BorderRadius.all(Radius.circular(borderRadius ?? 5)),
                  ),
                ))
            .toList(),
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
