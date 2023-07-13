import 'package:flutter/material.dart';
import '../../../ActivityGraph.dart';
import './date_util.dart';

class DatasetsUtil {
  /// Filtering [datasets] where the key is on the same month of [referenceDate].
  static Map<DateTime, Map<GitHubConfig, int>>?  filterMonth(
      final Map<DateTime, Map<GitHubConfig, int>>? datasets,
      DateTime referenceDate) {
    return Map.from(datasets ?? {})
      ..removeWhere(
        (date, value) =>
            !(date.isAfter(DateUtil.startDayOfMonth(referenceDate)) &&
                    date.isBefore(DateUtil.endDayOfMonth(referenceDate)) ||
                date == DateUtil.endDayOfMonth(referenceDate) ||
                date == DateUtil.startDayOfMonth(referenceDate)),
      );
  }

  /// Get maximum value of [datasets].
  static int getMaxValue(Map<DateTime, Map<GitHubConfig, int>>? datasets) {
    int result = 0;

    datasets?.forEach((date, map) {
      int value = 0;
      map.forEach((key, v) {
        value += v;
        if (value > result) {
          result = value;
        }
      });
    });

    return result;
  }

  /// Get color from [colorsets] using [dataValue].
  static Color? getColor(Map<int, Color>? colorsets, int? dataValue) {
    int result = 0;

    colorsets?.forEach((key, value) {
      if (key <= (dataValue ?? 0)) result = key;
    });

    return colorsets?[result];
  }
}
