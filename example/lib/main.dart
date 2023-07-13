import 'dart:ui';

import 'package:activity_graph/ActivityGraph.dart';
import 'package:activity_graph/flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:flutter/material.dart';

import 'env.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Activity Graph Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Graph Demo'),
      ),
      // backgroundColor: Colors.blueGrey,
      body: Container(
        // decoration: const BoxDecoration(
        //     image: DecorationImage(
        //       image: NetworkImage(
        //         'https://images.unsplash.com/photo-1604351031298-fe2920584c66?ixid=MnwxMTI1OHwwfDF8cmFuZG9tfHx8fHx8fHx8MTY4Mjc2NjAyNA&ixlib=rb-4.0.3&q=85&w=1920',
        //       ),
        //       fit: BoxFit.cover,
        //     )),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                //https://git.topgroups.travel/users/rsanjuan87/calendar_activities?date=2023-3-23
                //https://github.com/rsanjuan87?from=2022-08-17&to=2022-08-17&tab=overview
                ActivityWidget(
                  config: GitHubConfig(
                    username: 'rsanjuan87',
                    token: githubKey,
                    color: Colors.green.shade900,
                  ),
                  color: Colors.green.shade900,
                  mode: ColorMode.lightOpacity,
                  defaultColor: Colors.white.withAlpha(10),
                ),
                ActivityWidget(
                  config: GitLabConfig(
                    username: 'rsanjuan87',
                    token: gitlabKey_top,
                    host: 'git.topgroups.travel',
                    color: Colors.orange.shade900,
                  ),
                  color: Colors.orange.shade900,
                  mode: ColorMode.lightOpacity,
                  defaultColor: Colors.white.withAlpha(10),
                ),
              ],
            ),
            ActivityWidget(
              config: [
                GitHubConfig(
                  username: 'rsanjuan87',
                  token: githubKey,
                  color: Colors.blue.shade900,
                ),
                GitLabConfig(
                  username: 'rsanjuan87',
                  token: gitlabKey_top,
                  host: 'git.topgroups.travel',
                  color: Colors.blue.shade900,
                )
              ],
              color: Colors.blue.shade900,
              mode: ColorMode.lightOpacity,
              defaultColor: Colors.white.withAlpha(10),
            ),
            ActivityWidget(
              config: GitHubConfig(
                username: 'rsanjuan87',
                token: githubKey,
                color: Colors.green.shade900,
              ),
              color: Colors.green.shade900,
              mode: ColorMode.lightOpacity,
              defaultColor: Colors.white.withAlpha(10),
            ),
            ActivityWidget(
              config: GitLabConfig(
                username: 'rsanjuan87',
                token: gitlabKey_top,
                host: 'git.topgroups.travel',
                color: Colors.orange.shade900,
              ),
              color: Colors.orange.shade900,
              mode: ColorMode.lightOpacity,
              defaultColor: Colors.white.withAlpha(10),
            ),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
