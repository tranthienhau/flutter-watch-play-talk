import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import 'parent_dashboard_screen.dart';

class ChildProgressScreen extends ConsumerWidget {
  const ChildProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final p = ref.watch(activeProgressProvider);
    final topics = [
      ('Colors', p.isDone('colors') ? 1.0 : 0.8, true),
      ('Numbers', p.isDone('numbers') ? 0.6 : 0.1, false),
      ('Animals', 0.2, false),
      ('My Family', 0.0, false),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const ParentHeader(back: true),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        Row(children: [
                          Avatar(child.avatar, size: 64, ring: AppColors.accentTint),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(child.nickname, style: AppText.title),
                                const SizedBox(width: 8),
                                Pill('Age ${child.age}', small: true),
                              ]),
                              Text('Learning ${child.language.label} • Level 1', style: AppText.caption),
                            ]),
                          ),
                        ]),
                        const Divider(height: 26, color: AppColors.border),
                        Row(children: [
                          const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.success),
                          const SizedBox(width: 6),
                          const Expanded(child: Text('Parent PIN protected', style: AppText.caption)),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit profile'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accentFill,
                              side: const BorderSide(color: AppColors.accent, width: 1.5),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ACTIVE UNIT', style: AppText.overline),
                        Row(children: [
                          const Text('Topic progress', style: AppText.title),
                          const Spacer(),
                          Pill('${topics.length} topics', small: true),
                        ]),
                        const SizedBox(height: 10),
                        for (final t in topics) ...[
                          Row(children: [
                            CircleAvatar(radius: 4, backgroundColor: t.$2 > 0 ? AppColors.accentFill : AppColors.border),
                            const SizedBox(width: 8),
                            Text(t.$1, style: AppText.label.copyWith(fontSize: 15)),
                            if (t.$3) ...[const SizedBox(width: 8), const Pill('Active', small: true, color: AppColors.successTint, textColor: AppColors.success)],
                            const Spacer(),
                            Text(t.$2 == 0 ? 'Up next' : '${(t.$2 * 100).round()}%', style: AppText.caption.copyWith(color: t.$2 > 0 ? AppColors.accentFill : AppColors.textTertiary)),
                          ]),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(value: t.$2, minHeight: 7, color: AppColors.accent, backgroundColor: AppColors.accentTint),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.mic_none_rounded, color: AppColors.accentFill),
                          SizedBox(width: 6),
                          Text('Talk results this week', style: AppText.title),
                        ]),
                        const SizedBox(height: 14),
                        Row(children: [
                          _tile('Right', '${p.talk.right}', 'Accurate', AppColors.success),
                          const SizedBox(width: 10),
                          _tile('Close', '${p.talk.close}', 'Great try', AppColors.warning),
                          const SizedBox(width: 10),
                          _tile('Taps', '${p.talk.taps}', 'Assisted', AppColors.accentFill),
                        ]),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.input)),
                          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.verified_user_outlined, size: 18, color: AppColors.success),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Answers are checked on this device. No audio recordings or voice data are stored or shared.',
                                style: AppText.caption,
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RECENT ACTIVITY', style: AppText.overline),
                        Row(children: [
                          const Text('Lesson history', style: AppText.title),
                          const Spacer(),
                          Pill('${p.completed.length} completed', small: true),
                        ]),
                        const SizedBox(height: 8),
                        for (final c in p.completed.reversed)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text(MockContent.lesson(c.lessonId).title, style: AppText.label.copyWith(fontSize: 15)),
                                  Text(fmtDate(c.date), style: AppText.caption.copyWith(fontSize: 12)),
                                  const SizedBox(height: 6),
                                  const StepPills(active: 3, compact: true),
                                ]),
                              ),
                              for (var i = 0; i < 3; i++)
                                Icon(Icons.star_rounded, size: 18, color: i < c.stars ? const Color(0xFFF59E0B) : AppColors.border),
                            ]),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      const CircleAvatar(backgroundColor: AppColors.supportTint, child: Icon(Icons.calendar_today_outlined, color: Color(0xFFC2410C), size: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Weekly streak: ${p.streakDays} days', style: AppText.label),
                          const Text('Next recommended session: Tomorrow', style: AppText.caption),
                        ]),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, String value, String sub, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircleAvatar(radius: 3, backgroundColor: color),
              const SizedBox(width: 4),
              Text(label, style: AppText.caption.copyWith(fontSize: 12)),
            ]),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            Text(sub, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      );
}
