import 'package:flutter/material.dart';

import '../game/game_settings.dart';
import '../models/models.dart';
import '../theme/tokens.dart';

/// Local image paths (real photography from the design).
class Img {
  static const _p = 'assets/images';
  static const appIcon = '$_p/app-icon.png';
  static const welcomeHero = '$_p/01-mother-and-daughter-laughing-while.jpg';
  static const mia = '$_p/03-mia.jpg';
  static const leo = '$_p/03-leo.jpg';
  static const sofia = '$_p/03-sofia.jpg';
  static const miaAvatar = '$_p/05-mia-avatar-profile-photo.jpg';
  static const leoAvatar = '$_p/06-leo-profile-avatar.jpg';
  static const paywallHero = '$_p/04-happy-young-toddler-laughing-while.jpg';
  static const luna = '$_p/06-maestra-luna-teacher-portrait.jpg';
  static const lunaBadge = '$_p/05-closeup-circular-portrait-photo-of.jpg';
  static const crayons = '$_p/07-colorful-red-blue-and-yellow.jpg';
  static const crayonsTable = '$_p/20-wax-crayons-on-wooden-table.jpg';
  static const lunaApple = '$_p/08-maestra-luna-holding-up-a.jpg';
  static const apple = '$_p/10-crisp-red-apple-on-a.jpg';
  static const appleArt = '$_p/11-ripe-red-apple-illustration-reference.jpg';
  static const epColors = '$_p/13-joyful-bilingual-preschool-music-lesson.jpg';
  static const epAnimals = '$_p/13-playful-documentary-shot-of-a.jpg';
  static const epCount = '$_p/13-preschool-teacher-sitting-with-four.jpg';
  static const epBody = '$_p/13-charming-bilingual-circle-time-in.jpg';
  static const lunaSinging = '$_p/14-maestra-luna-singing-and-engaging.jpg';
  static const chapterCount = '$_p/14-counting-chapter-thumbnail.jpg';
  static const chapterAnimals = '$_p/14-animals-chapter-thumbnail.jpg';
  static const sofiaAlt = '$_p/16-img.jpg';
  static const micConsent = '$_p/19-warm-authentic-documentary-lifestyle-photograph.jpg';
  static const lunaPreschool = '$_p/24-maestra-luna-singing-with-preschoolers.jpg';
  static const clapping = '$_p/24-teacher-leading-clapping-song-circle.jpg';
  static const singingCircle = '$_p/24-teacher-and-children-singing-in.jpg';
  static const lunaPuppet = '$_p/26-maestra-luna-with-cute-animal.jpg';
  static const dancing = '$_p/28-teacher-dancing-and-singing-with.jpg';
}

class MockContent {
  static const children = [
    ChildProfile(id: 'mia', nickname: 'Mia', age: 3, language: LessonLanguage.spanish, avatar: Img.miaAvatar),
    ChildProfile(id: 'leo', nickname: 'Leo', age: 5, language: LessonLanguage.both, avatar: Img.leoAvatar),
    ChildProfile(id: 'sofia', nickname: 'Sofia', age: 2, language: LessonLanguage.english, avatar: Img.sofia),
  ];

  /// Game settings arrive from the backend as approved JSON and are parsed
  /// through the schema check, exactly as the app would in production.
  static final _games = {
    'hello': GameSettings.fromJson({
      'template': 'catch',
      'target': 'hand',
      'distractors': ['sun', 'star'],
      'goal': 5,
      'prompt_es': '¡Atrapa las manos!',
      'prompt_en': 'Catch the waving hands!',
      'target_label': 'Hola',
    }),
    'numbers': GameSettings.fromJson({
      'template': 'catch',
      'target': 'number3',
      'distractors': ['star', 'sun'],
      'goal': 6,
      'prompt_es': '¡Atrapa el tres!',
      'prompt_en': 'Catch the number three!',
      'target_label': 'Tres',
    }),
    'colors': GameSettings.fromJson({
      'template': 'catch',
      'target': 'apple',
      'distractors': ['blueberry', 'banana'],
      'goal': 10,
      'prompt_es': '¡Atrapa los rojos!',
      'prompt_en': 'Catch the red ones!',
      'target_label': 'Rojo',
      'fall_speed': 130,
      'spawn_every_ms': 950,
    }),
  };

