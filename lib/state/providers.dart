import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_content.dart';
import '../models/models.dart';
import '../services/speech_check.dart';

/// Demo mode: the Catch game basket steers itself. Used for the recorded
/// demo and integration screenshots (`--dart-define=DEMO_AUTOPLAY=true`).
const demoAutoplay = bool.fromEnvironment('DEMO_AUTOPLAY');

final speechCheckProvider = Provider((_) => const SpeechCheck());

// ---------------------------------------------------------------- account

class AccountState {
  const AccountState({this.signedIn = false, this.plan, this.trialEndsOn});
  final bool signedIn;
  final Plan? plan;
  final DateTime? trialEndsOn;
  bool get subscribed => plan != null;
}

class AccountNotifier extends Notifier<AccountState> {
  @override
  AccountState build() => const AccountState();

  void signIn() => state = AccountState(signedIn: true, plan: state.plan, trialEndsOn: state.trialEndsOn);

  /// Stand-in for StoreKit 2 / Play Billing via RevenueCat. Entitlement is
  /// keyed to the parent account, so it unlocks every family device.
  void startTrial(Plan plan) => state = AccountState(
        signedIn: true,
        plan: plan,
        trialEndsOn: DateTime.now().add(const Duration(days: 7)),
      );
}

final accountProvider = NotifierProvider<AccountNotifier, AccountState>(AccountNotifier.new);

// ---------------------------------------------------------------- child

class ActiveChildNotifier extends Notifier<String> {
  @override
  String build() => 'mia';
  void select(String id) => state = id;
}

final activeChildIdProvider = NotifierProvider<ActiveChildNotifier, String>(ActiveChildNotifier.new);

final activeChildProvider = Provider<ChildProfile>((ref) {
  final id = ref.watch(activeChildIdProvider);
  return MockContent.children.firstWhere((c) => c.id == id);
});

// ---------------------------------------------------------------- progress

class ProgressNotifier extends Notifier<Map<String, ChildProgress>> {
  @override
  Map<String, ChildProgress> build() {
    final now = DateTime.now();
    return {
      'mia': ChildProgress(
        completed: [
          CompletedLesson(lessonId: 'hello', date: now.subtract(const Duration(days: 3)), stars: 3),
          CompletedLesson(lessonId: 'numbers', date: now.subtract(const Duration(days: 1)), stars: 3),
        ],
        stars: 24,
        streakDays: 3,
        stickers: const ['sun', 'number3', 'cat', 'rainbow', 'star'],
        talk: const TalkTally(right: 14, close: 4, taps: 3),
        wordsSaid: const {'rojo': true, 'azul': true, 'amarillo': false},
        minutesByDay: const [12, 10, 8, 12, 0, 0, 0],
      ),
      'leo': const ChildProgress(),
      'sofia': ChildProgress(
        completed: [CompletedLesson(lessonId: 'hello', date: now.subtract(const Duration(days: 2)), stars: 2)],
        stars: 6,
        streakDays: 1,
        stickers: const ['sun'],
        talk: const TalkTally(right: 3, close: 2, taps: 4),
        minutesByDay: const [6, 0, 5, 0, 0, 0, 0],
      ),
    };
  }

  ChildProgress of(String childId) => state[childId] ?? const ChildProgress();

  void recordTalk(String childId, String word, TalkResult r) {
    final p = of(childId);
    final said = r == TalkResult.right || r == TalkResult.close;
    state = {
      ...state,
      childId: p.copyWith(
        talk: p.talk.add(r),
        wordsSaid: {...p.wordsSaid, word.toLowerCase(): said || (p.wordsSaid[word.toLowerCase()] ?? false)},
      ),
    };
  }

  /// Returns true when the sticker is new for this child.
  bool completeLesson(String childId, Lesson lesson, int stars) {
    final p = of(childId);
    final isNewSticker = !p.stickers.contains(lesson.sticker.id);
    final days = [...p.minutesByDay];
    days[DateTime.now().weekday - 1] += lesson.minutes;
    state = {
      ...state,
      childId: p.copyWith(
        completed: [
          ...p.completed.where((c) => c.lessonId != lesson.id),
          CompletedLesson(lessonId: lesson.id, date: DateTime.now(), stars: stars),
        ],
        stars: p.stars + stars,
        streakDays: p.streakDays == 0 ? 1 : p.streakDays,
        stickers: isNewSticker ? [lesson.sticker.id, ...p.stickers] : p.stickers,
        minutesByDay: days,
      ),
    };
    return isNewSticker;
  }

  /// Parent "delete child data": wipes events for one profile.
  void reset(String childId) => state = {...state, childId: const ChildProgress()};
}

final progressProvider = NotifierProvider<ProgressNotifier, Map<String, ChildProgress>>(ProgressNotifier.new);

final activeProgressProvider = Provider<ChildProgress>((ref) {
  final id = ref.watch(activeChildIdProvider);
  return ref.watch(progressProvider)[id] ?? const ChildProgress();
});

/// Next lesson on the path for the active child (first not completed).
final currentLessonProvider = Provider<Lesson>((ref) {
  final p = ref.watch(activeProgressProvider);
  return MockContent.lessons.firstWhere((l) => !p.isDone(l.id), orElse: () => MockContent.lessons.last);
});

// ---------------------------------------------------------------- settings

class SettingsNotifier extends Notifier<ParentSettings> {
  @override
  ParentSettings build() => const ParentSettings();
  void setLanguage(LessonLanguage l) => state = state.copyWith(language: l);
  void setMic(bool on) => state = state.copyWith(micEnabled: on);
  void setLimit(int min) => state = state.copyWith(dailyLimitMin: min);
}

final settingsProvider = NotifierProvider<SettingsNotifier, ParentSettings>(SettingsNotifier.new);
