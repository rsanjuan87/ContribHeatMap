library activity_graph;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'heatmap_calendar/src/data/heatmap_color_mode.dart';
import 'heatmap_calendar/src/heatmap.dart';


class GitHubConfig {
  final String username;
  final String token;
  final Color? color;

  GitHubConfig({
    required this.username,
    required this.token,
    required this.color,
  });
}

class GitLabConfig extends GitHubConfig {
  // final String username;
  // final String token;
  final String? host;

  GitLabConfig({
    required super.username,
    required super.token,
    required super.color,
    this.host,
  });
}

class ActivityWidget extends StatefulWidget {
  // final GitHubConfig? gitHubConfig;
  final config;

  final double? size;

  @deprecated
  final bool randomize;

  final ColorMode mode;
  final Color defaultColor;

  ActivityWidget({
    // this.gitHubConfig,
    this.config,
    this.size,
    this.randomize = false,
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
  Map<DateTime, Map<GitHubConfig, int>> activityDates = {};

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
      for (var element in weeks) {
        List days = element['contributionDays'];
        for (var day in days) {
          DateTime date = DateTime.parse(day['date']);

          if (widget.randomize) {
            date = date.subtract(Duration(
                days: Random(date.millisecondsSinceEpoch).nextInt(30)));
          }

          Map<GitHubConfig, int> map = activityDates[date] ?? {};
          int c = map[config] ?? 0;

          map[config] = c + (day['contributionCount'] as int);
          activityDates[date] = map;

          // activityDates[date][config] = (activityDates[date][config] ?? 0) +
          //     (day['contributionCount'] as int);
        }
      }

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
      size: widget.size ?? size.width * .013,
      borderRadius: 3,
      colorsets: {0: Colors.green.shade900},
      defaultColor: widget.defaultColor,
      configsCount: widget.config is List ? widget.config.length : 1,
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

  Future<void> fetchActivity(GitLabConfig config) async {
    bool wasEmpty = false;
    int page = 0;
    do {
      String url = 'https://${config.host ?? 'gitlab.com'}/api/v4/users/'
          '${config.username}/events?per_page=100&page=${page++}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer ${config.token}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List responseData = json.decode(response.body);

        wasEmpty = responseData.isEmpty;
        for (var e in responseData) {
          DateTime date =
              DateTime.parse(e['created_at'].toString().substring(0, 10))
                  .copyWith(
            hour: 0,
            minute: 0,
            second: 0,
            millisecond: 0,
            microsecond: 0,
          );

          if (widget.randomize) {
            date = date.subtract(Duration(
                days: Random(date.millisecondsSinceEpoch).nextInt(30)));
          }

          // int v = e['push_data']?['commit_count'] ?? 0;
          if (e['action_name'] == 'pushed new' ||
              e['action_name'] == 'pushed to') {
            // v = v;

            Map<GitHubConfig, int> map = activityDates[date] ?? {};
            int c = map[config] ?? 0;

            map[config] = c + 1;
            activityDates[date] = map;

          }
        }
        setState(() {});
      }
    } while (!wasEmpty);
  }
}
