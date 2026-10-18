import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class WatchPlayTalkApp extends StatefulWidget {
  const WatchPlayTalkApp({super.key});

  @override
  State<WatchPlayTalkApp> createState() => _WatchPlayTalkAppState();
}

class _WatchPlayTalkAppState extends State<WatchPlayTalkApp> {
  late final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Watch Play Talk',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: _router,
    );
  }
}
