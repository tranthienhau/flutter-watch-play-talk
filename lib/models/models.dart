import 'package:flutter/material.dart';

import '../game/game_settings.dart';

enum LessonLanguage { spanish, english, both }

extension LessonLanguageLabel on LessonLanguage {
  String get label => switch (this) {
        LessonLanguage.spanish => 'Español',
        LessonLanguage.english => 'English',
        LessonLanguage.both => 'Both',
      };
}

/// A child profile. Nickname, age band and avatar only: no real name,
/// birthday, photo upload or location (COPPA data minimisation).
class ChildProfile {
  const ChildProfile({
    required this.id,
    required this.nickname,
    required this.age,
    required this.language,
    required this.avatar,
  });

  final String id;
  final String nickname;
  final int age;
  final LessonLanguage language;
  final String avatar;
}

enum LessonStep { watch, play, talk }

extension LessonStepInfo on LessonStep {
  String get label => switch (this) {
        LessonStep.watch => 'Watch',
        LessonStep.play => 'Play',
        LessonStep.talk => 'Talk',
      };
  IconData get icon => switch (this) {
        LessonStep.watch => Icons.play_circle_outline_rounded,
        LessonStep.play => Icons.sports_esports_outlined,
        LessonStep.talk => Icons.mic_none_rounded,
      };
}

/// Spoken vocabulary item shown during the Watch clip.
class VocabWord {
  const VocabWord({required this.word, required this.translation, required this.phonetic, required this.color});
  final String word;
  final String translation;
  final String phonetic;
  final Color color;
}

/// One Talk question. Every line the teacher says is pre-approved and
/// pre-recorded; [accepted] is the closed answer list the on-device
/// recognizer is hinted with.
class TalkQuestion {
  const TalkQuestion({
    required this.prompt,
    required this.promptEn,
    required this.targetWord,
    required this.targetEn,
    required this.answer,
    required this.answerEn,
    required this.phonetic,
    required this.accepted,
    required this.options,
    this.image,
    this.emoji,
    this.simulatedHeard = const [],
  });

  final String prompt;
  final String promptEn;
  final String targetWord;
  final String targetEn;
  final String answer;
  final String answerEn;
  final String phonetic;

  /// Accepted answers in both languages plus common toddler forms.
  final List<String> accepted;

  /// Tap-fallback options (label, dot color).
  final List<(String, Color)> options;
  final String? image;
  final String? emoji;

  /// Simulator stand-in for the recognizer's N-best list, one entry per
  /// attempt, so the demo runs without a microphone.
  final List<List<String>> simulatedHeard;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.number,
    required this.title,
    required this.titleEs,
    required this.subtitle,
    required this.icon,
    required this.minutes,
    required this.cover,
    required this.clip,
    required this.vocab,
    required this.game,
    required this.talk,
    required this.sticker,
  });

  final String id;
  final int number;
  final String title;
  final String titleEs;
  final String subtitle;
  final IconData icon;
  final int minutes;
  final String cover;
  final String clip;
  final List<VocabWord> vocab;
  final GameSettings game;
  final List<TalkQuestion> talk;
  final Sticker sticker;
}

class Sticker {
  const Sticker({required this.id, required this.name, required this.nameEs, required this.emoji});
  final String id;
  final String name;
  final String nameEs;
  final String emoji;
}

class Chapter {
  const Chapter({required this.title, required this.startSec});
  final String title;
  final int startSec;
}

class Episode {
  const Episode({
    required this.id,
    required this.number,
    required this.title,
    required this.description,
    required this.minutes,
    required this.languages,
    required this.image,
    required this.category,
    this.chapters = const [],
    this.isNew = false,
  });

  final String id;
  final int number;
  final String title;
  final String description;
  final int minutes;
  final String languages;
  final String image;
  final String category;
  final List<Chapter> chapters;
  final bool isNew;
}

/// Result of an on-device Talk check. Never contains audio.
enum TalkResult { right, close, none, tap }

class TalkTally {
  const TalkTally({this.right = 0, this.close = 0, this.taps = 0});
  final int right;
  final int close;
  final int taps;

  TalkTally add(TalkResult r) => switch (r) {
        TalkResult.right => TalkTally(right: right + 1, close: close, taps: taps),
        TalkResult.close => TalkTally(right: right, close: close + 1, taps: taps),
        TalkResult.tap => TalkTally(right: right, close: close, taps: taps + 1),
        TalkResult.none => this,
      };
}

class CompletedLesson {
  const CompletedLesson({required this.lessonId, required this.date, required this.stars});
  final String lessonId;
  final DateTime date;
  final int stars;
}

/// Progress for one child, stored as activity events only.
class ChildProgress {
  const ChildProgress({
    this.completed = const [],
    this.stars = 0,
    this.streakDays = 0,
    this.stickers = const [],
    this.talk = const TalkTally(),
    this.wordsSaid = const {},
    this.minutesByDay = const [0, 0, 0, 0, 0, 0, 0],
  });

  final List<CompletedLesson> completed;
  final int stars;
  final int streakDays;
  final List<String> stickers;
  final TalkTally talk;
  final Map<String, bool> wordsSaid;
  final List<int> minutesByDay;

  bool isDone(String lessonId) => completed.any((c) => c.lessonId == lessonId);

  ChildProgress copyWith({
    List<CompletedLesson>? completed,
    int? stars,
    int? streakDays,
    List<String>? stickers,
    TalkTally? talk,
    Map<String, bool>? wordsSaid,
    List<int>? minutesByDay,
  }) =>
      ChildProgress(
        completed: completed ?? this.completed,
        stars: stars ?? this.stars,
        streakDays: streakDays ?? this.streakDays,
        stickers: stickers ?? this.stickers,
        talk: talk ?? this.talk,
        wordsSaid: wordsSaid ?? this.wordsSaid,
        minutesByDay: minutesByDay ?? this.minutesByDay,
      );
}

enum Plan { annual, monthly }

class ParentSettings {
  const ParentSettings({
    this.language = LessonLanguage.both,
    this.dailyLimitMin = 30,
    this.micEnabled = true,
  });
  final LessonLanguage language;
  final int dailyLimitMin;
  final bool micEnabled;

  ParentSettings copyWith({LessonLanguage? language, int? dailyLimitMin, bool? micEnabled}) => ParentSettings(
        language: language ?? this.language,
        dailyLimitMin: dailyLimitMin ?? this.dailyLimitMin,
        micEnabled: micEnabled ?? this.micEnabled,
      );
}
