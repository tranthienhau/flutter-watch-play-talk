import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:watch_play_talk/app.dart';

/// Tablet layout: side tab rail + two-column learn path.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpFor(WidgetTester t, int ms) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> tap(WidgetTester t, String key, {int ms = 900}) async {
    await t.tap(find.byKey(Key(key)).first);
    await pumpFor(t, ms);
  }

  testWidgets('capture tablet', (t) async {
    await binding.convertFlutterSurfaceToImage();
    await t.pumpWidget(const ProviderScope(child: WatchPlayTalkApp()));
    await pumpFor(t, 1500);
    await tap(t, 'sign-in-apple');
    await tap(t, 'start-trial');
    await tap(t, 'key-4', ms: 300);
    await tap(t, 'key-7', ms: 1500);
    await tap(t, 'profile-mia', ms: 5000);
    await t.pump();
    await binding.takeScreenshot('20-ipad-learn-path');
  });
}
