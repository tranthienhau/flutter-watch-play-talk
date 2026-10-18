import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/learn/learn_path_screen.dart';
import 'screens/lesson/lesson_complete_screen.dart';
import 'screens/lesson/lesson_intro_screen.dart';
import 'screens/lesson/play_game_screen.dart';
import 'screens/lesson/talk_quiz_screen.dart';
import 'screens/lesson/watch_clip_screen.dart';
import 'screens/onboarding/child_profiles_screen.dart';
import 'screens/onboarding/parental_gate_screen.dart';
import 'screens/onboarding/subscription_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/parent/child_progress_screen.dart';
import 'screens/parent/mic_consent_screen.dart';
import 'screens/parent/parent_dashboard_screen.dart';
import 'screens/parent/parent_settings_screen.dart';
import 'screens/stickers/stickers_screen.dart';
import 'screens/watch/episode_player_screen.dart';
import 'screens/watch/episodes_screen.dart';
import 'theme/tokens.dart';
import 'widgets/kid_chrome.dart';

final rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter() => GoRouter(
      navigatorKey: rootKey,
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const WelcomeScreen()),
        GoRoute(path: '/subscribe', builder: (_, _) => const SubscriptionScreen()),
        GoRoute(
          path: '/gate',
          pageBuilder: (_, s) => MaterialPage(key: s.pageKey, fullscreenDialog: true, child: const ParentalGateScreen()),
        ),
        GoRoute(path: '/profiles', builder: (_, _) => const ChildProfilesScreen()),
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) => KidShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/learn', builder: (_, _) => const LearnPathScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/watch', builder: (_, _) => const EpisodesScreen())]),
            StatefulShellBranch(routes: [GoRoute(path: '/stickers', builder: (_, _) => const StickersScreen())]),
          ],
        ),
        GoRoute(
          path: '/lesson/:id',
          builder: (_, s) => LessonIntroScreen(lessonId: s.pathParameters['id']!),
          routes: [
            GoRoute(path: 'watch', builder: (_, s) => WatchClipScreen(lessonId: s.pathParameters['id']!)),
            GoRoute(path: 'play', builder: (_, s) => PlayGameScreen(lessonId: s.pathParameters['id']!)),
            GoRoute(path: 'talk', builder: (_, s) => TalkQuizScreen(lessonId: s.pathParameters['id']!)),
            GoRoute(path: 'done', builder: (_, s) => LessonCompleteScreen(lessonId: s.pathParameters['id']!)),
          ],
        ),
        GoRoute(path: '/episode/:id', builder: (_, s) => EpisodePlayerScreen(episodeId: s.pathParameters['id']!)),
        GoRoute(
          path: '/parent',
          builder: (_, _) => const ParentDashboardScreen(),
          routes: [
            GoRoute(path: 'child', builder: (_, _) => const ChildProgressScreen()),
            GoRoute(path: 'settings', builder: (_, _) => const ParentSettingsScreen()),
            GoRoute(
              path: 'mic',
              pageBuilder: (_, s) => MaterialPage(key: s.pageKey, fullscreenDialog: true, child: const MicConsentScreen()),
            ),
          ],
        ),
      ],
    );

/// Kid area shell: bottom tab bar on phones, side tab rail on tablets.
class KidShell extends StatelessWidget {
  const KidShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  void _go(int i) => shell.goBranch(i, initialLocation: i == shell.currentIndex);

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 700;
    if (!wide) {
      return Scaffold(
        body: SafeArea(bottom: false, child: shell),
        bottomNavigationBar: KidTabBar(index: shell.currentIndex, onTap: _go),
      );
    }
    const tabs = [
      (Icons.map_outlined, 'Learn'),
      (Icons.play_circle_outline_rounded, 'Watch'),
      (Icons.stars_outlined, 'Stickers'),
    ];
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Container(
              width: 96,
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  for (var i = 0; i < tabs.length; i++)
                    InkWell(
                      onTap: () => _go(i),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Column(children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: i == shell.currentIndex ? AppColors.accentTint : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.control),
                            ),
                            child: Icon(tabs[i].$1, size: 32, color: i == shell.currentIndex ? AppColors.accentFill : AppColors.textTertiary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tabs[i].$2,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: i == shell.currentIndex ? AppColors.accentFill : AppColors.textTertiary,
                            ),
                          ),
                        ]),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(child: shell),
          ],
        ),
      ),
    );
  }
}
