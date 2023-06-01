library activity_graph;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GitLabActivityWidget extends StatefulWidget {
  final String username;
  final String token;

  final double? size;
  final Color color;

  final bool bol;

  final String? gitlabHost;

  const GitLabActivityWidget({
    required this.username,
    required this.token,
    this.gitlabHost,
    this.size,
    this.color = Colors.blue,
    this.bol = false,
  });

  @override
  _GitLabActivityWidgetState createState() => _GitLabActivityWidgetState();
}

class _GitLabActivityWidgetState extends State<GitLabActivityWidget> {
  Map<DateTime, int> activityDates = {};

  @override
  void initState() {
    super.initState();
    fetchActivityGitLab();
  }

  Future<void> fetchActivityGitLab() async {
    activityDates = {};
    bool wasEmpty = false;
    int page = 0;
    do {
      String url =
          'https://${widget.gitlabHost ?? 'gitlab.com'}/api/v4/users/${widget.username}/events?per_page=100&page=${page++}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List responseData = json.decode(response.body);

        wasEmpty = responseData.isEmpty;
        responseData.forEach((e) {
          DateTime date = DateTime.parse(e['created_at'].toString().substring(0, 10)).copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          );

          if (widget.bol) {
            date = date.subtract(Duration(
                days: Random(date.millisecondsSinceEpoch).nextInt(30)));
          }

          int v = e['push_data']?['commit_count'] ?? 0;
          activityDates[date] = (activityDates[date] ?? 0) + v;
        });
      }
    } while (!wasEmpty);
    print(activityDates);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return HeatMap(
          scrollable: true,
          colorMode: ColorMode.opacity,
          size: widget.size ??
              (Device.orientation == Orientation.landscape ? 1.3.w : 1.h),
          borderRadius: 3,
          fontSize: 0,
          colorsets: {0: widget.color},
          defaultColor: Colors.transparent,
          datasets: activityDates,
          showColorTip: false,
        );
      },
    );
  }
}

class HeatMapExample extends StatefulWidget {
  const HeatMapExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HeatMapExample();
}

class _HeatMapExample extends State<HeatMapExample> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController heatLevelController = TextEditingController();

  bool isOpacityMode = true;

  Map<DateTime, int> heatMapDatasets = {
    DateTime.now().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    ): 10,
    DateTime.now().subtract(const Duration(days: 1)).copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        ): 5,
    DateTime.now().subtract(const Duration(days: 2)).copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        ): 15,
  };

  @override
  void dispose() {
    super.dispose();
    dateController.dispose();
    heatLevelController.dispose();
  }

  Widget _textField(final String hint, final TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 20, top: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffe7e7e7), width: 1.0)),
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF20bca4), width: 1.0)),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          isDense: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Heatmap'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Card(
              margin: const EdgeInsets.all(20),
              elevation: 20,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: HeatMap(
                  scrollable: true,
                  colorMode:
                      isOpacityMode ? ColorMode.opacity : ColorMode.color,
                  datasets: heatMapDatasets,
                  colorsets: const {
                    1: Colors.red,
                    3: Colors.orange,
                    5: Colors.yellow,
                    7: Colors.green,
                    9: Colors.blue,
                    11: Colors.indigo,
                    13: Colors.purple,
                  },
                  onClick: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(value.toString())));
                  },
                ),
              ),
            ),
            _textField('YYYYMMDD', dateController),
            _textField('Heat Level', heatLevelController),
            ElevatedButton(
              child: const Text('COMMIT'),
              onPressed: () {
                setState(() {
                  final DateTime date = DateTime.parse(dateController.text);
                  heatMapDatasets[date] = int.parse(heatLevelController.text);
                });
              },
            ),

            // ColorMode/OpacityMode Switch.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text('Color Mode'),
                CupertinoSwitch(
                  value: isOpacityMode,
                  onChanged: (value) {
                    setState(() {
                      isOpacityMode = value;
                    });
                  },
                ),
                const Text('Opacity Mode'),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
