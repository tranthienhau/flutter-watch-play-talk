import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class LessonCompleteScreen extends ConsumerStatefulWidget {
  const LessonCompleteScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends ConsumerState<LessonCompleteScreen> with TickerProviderStateMixin {
  late final AnimationController _pop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  late final AnimationController _confetti =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _pop.dispose();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = MockContent.lesson(widget.lessonId);
    final child = ref.watch(activeChildProvider);
    final next = ref.watch(currentLessonProvider);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _confetti,
              builder: (_, _) => CustomPaint(painter: _ConfettiPainter(_confetti.value)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleIconButton(Icons.close_rounded, onTap: () => context.go('/learn')),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill), boxShadow: AppShadows.soft),
                        child: Row(children: [
                          Avatar(child.avatar, size: 30, ringWidth: 0),
                          const SizedBox(width: 6),
                          Text(child.nickname, style: AppText.label.copyWith(fontSize: 14)),
                        ]),
                      ),
                      const Spacer(),
                      const CircleIconButton(Icons.volume_up_outlined, tint: true),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill), boxShadow: AppShadows.soft),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                        Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                        Icon(Icons.star_rounded, color: Color(0xFFF59E0B)),
                        SizedBox(width: 6),
                        Text('+3 Stars', style: AppText.label),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ScaleTransition(
                    scale: CurvedAnimation(parent: _pop, curve: Curves.elasticOut),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Container(
                          width: 210,
                          height: 210,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.glow(AppColors.support)),
                          child: ClipOval(
                            child: l.id == 'colors'
                                ? Image.asset(Img.appleArt, fit: BoxFit.cover)
                                : Container(
                                    color: AppColors.accentTint,
                                    alignment: Alignment.center,
                                    child: Text(l.sticker.emoji, style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w700, color: AppColors.accentFill)),
                                  ),
                          ),
                        ),
                        const Positioned(bottom: -12, child: Pill('NEW STICKER!', support: true, small: true)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text('¡Muy bien, ${child.nickname}!', style: AppText.display),
                  const SizedBox(height: 6),
                  Text(
                    l.id == 'colors' ? 'You learned 3 colors' : 'You finished ${l.title}',
                    style: AppText.body,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final v in l.vocab)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill), boxShadow: AppShadows.soft),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            CircleAvatar(radius: 6, backgroundColor: v.color),
                            const SizedBox(width: 6),
                            Text(v.word.replaceAll(RegExp('[¡!]'), '').toLowerCase(), style: AppText.label.copyWith(fontSize: 15)),
                          ]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const StepPills(active: 3, compact: true),
                  const Spacer(),
                  PrimaryButton(
                    key: const Key('next-lesson'),
                    label: 'Next lesson',
                    icon: Icons.arrow_forward_rounded,
                    kid: true,
                    onTap: () => context.go('/learn'),
                  ),
                  const SizedBox(height: 12),
                  SecondaryButton(label: 'Back to path', leadingIcon: Icons.map_outlined, kid: true, onTap: () => context.go('/learn')),
                  const SizedBox(height: 4),
                  if (next.id != l.id) Text('Up next: ${next.title}', style: AppText.caption),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.t);
  final double t;
  static final _rng = Random(3);
  static final _bits = List.generate(36, (i) => (_rng.nextDouble(), _rng.nextDouble(), _rng.nextInt(4), _rng.nextDouble()));
  static const _colors = [AppColors.accent, AppColors.support, Color(0xFFFACC15), Color(0xFF86D9A8)];

  @override
  void paint(Canvas c, Size s) {
    for (final b in _bits) {
      final y = ((b.$2 + t * (0.25 + b.$4 * 0.2)) % 1.0) * s.height;
      final x = b.$1 * s.width + sin((t + b.$4) * pi * 2) * 12;
      c.save();
      c.translate(x, y);
      c.rotate((t + b.$4) * pi * 2);
      final p = Paint()..color = _colors[b.$3].withValues(alpha: 0.75);
      if (b.$3.isEven) {
        c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -2, 12, 5), const Radius.circular(2)), p);
      } else {
        c.drawCircle(Offset.zero, 4, p);
      }
      c.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
