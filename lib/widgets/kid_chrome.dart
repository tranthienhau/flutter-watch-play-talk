import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/providers.dart';
import '../theme/tokens.dart';
import 'ui.dart';

/// Every route into the parent area passes the parental gate first.
Future<void> openParentArea(BuildContext context) async {
  final ok = await context.push<bool>('/gate');
  if (ok == true && context.mounted) context.push('/parent');
}

/// Kid header: avatar + greeting left, star counter + parent lock right.
class KidHeader extends ConsumerWidget {
  const KidHeader({super.key, this.showStreak = false});
  final bool showStreak;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = ref.watch(activeChildProvider);
    final progress = ref.watch(activeProgressProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            key: const Key('header-avatar'),
            onTap: () => context.go('/profiles'),
            child: Avatar(child.avatar, size: 52, ring: AppColors.accentTint),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Watch Play Talk', style: AppText.caption.copyWith(fontSize: 12)),
                Text(
                  '¡Hola, ${child.nickname}!',
                  style: const TextStyle(fontFamily: AppFonts.display, fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          StarCounter(progress.stars),
          if (showStreak && progress.streakDays > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(6, 6, 10, 6),
              decoration: BoxDecoration(color: AppColors.supportTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
              child: Row(children: [
                const Icon(Icons.local_fire_department_rounded, color: Color(0xFFF97316), size: 20),
                Text('${progress.streakDays}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              ]),
            ),
          ],
          const SizedBox(width: 6),
          CircleIconButton(Icons.lock_outline_rounded, key: const Key('parent-lock'), size: 40, semantic: 'Parent area', onTap: () => openParentArea(context)),
        ],
      ),
    );
  }
}

/// Kid bottom tab bar: Learn, Watch, Stickers. 72px, flat white, hairline.
class KidTabBar extends StatelessWidget {
  const KidTabBar({super.key, required this.index, required this.onTap});
  final int index;
  final ValueChanged<int> onTap;

  static const _tabs = [
    (Icons.map_outlined, 'Learn'),
    (Icons.play_circle_outline_rounded, 'Watch'),
    (Icons.stars_outlined, 'Stickers'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++)
                Expanded(
                  child: InkWell(
                    key: Key('tab-${_tabs[i].$2.toLowerCase()}'),
                    onTap: () => onTap(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
                          decoration: BoxDecoration(
                            color: i == index ? AppColors.accentTint : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Icon(_tabs[i].$1, size: 32, color: i == index ? AppColors.accentFill : AppColors.textTertiary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tabs[i].$2,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: i == index ? AppColors.accentFill : AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
