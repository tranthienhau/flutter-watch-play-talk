import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:watch_play_talk/app.dart';

/// Walks the full parent + child journey and captures real screenshots.
/// Run with --dart-define=DEMO_AUTOPLAY=true so the Catch game plays itself.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFor(WidgetTester t, int ms) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name, {int settleMs = 900}) async {
    await pumpFor(t, settleMs);
    if (Platform.isAndroid) await binding.convertFlutterSurfaceToImage();
    await t.pump();
    await binding.takeScreenshot(name);
  }

  Future<void> tap(WidgetTester t, String key, {int ms = 900}) async {
    await t.tap(find.byKey(Key(key)).first);
    await pumpFor(t, ms);
  }

  Future<void> gate(WidgetTester t, {String? shotName}) async {
    await tap(t, 'key-4', ms: 300);
    if (shotName != null) await shot(t, shotName, settleMs: 200);
    await tap(t, 'key-7', ms: 1200);
  }

  Future<void> waitFor(WidgetTester t, Finder f, {int maxMs = 60000}) async {
    for (var i = 0; i < maxMs ~/ 200; i++) {
      if (f.evaluate().isNotEmpty) return;
      await t.pump(const Duration(milliseconds: 200));
    }
    throw StateError('timed out waiting for $f');
  }

  testWidgets('capture screens', (t) async {
    if (Platform.isIOS) await binding.convertFlutterSurfaceToImage();
    await t.pumpWidget(const ProviderScope(child: WatchPlayTalkApp()));
    await shot(t, '01-welcome', settleMs: 1500);

    await tap(t, 'sign-in-apple');
    await shot(t, '02-subscription');

    await tap(t, 'start-trial');
    await gate(t, shotName: '03-parental-gate');
    await shot(t, '04-child-profiles', settleMs: 1200);

    await tap(t, 'profile-mia', ms: 1200);
    await shot(t, '05-learn-path');

    await tap(t, 'current-node');
    await shot(t, '06-lesson-intro');

    await tap(t, 'lesson-start', ms: 3500);
    await shot(t, '07-watch-clip', settleMs: 100);
    await pumpFor(t, 11000);
    await tap(t, 'next-play', ms: 6000);
    await shot(t, '08-play-game', settleMs: 100);

    await waitFor(t, find.byKey(const Key('mic-button')));
    await pumpFor(t, 600);
    // Q1: heard "asul" -> right.
    await tap(t, 'mic-button', ms: 3200);
    await shot(t, '09-talk-quiz', settleMs: 300);
    // Q2: "mama" -> none -> gentle correction.
    await tap(t, 'mic-button', ms: 2000);
    await shot(t, '10-talk-try-again', settleMs: 300);
    await tap(t, 'say-again', ms: 3200);
    // Q3 close, Q4 right.
    await tap(t, 'mic-button', ms: 3200);
    await tap(t, 'mic-button', ms: 3400);
    await shot(t, '11-lesson-complete', settleMs: 600);

    await tap(t, 'next-lesson', ms: 1200);
    await tap(t, 'tab-watch');
    await shot(t, '12-episodes');
    await tap(t, 'play-episode', ms: 1200);
    await shot(t, '13-episode-player', settleMs: 300);
    await tap(t, 'close-player');
    await tap(t, 'tab-stickers');
    await shot(t, '14-stickers');

    await tap(t, 'parent-lock');
    await gate(t);
    await shot(t, '15-parent-dashboard');
    await tap(t, 'week-card');
    await shot(t, '16-child-progress');
    await tap(t, 'parent-back');
    await tap(t, 'open-settings');
    await shot(t, '17-parent-settings');
    await tap(t, 'mic-switch', ms: 500);
    await tap(t, 'mic-switch', ms: 1200);
    await shot(t, '18-mic-consent');
    await tap(t, 'allow-mic');
    await tap(t, 'settings-back');
    await tap(t, 'parent-close', ms: 1200);

    await tap(t, 'header-avatar', ms: 1200);
    await tap(t, 'profile-leo', ms: 1200);
    await shot(t, '19-first-run');
  });
}
