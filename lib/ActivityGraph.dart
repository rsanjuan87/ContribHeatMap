library activity_graph;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
// import 'package:responsive_sizer/responsive_sizer.dart';

import 'flutter_heatmap/data/heatmap_color_mode.dart';
import 'flutter_heatmap/heatmap.dart';

class GitHubConfig {
  final String username;
  final String token;

  GitHubConfig({
    required this.username,
    required this.token,
  });
}

class GitLabConfig extends GitHubConfig {
  // final String username;
  // final String token;
  final String? host;

  GitLabConfig({
    required super.username,
    required super.token,
    this.host,
  });
}

class ActivityWidget extends StatefulWidget {
  // final GitHubConfig? gitHubConfig;
  final config;

  final double? size;
  final Color color;
  final bool bol;

  final ColorMode mode;
  final Color defaultColor;

  ActivityWidget({
    // this.gitHubConfig,
    this.config,
    this.color = Colors.blue,
    this.size,
    this.bol = false,
    this.mode = ColorMode.opacity,
    this.defaultColor = Colors.white10,
  }) {
    if (config != null &&
        config! is GitHubConfig &&
        config! is List<GitHubConfig>) {
      throw Exception(
          'config must be of type GitLabConfig, GitLabConfig or List<GitHubConfig or GitLabConfig>\n'
          '"$config"');
    }
    ;
  }

  @override
  _ActivityWidgetState createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  Map<DateTime, int> activityDates = {};

  @override
  void initState() {
    super.initState();
    // if (widget.gitHubConfig != null) {
    //   fetchGitHub();
    // }
    if (widget.config != null) {
      fetchActivityGitLab();
    }
  }

  Future<void> fetchActivityGitLab() async {
    activityDates = {};
    if (widget.config is GitLabConfig) {
      fetchActivity(widget.config);
    } else if (widget.config is GitHubConfig) {
      fetchGitHub(widget.config);
    } else if (widget.config is List) {
      for (var element in widget.config) {
        if (element is GitLabConfig) {
          fetchActivity(element);
        } else if (element is GitHubConfig) {
          fetchGitHub(element);
        }
      }
    }
    setState(() {});
  }

  Future<void> fetchGitHub(config) async {
    String query = '''
       query {
         user(login: "${config?.username}") {
           contributionsCollection {
             contributionCalendar {
               totalContributions
               weeks {
                 contributionDays {
                   date
                   contributionCount
                 }
               }
             }
           }
         }
       }
     ''';

    final response = await http.post(
      Uri.parse('https://api.github.com/graphql'),
      headers: {
        'Authorization': 'Bearer ${config?.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);

      List weeks = responseData['data']['user']['contributionsCollection']
          ['contributionCalendar']['weeks'];
      weeks.forEach((element) {
        List days = element['contributionDays'];
        days.forEach((day) {
          DateTime date = DateTime.parse(day['date']);

          if (widget.bol) {
            date = date.subtract(Duration(
                days: Random(date.millisecondsSinceEpoch).nextInt(30)));
          }

          activityDates[date] =
              (activityDates[date] ?? 0) + (day['contributionCount'] as int);
        });
      });

      // print(activityDates);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // return ResponsiveSizer(
    //   builder: (context, orientation, screenType) {
    Size size = MediaQuery.of(context).size;
    return HeatMap(
      scrollable: false,
      colorMode: widget.mode,
      size: widget.size ?? size.width * .0155,
      borderRadius: 3,
      colorsets: {0: widget.color},
      defaultColor: widget.defaultColor,
      datasets: activityDates,
      showColorLegend: false,
      showText: false,
      fontSize: 0,
      onClick: (date, count) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('${date.toString().substring(0, 10)} $count')));
      },
      tooltipGenerator: (v, d) {
        if (v == 0) {
          return null;
        }
        return 'Contributions: ${v.toString()}\n'
            'Date : ${d.toString().substring(0, 10)}';
      },
    );
    // },
    // );
  }

  Future<void> fetchActivity(GitLabConfig gitlabConfig) async {
    bool wasEmpty = false;
    int page = 0;
    do {
      String url = 'https://${gitlabConfig.host ?? 'gitlab.com'}/api/v4/users/'
          '${gitlabConfig.username}/events?per_page=100&page=${page++}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${gitlabConfig.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List responseData = json.decode(response.body);

        wasEmpty = responseData.isEmpty;
        responseData.forEach((e) {
          DateTime date =
              DateTime.parse(e['created_at'].toString().substring(0, 10))
                  .copyWith(
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

          // int v = e['push_data']?['commit_count'] ?? 0;
          if (e['action_name'] == 'pushed new' ||
              e['action_name'] == 'pushed to') {
            // v = v;
            activityDates[date] = (activityDates[date] ?? 0) + 1; //v;
          } else {
            // v = 0;
          }
        });
        setState(() {});
      }
    } while (!wasEmpty);
  }
}
