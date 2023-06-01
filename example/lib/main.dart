import 'dart:ui';

import 'package:activity_graph/GitHubActivityGraph.dart';
import 'package:activity_graph/GitlabActivityGraph.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

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
          decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1604351031298-fe2920584c66?ixid=MnwxMTI1OHwwfDF8cmFuZG9tfHx8fHx8fHx8MTY4Mjc2NjAyNA&ixlib=rb-4.0.3&q=85&w=1920',
                ),
                fit: BoxFit.cover,
              )),
          child:
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Center(
                child: Stack(
                  children: [
                    GithubActivityWidget(
                      // gitHubConfig: GitHubConfig(
                      //   username: 'rsanjuan87',
                      //   token: githubKey,
                      // ),
                      gitlabConfig: [
                        GitLabConfig(
                          username: 'rsanjuan87',
                          token: gitlabKey_top,
                          host: 'git.topgroupexpress.com',
                        ),
                        GitLabConfig(
                          username: 'rsanjuan87',
                          token: gitlabKey,
                        ),
                      ],
                      color: Colors.deepOrange.shade900,
                      mode: ColorMode.lightOpacity,
                      defaultColor: Colors.white.withAlpha(10),
                    ),
                    GithubActivityWidget(
                      gitHubConfig: GitHubConfig(
                        username: 'rsanjuan87',
                        token: githubKey,
                      ),
                      // gitlabConfig: GitLabConfig(
                      //   username: 'rsanjuan87',
                      //   token: gitlabKey_top,
                      //   host: 'git.topgroupexpress.com',
                      // ),
                      color: Colors.green.shade900,
                      mode: ColorMode.light,
                      defaultColor: Colors.white.withAlpha(10),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
