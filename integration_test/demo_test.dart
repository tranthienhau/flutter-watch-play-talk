import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:watch_play_talk/app.dart';

/// Short guided walkthrough used while screen-recording the demo GIFs.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFor(WidgetTester t, int ms) async {
    for (var i = 0; i < ms ~/ 50; i++) {
      await t.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> tap(WidgetTester t, String key, {int ms = 1100}) async {
    await t.tap(find.byKey(Key(key)).first);
    await pumpFor(t, ms);
  }

  testWidgets('demo', (t) async {
    await t.pumpWidget(const ProviderScope(child: WatchPlayTalkApp()));
    await pumpFor(t, 1800);
    await tap(t, 'sign-in-apple', ms: 1500);
    await tap(t, 'start-trial');
    await tap(t, 'key-4', ms: 400);
    await tap(t, 'key-7', ms: 1600);
    await tap(t, 'profile-mia', ms: 2200);
    await tap(t, 'current-node', ms: 1500);
    await tap(t, 'lesson-start', ms: 4600);
    await tap(t, 'next-play');
    for (var i = 0; i < 300 && find.byKey(const Key('mic-button')).evaluate().isEmpty; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    await pumpFor(t, 800);
    await tap(t, 'mic-button', ms: 3300);
    await tap(t, 'mic-button', ms: 2300);
    await tap(t, 'say-again', ms: 3300);
    await tap(t, 'mic-button', ms: 3300);
    await tap(t, 'mic-button', ms: 4200);
    await tap(t, 'next-lesson', ms: 1200);
    await tap(t, 'tab-watch', ms: 1500);
    await tap(t, 'tab-stickers', ms: 1800);
    await tap(t, 'parent-lock', ms: 900);
    await tap(t, 'key-4', ms: 400);
    await tap(t, 'key-7', ms: 2400);
  });
}
