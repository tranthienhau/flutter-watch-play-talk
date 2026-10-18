import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

String fmtDate(DateTime d) {
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${m[d.month - 1]} ${d.day}';
}

/// Shared parent-area header: lock + title, optional back, close.
class ParentHeader extends StatelessWidget {
  const ParentHeader({super.key, this.title = 'Parent area', this.back = false, this.trailing});
  final String title;
  final bool back;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          if (back) ...[CircleIconButton(Icons.arrow_back_rounded, key: const Key('parent-back'), onTap: () => context.pop(), semantic: 'Back'), const SizedBox(width: 8)],
          const Icon(Icons.lock_outline_rounded, size: 20, color: AppColors.accentFill),
          const SizedBox(width: 8),
          Text(title, style: AppText.title),
          const Spacer(),
          ?trailing,
          const SizedBox(width: 8),
          CircleIconButton(Icons.close_rounded, key: const Key('parent-close'), onTap: () => context.go('/learn'), semantic: 'Leave parent area'),
        ],
      ),
    );
  }
}

class ParentDashboardScreen extends ConsumerWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final p = ref.watch(activeProgressProvider);
    final account = ref.watch(accountProvider);
    final total = p.minutesByDay.fold<int>(0, (a, b) => a + b);
    final active = p.minutesByDay.where((m) => m > 0).length;
    final words = p.wordsSaid.length + p.completed.length * 4;
    final colors = MockContent.lesson('colors').vocab;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ParentHeader(
              trailing: CircleIconButton(Icons.settings_outlined, key: const Key('open-settings'), onTap: () => context.push('/parent/settings'), semantic: 'Settings'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  Row(children: [
                    const Text('Select learner', style: AppText.caption),
                    const Spacer(),
                    Text('${child.language == LessonLanguage.english ? 'English' : 'Spanish'} track', style: AppText.caption.copyWith(color: AppColors.accentFill, fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      for (final c in MockContent.children)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _LearnerChip(child: c, selected: c.id == child.id, onTap: () => ref.read(activeChildIdProvider.notifier).select(c.id)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    key: const Key('week-card'),
                    onTap: () => context.push('/parent/child'),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), gradient: AppGradients.heroDiagonal, boxShadow: AppShadows.soft),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('${child.nickname} this week', style: const TextStyle(fontFamily: AppFonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                              const Text('Goal: 10 mins • 5 days/wk', style: TextStyle(fontSize: 13, color: Colors.white)),
                            ]),
                            const Spacer(),
                            Pill(active >= 3 ? 'On track' : 'Getting started', icon: Icons.auto_awesome, small: true, color: Colors.white, textColor: AppColors.accentFill),
                          ]),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(AppRadius.control)),
                            child: Row(children: [
                              _stat('${p.completed.length}', 'lessons done'),
                              _divider(),
                              _stat('$words', 'words learned'),
                              _divider(),
                              _stat('${total}m', 'total time'),
                            ]),
                          ),
                          const SizedBox(height: 14),
                          Row(children: [
                            const Text('Daily practice time', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('Avg ${active == 0 ? 0 : (total / active).toStringAsFixed(1)}m / day', style: const TextStyle(fontSize: 13, color: Colors.white)),
                          ]),
                          const SizedBox(height: 10),
                          _WeekBars(minutes: p.minutesByDay),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Words practiced', style: AppText.title),
                              Text('Colors unit • Spanish', style: AppText.caption),
                            ]),
                          ),
                          CircleIconButton(Icons.volume_up_outlined, size: 38, tint: true),
                        ]),
                        const SizedBox(height: 10),
                        for (final v in colors) _wordRow(v, p.wordsSaid[v.word.replaceAll(RegExp('[¡!]'), '').toLowerCase()]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Recent lessons', style: AppText.title),
                              Text('Step flow: Watch • Play • Talk', style: AppText.caption),
                            ]),
                          ),
                          Pill('${p.completed.length} completed', small: true),
                        ]),
                        const SizedBox(height: 8),
                        if (p.completed.isEmpty)
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('No lessons yet. The first one takes about 3 minutes.', style: AppText.caption)),
                        for (final c in p.completed.reversed) _lessonRow(MockContent.lesson(c.lessonId), c),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    onTap: () => context.push('/parent/settings'),
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const CircleAvatar(backgroundColor: AppColors.accentTint, child: Icon(Icons.credit_card_rounded, color: AppColors.accentFill)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Manage subscription', style: AppText.label),
                          Text(
                            'Watch Play Talk Family Plan • ${account.plan == Plan.monthly ? 'Monthly' : 'Annual'}',
                            style: AppText.caption,
                          ),
                        ]),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    ]),
                  ),
                  const SizedBox(height: 14),
                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.verified_user_outlined, size: 16, color: AppColors.success),
                    SizedBox(width: 6),
                    Text('Adult verification active', style: TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w500)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String v, String l) => Expanded(
        child: Column(children: [
          Text(v, style: const TextStyle(fontFamily: AppFonts.body, fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(l, style: const TextStyle(fontSize: 11.5, color: Colors.white)),
        ]),
      );

  Widget _divider() => Container(width: 1, height: 34, color: Colors.white38);

  Widget _wordRow(VocabWord v, bool? said) {
    final word = v.word.replaceAll(RegExp('[¡!]'), '').toLowerCase();
    final ok = said == true;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        CircleAvatar(radius: 16, backgroundColor: v.color.withValues(alpha: 0.15), child: Icon(Icons.record_voice_over_outlined, size: 16, color: v.color)),
        const SizedBox(width: 10),
        Text(word, style: AppText.label),
        Text('  • ${v.translation}', style: AppText.caption),
        const Spacer(),
        Pill(
          ok ? 'said it' : 'practicing',
          icon: ok ? Icons.check_rounded : Icons.hourglass_top_rounded,
          small: true,
          color: ok ? AppColors.successTint : AppColors.warningTint,
          textColor: ok ? AppColors.success : AppColors.warning,
        ),
      ]),
    );
  }

  Widget _lessonRow(Lesson l, CompletedLesson c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          CircleAvatar(radius: 20, backgroundColor: AppColors.accentTint, child: Icon(l.icon, size: 20, color: AppColors.accentFill)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${l.title}${l.id == 'colors' ? ': ${l.subtitle}' : ''}', style: AppText.label.copyWith(fontSize: 15)),
              Text('${fmtDate(c.date)} • Complete', style: AppText.caption.copyWith(fontSize: 12)),
            ]),
          ),
          const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
          Text(' ${c.stars}', style: AppText.label.copyWith(fontSize: 14)),
        ]),
      );
}