  static const _colorOptions = [
    ('Rojo', AppColors.gameRed),
    ('Azul', AppColors.gameBlue),
    ('Amarillo', AppColors.gameYellow),
  ];

  static final lessons = [
    Lesson(
      id: 'hello',
      number: 1,
      title: 'Hello and Goodbye',
      titleEs: '¡Hola y Adiós!',
      subtitle: 'hola, adiós',
      icon: Icons.waving_hand_outlined,
      minutes: 3,
      cover: Img.clapping,
      clip: Img.singingCircle,
      vocab: const [
        VocabWord(word: '¡Hola!', translation: 'Hello', phonetic: 'Oh-lah', color: AppColors.accentFill),
        VocabWord(word: '¡Adiós!', translation: 'Goodbye', phonetic: 'Ah-dee-ohs', color: AppColors.support),
      ],
      game: _games['hello']!,
      talk: const [
        TalkQuestion(
          prompt: '¿Cómo se dice hello?',
          promptEn: 'How do you say hello?',
          targetWord: '¡Hola!',
          targetEn: 'Hello',
          answer: 'Hola',
          answerEn: 'Hello',
          phonetic: 'Oh-lah',
          accepted: ['hola', 'hello', 'ola', 'lola'],
          options: [('Hola', AppColors.accentFill), ('Adiós', AppColors.support)],
          emoji: '👋',
          simulatedHeard: [
            ['ola', 'hola'],
          ],
        ),
        TalkQuestion(
          prompt: '¿Cómo se dice goodbye?',
          promptEn: 'How do you say goodbye?',
          targetWord: '¡Adiós!',
          targetEn: 'Goodbye',
          answer: 'Adiós',
          answerEn: 'Goodbye',
          phonetic: 'Ah-dee-ohs',
          accepted: ['adiós', 'adios', 'goodbye', 'bye bye', 'dios'],
          options: [('Hola', AppColors.accentFill), ('Adiós', AppColors.support)],
          emoji: '🙋',
          simulatedHeard: [
            ['adio', 'audio'],
          ],
        ),
      ],
      sticker: const Sticker(id: 'sun', name: 'Sun', nameEs: '¡Sol!', emoji: '☀️'),
    ),
    Lesson(
      id: 'numbers',
      number: 2,
      title: 'Numbers 1 to 5',
      titleEs: 'Los Números',
      subtitle: 'uno, dos, tres',
      icon: Icons.pin_outlined,
      minutes: 4,
      cover: Img.chapterCount,
      clip: Img.epCount,
      vocab: const [
        VocabWord(word: '¡Uno!', translation: 'One', phonetic: 'Oo-noh', color: AppColors.accentFill),
        VocabWord(word: '¡Dos!', translation: 'Two', phonetic: 'Dohs', color: AppColors.support),
        VocabWord(word: '¡Tres!', translation: 'Three', phonetic: 'Trehs', color: AppColors.accent),
      ],
      game: _games['numbers']!,
      talk: const [
        TalkQuestion(
          prompt: '¿Cuántas estrellas?',
          promptEn: 'How many stars?',
          targetWord: '⭐ ⭐ ⭐',
          targetEn: 'Three stars',
          answer: 'Tres',
          answerEn: 'Three',
          phonetic: 'Trehs',
          accepted: ['tres', 'three', 'tre', 'free'],
          options: [('Dos', AppColors.support), ('Tres', AppColors.accentFill), ('Cinco', AppColors.accent)],
          emoji: '⭐',
          simulatedHeard: [
            ['tre', 'tres'],
          ],
        ),
      ],
      sticker: const Sticker(id: 'number3', name: 'Number 3', nameEs: '¡Número 3!', emoji: '3'),
    ),
    Lesson(
      id: 'colors',
      number: 3,
      title: 'Colors',
      titleEs: 'Los Colores',
      subtitle: 'rojo, azul, amarillo',
      icon: Icons.palette_outlined,
      minutes: 4,
      cover: Img.crayons,
      clip: Img.lunaApple,
      vocab: const [
        VocabWord(word: '¡Rojo!', translation: 'Red', phonetic: 'Roh-hoh', color: AppColors.gameRed),
        VocabWord(word: '¡Azul!', translation: 'Blue', phonetic: 'Ah-sool', color: AppColors.gameBlue),
        VocabWord(word: '¡Amarillo!', translation: 'Yellow', phonetic: 'Ah-mah-ree-yoh', color: Color(0xFFCA9A04)),
      ],
      game: _games['colors']!,
      talk: const [
        TalkQuestion(
          prompt: '¿De qué color es el arándano?',
          promptEn: 'What color is the blueberry?',
          targetWord: 'El arándano',
          targetEn: 'The blueberry',
          answer: 'Azul',
          answerEn: 'Blue',
          phonetic: 'Ah-sool',
          accepted: ['azul', 'blue', 'asul', 'zul', 'bu'],
          options: _colorOptions,
          emoji: '🫐',
          simulatedHeard: [
            ['asul', 'azul'],
          ],
        ),
        TalkQuestion(
          prompt: '¿De qué color es la manzana?',
          promptEn: 'What color is the apple?',
          targetWord: 'La manzana',
          targetEn: 'The apple',
          answer: 'Rojo',
          answerEn: 'Red',
          phonetic: 'Roh-hoh',
          accepted: ['rojo', 'red', 'wojo', 'wed', 'oho', 'lojo'],
          options: _colorOptions,
          image: Img.apple,
          simulatedHeard: [
            ['mama', 'manzana'],
            ['wojo', 'ojo'],
          ],
        ),
        TalkQuestion(
          prompt: '¿De qué color es el plátano?',
          promptEn: 'What color is the banana?',
          targetWord: 'El plátano',
          targetEn: 'The banana',
          answer: 'Amarillo',
          answerEn: 'Yellow',
          phonetic: 'Ah-mah-ree-yoh',
          accepted: ['amarillo', 'yellow', 'amadillo', 'malillo', 'lellow'],
          options: _colorOptions,
          emoji: '🍌',
          simulatedHeard: [
            ['amariyo', 'a mario'],
          ],
        ),
        TalkQuestion(
          prompt: '¿De qué color es la fresa?',
          promptEn: 'What color is the strawberry?',
          targetWord: 'La fresa',
          targetEn: 'The strawberry',
          answer: 'Rojo',
          answerEn: 'Red',
          phonetic: 'Roh-hoh',
          accepted: ['rojo', 'red', 'wojo', 'wed', 'oho', 'lojo'],
          options: _colorOptions,
          emoji: '🍓',
          simulatedHeard: [
            ['red'],
          ],
        ),
      ],
      sticker: const Sticker(id: 'apple', name: 'Apple', nameEs: '¡Manzana!', emoji: '🍎'),
    ),
    Lesson(
      id: 'animals',
      number: 4,
      title: 'Animals',
      titleEs: 'Los Animales',
      subtitle: 'gato, perro, pez',
      icon: Icons.cruelty_free_outlined,
      minutes: 5,
      cover: Img.chapterAnimals,
      clip: Img.lunaPuppet,
      vocab: const [],
      game: _games['hello']!,
      talk: const [],
      sticker: const Sticker(id: 'cat', name: 'Cat', nameEs: '¡Gatito!', emoji: '🐱'),
    ),
    Lesson(
      id: 'family',
      number: 5,
      title: 'My Family',
      titleEs: 'Mi Familia',
      subtitle: 'mamá, papá, bebé',
      icon: Icons.diversity_1_outlined,
      minutes: 5,
      cover: Img.welcomeHero,
      clip: Img.welcomeHero,
      vocab: const [],
      game: _games['hello']!,
      talk: const [],
      sticker: const Sticker(id: 'rainbow', name: 'Rainbow', nameEs: '¡Arcoíris!', emoji: '🌈'),
    ),
  ];

