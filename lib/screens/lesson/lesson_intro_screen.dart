import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class LessonIntroScreen extends ConsumerWidget {
  const LessonIntroScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = MockContent.lesson(lessonId);
    final lang = ref.watch(settingsProvider).language;
    final steps = [
      (LessonStep.watch, '${(l.minutes / 2).ceil()} min • Video story with Maestra Luna'),
      (LessonStep.play, l.game.promptEn.replaceAll('!', '')),
      (LessonStep.talk, 'Say the words'),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  CircleIconButton(Icons.arrow_back_rounded, onTap: () => context.pop(), semantic: 'Back'),
                  const Spacer(),
                  Pill('Lección ${l.number}', icon: l.icon, small: true),
                  const Spacer(),
                  const CircleIconButton(Icons.volume_up_outlined, tint: true, semantic: 'Hear the lesson name'),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Photo(l.cover, height: 170, radius: 18),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Pill(lang == LessonLanguage.english ? 'English' : 'Español', support: true, small: true),
                                  const SizedBox(width: 8),
                                  Pill('${l.minutes} min', icon: Icons.schedule_rounded, small: true),
                                  const Spacer(),
                                  const Text('3 partes', style: AppText.caption),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text('${l.title}: ${l.subtitle}', style: AppText.displayS),
                              const SizedBox(height: 6),
                              const Text('Learn with Maestra Luna through 3 fun activities!', style: AppText.body),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  for (var i = 0; i < steps.length; i++) ...[
                    _StepCard(index: i, step: steps[i].$1, sub: steps[i].$2, active: i == 0),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: PrimaryButton(
                key: const Key('lesson-start'),
                label: 'Start',
                icon: Icons.arrow_forward_rounded,
                kid: true,
                onTap: () => context.pushReplacement('/lesson/${l.id}/watch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.index, required this.step, required this.sub, required this.active});
  final int index;
  final LessonStep step;
  final String sub;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: active ? AppColors.accent : AppColors.border, width: active ? 2.5 : 1.5),
        boxShadow: active ? AppShadows.soft : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: active ? AppColors.accentFill : AppColors.accentTint,
            child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.accentFill)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(step.icon, size: 20, color: AppColors.accentFill),
                  const SizedBox(width: 6),
                  Text(step.label, style: AppText.label),
                ]),
                const SizedBox(height: 2),
                Text(sub, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (active)
            const Pill('Start here', small: true)
          else
            const Icon(Icons.lock_outline_rounded, color: AppColors.border),
        ],
      ),
    );
  }
}
