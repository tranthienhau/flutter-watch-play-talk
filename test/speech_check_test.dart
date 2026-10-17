import 'package:flutter_test/flutter_test.dart';
import 'package:watch_play_talk/models/models.dart';
import 'package:watch_play_talk/services/speech_check.dart';

void main() {
  const check = SpeechCheck();
  const rojo = ['rojo', 'red', 'wojo', 'wed'];
  const amarillo = ['amarillo', 'yellow', 'amadillo'];

  test('exact and toddler forms are right', () {
    expect(check.check(['Rojo'], rojo), TalkResult.right);
    expect(check.check(['wojo'], rojo), TalkResult.right);
    expect(check.check(['red'], rojo), TalkResult.right);
  });

  test('sound-alike answers count as close', () {
    expect(check.check(['amariyo'], amarillo), TalkResult.close);
    expect(check.check(['lojo'], rojo), TalkResult.close);
  });

  test('best of the N-best list wins', () {
    expect(check.check(['ojo', 'rojo'], rojo), TalkResult.right);
  });

  test('unrelated speech is none, never a crash', () {
    expect(check.check(['mama', 'manzana'], rojo), TalkResult.none);
    expect(check.check([], rojo), TalkResult.none);
  });
}