  static Lesson lesson(String id) => lessons.firstWhere((l) => l.id == id);

  static const allStickers = [
    Sticker(id: 'apple', name: 'Apple', nameEs: '¡Manzana!', emoji: '🍎'),
    Sticker(id: 'sun', name: 'Sun', nameEs: '¡Sol!', emoji: '☀️'),
    Sticker(id: 'cat', name: 'Cat', nameEs: '¡Gatito!', emoji: '🐱'),
    Sticker(id: 'number3', name: 'Number 3', nameEs: '¡Número 3!', emoji: '3'),
    Sticker(id: 'rainbow', name: 'Rainbow', nameEs: '¡Arcoíris!', emoji: '🌈'),
    Sticker(id: 'star', name: 'Star', nameEs: '¡Estrella!', emoji: '⭐'),
    Sticker(id: 'l7', name: 'Lesson 7', nameEs: '', emoji: ''),
    Sticker(id: 'l8', name: 'Lesson 8', nameEs: '', emoji: ''),
    Sticker(id: 'l9', name: 'Lesson 9', nameEs: '', emoji: ''),
    Sticker(id: 'l10', name: 'Lesson 10', nameEs: '', emoji: ''),
    Sticker(id: 'l11', name: 'Lesson 11', nameEs: '', emoji: ''),
    Sticker(id: 'l12', name: 'Lesson 12', nameEs: '', emoji: ''),
  ];

