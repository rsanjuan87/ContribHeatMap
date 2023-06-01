library activity_graph;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class GitHubConfig {
  final String username;
  final String token;

  GitHubConfig({
    required this.username,
    required this.token,
  });
}

class GitLabConfig {
  final String username;
  final String token;
  final String? host;

  GitLabConfig({
    required this.username,
    required this.token,
    this.host,
  });
}

class GithubActivityWidget extends StatefulWidget {
  final GitHubConfig? gitHubConfig;
  final gitlabConfig;

  final double? size;
  final Color color;
  final bool bol;

  final ColorMode mode;
  final Color defaultColor;

  GithubActivityWidget({
    this.gitHubConfig,
    this.gitlabConfig,
    this.color = Colors.blue,
    this.size,
    this.bol = false,
    this.mode = ColorMode.opacity,
    this.defaultColor = Colors.white10,
  }) {
    if (gitlabConfig != null &&
        gitlabConfig! is GitLabConfig &&
        gitlabConfig! is List<GitLabConfig>) {
      throw Exception(
          'gitlabConfig must be of type GitLabConfig or List<GitLabConfig>');
    }
    ;
  }

  @override
  _GithubActivityWidgetState createState() => _GithubActivityWidgetState();
}

class _GithubActivityWidgetState extends State<GithubActivityWidget> {
  Map<DateTime, int> activityDates = {};

  @override
  void initState() {
    super.initState();
    if (widget.gitHubConfig != null) {
      fetchGitHub();
    }
    if (widget.gitlabConfig != null) {
      fetchActivityGitLab();
    }
  }

  Future<void> fetchActivityGitLab() async {
    activityDates = {};
    if (widget.gitlabConfig is GitLabConfig) {
      fetchActivity(widget.gitlabConfig);
    } else if (widget.gitlabConfig is List<GitLabConfig>) {
      widget.gitlabConfig.forEach((element) => fetchActivity(element));
    }
    setState(() {});
  }

  Future<void> fetchGitHub() async {
    String query = '''
       query {
         user(login: "${widget.gitHubConfig?.username}") {
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
        'Authorization': 'Bearer ${widget.gitHubConfig?.token}',
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

          activityDates[date] = (activityDates[date] ?? 0) + (day['contributionCount'] as int);

        });
      });

      // print(activityDates);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return HeatMap(
          scrollable: true,
          colorMode: widget.mode,
          size: widget.size ??
              (Device.orientation == Orientation.landscape ? 1.3.w : 1.h),
          borderRadius: 3,
          fontSize: 0,
          colorsets: {0: widget.color},
          defaultColor: widget.defaultColor,
          datasets: activityDates,
          showColorTip: false,
          showText: false,
        );
      },
    );
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

          int v = e['push_data']?['commit_count'] ?? 0;
          activityDates[date] = (activityDates[date] ?? 0) + v;
        });
        setState(() {});
      }
    } while (!wasEmpty);
  }
}