class _LearnerChip extends StatelessWidget {
  const _LearnerChip({required this.child, required this.selected, required this.onTap});
  final ChildProfile child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentTint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Avatar(child.avatar, size: 34, ringWidth: 0),
          const SizedBox(width: 6),
          Text(child.nickname, style: AppText.label.copyWith(fontSize: 15, color: selected ? AppColors.accentFill : AppColors.textPrimary)),
          if (selected) ...[const SizedBox(width: 4), const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.accentFill)],
        ]),
      ),
    );
  }
}

/// Bubble bars for daily practice minutes (Mon..Sun).
class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.minutes});
  final List<int> minutes;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Column(children: [
              Text(minutes[i] > 0 ? '${minutes[i]}m' : '-', style: const TextStyle(fontSize: 10.5, color: Colors.white)),
              const SizedBox(height: 4),
              Container(
                width: 34,
                height: minutes[i] > 0 ? 34 : 8,
                decoration: BoxDecoration(
                  color: minutes[i] > 0 ? Colors.white : Colors.white38,
                  borderRadius: BorderRadius.circular(20),
                  border: i == today ? Border.all(color: AppColors.accentFill, width: 2) : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(days[i], style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: i == today ? FontWeight.w700 : FontWeight.w400)),
            ]),
          ),
      ],
    );
  }
}