  static const episodes = [
    Episode(
      id: 'ep42',
      number: 42,
      title: 'Colors Everywhere',
      description: 'Sing along with Maestra Luna and discover rojo, azul, y amarillo!',
      minutes: 48,
      languages: 'Spanish & English',
      image: Img.epColors,
      category: 'Español',
      isNew: true,
      chapters: [
        Chapter(title: 'Hello song', startSec: 0),
        Chapter(title: 'Colors (Los colores)', startSec: 252),
        Chapter(title: 'Counting (Los números)', startSec: 700),
        Chapter(title: 'Animals (Los animales)', startSec: 1145),
      ],
    ),
    Episode(
      id: 'ep41',
      number: 41,
      title: 'Animal Friends',
      description: 'Meet el gato, el perro y el pez with Maestra Luna and her puppet friend.',
      minutes: 52,
      languages: 'Spanish & English',
      image: Img.epAnimals,
      category: 'English',
      chapters: [
        Chapter(title: 'Hello song', startSec: 0),
        Chapter(title: 'Pets (Las mascotas)', startSec: 300),
        Chapter(title: 'Farm (La granja)', startSec: 1320),
      ],
    ),
    Episode(
      id: 'ep40',
      number: 40,
      title: 'Count With Me',
      description: 'Uno, dos, tres! Count fingers, toes and apples together.',
      minutes: 45,
      languages: 'Spanish & English',
      image: Img.epCount,
      category: 'Songs',
      chapters: [
        Chapter(title: 'Counting song', startSec: 0),
        Chapter(title: 'Numbers 1 to 5', startSec: 420),
      ],
    ),
    Episode(
      id: 'ep39',
      number: 39,
      title: 'My Body',
      description: 'Head, shoulders, knees and toes, en español y en inglés.',
      minutes: 50,
      languages: 'Spanish & English',
      image: Img.epBody,
      category: 'Songs',
      chapters: [
        Chapter(title: 'Cabeza y hombros', startSec: 0),
      ],
    ),
  ];
}
