import 'package:flutter_test/flutter_test.dart';
import 'package:watch_play_talk/game/game_settings.dart';

void main() {
  Map<String, dynamic> base() => {
        'template': 'catch',
        'target': 'apple',
        'distractors': ['blueberry', 'banana'],
        'goal': 10,
        'prompt_es': '¡Atrapa los rojos!',
        'prompt_en': 'Catch the red ones!',
        'target_label': 'Rojo',
      };

  test('valid settings parse', () {
    expect(GameSettings.fromJson(base()).goal, 10);
  });

  test('unknown template is rejected', () {
    expect(() => GameSettings.fromJson(base()..['template'] = 'shooter'), throwsFormatException);
  });

  test('art outside the approved library is rejected', () {
    expect(() => GameSettings.fromJson(base()..['target'] = 'dragon'), throwsFormatException);
  });

  test('toddler limits are enforced', () {
    expect(() => GameSettings.fromJson(base()..['goal'] = 40), throwsFormatException);
    expect(() => GameSettings.fromJson(base()..['fall_speed'] = 400), throwsFormatException);
  });
}
