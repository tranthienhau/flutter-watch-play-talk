import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/kid_chrome.dart';
import '../../widgets/ui.dart';

class LearnPathScreen extends ConsumerWidget {
  const LearnPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(activeProgressProvider);
    final wide = MediaQuery.sizeOf(context).width >= 700;
    if (progress.completed.isEmpty) return const _FirstRunPath();
    return Column(
      children: [
        const KidHeader(showStreak: true),
        Expanded(child: wide ? const _TabletPath() : const _WindingPath()),
      ],
    );
  }
}

void _openLesson(BuildContext context, Lesson l) {
  if (l.talk.isEmpty) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${l.title} arrives with this week\'s episode. ¡Muy pronto!')));
    return;
  }
  context.push('/lesson/${l.id}');
}

void _lockedHint(BuildContext context, Lesson current) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('Finish ${current.title} first. ¡Tú puedes!')));
}

// ------------------------------------------------------------------ phone

class _WindingPath extends ConsumerStatefulWidget {
  const _WindingPath();

  @override
  ConsumerState<_WindingPath> createState() => _WindingPathState();
}

class _WindingPathState extends ConsumerState<_WindingPath> {
  static const _xs = [0.36, 0.7, 0.5, 0.26, 0.52];
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(activeProgressProvider);
    final current = ref.watch(currentLessonProvider);
    final lessons = MockContent.lessons;
    final curIdx = lessons.indexOf(current);

    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth;
      // Bottom-up y positions; extra room under the current node for its card.
      final ys = <double>[];
      var y = 90.0;
      for (var i = 0; i < lessons.length; i++) {
        if (i > 0) y += 165 + (i == curIdx ? 170 : 0) + (i - 1 == curIdx ? 30 : 0);
        ys.add(y);
      }
      final height = y + 130;
      Offset c(int i) => Offset(_xs[i] * w, height - ys[i]);
      // Open with the current lesson in view (reverse scroll: 0 = bottom).
      _scroll ??= ScrollController(
        initialScrollOffset: max(0, ys[curIdx] - box.maxHeight * 0.62),
      );

      return Container(
        decoration: const BoxDecoration(gradient: AppGradients.pathBackdrop),
        child: SingleChildScrollView(
          controller: _scroll,
          reverse: true,
          child: SizedBox(
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _PathPainter([for (var i = 0; i < lessons.length; i++) c(i)], curIdx)),
                ),
                for (var i = 0; i < lessons.length; i++)
                  if (i == curIdx)
                    ..._currentNode(context, lessons[i], c(i), w)
                  else
                    _node(
                      context,
                      lessons[i],
                      c(i),
                      done: progress.isDone(lessons[i].id),
                      onLocked: () => _lockedHint(context, current),
                    ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _node(BuildContext context, Lesson l, Offset c, {required bool done, required VoidCallback onLocked}) {
    const size = 76.0;
    return Positioned(
      left: c.dx - 70,
      top: c.dy - size / 2,
      width: 140,
      child: GestureDetector(
        onTap: done ? () => _openLesson(context, l) : onLocked,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: done ? AppColors.surface : AppColors.surface.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: done ? AppColors.accent.withValues(alpha: 0.35) : AppColors.border, width: 3),
                    boxShadow: done ? AppShadows.soft : null,
                  ),
                  child: Icon(
                    done ? l.icon : Icons.lock_outline_rounded,
                    size: 32,
                    color: done ? AppColors.accentFill : AppColors.textTertiary.withValues(alpha: 0.7),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: done ? AppColors.success : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: AppShadows.soft,
                    ),
                    child: Icon(done ? Icons.check_rounded : l.icon, size: 15, color: done ? Colors.white : AppColors.textTertiary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: done ? AppColors.textPrimary : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _currentNode(BuildContext context, Lesson l, Offset c, double w) {
    const size = 104.0;
    return [
      Positioned(
        left: c.dx - 75,
        top: c.dy - 75,
        width: 150,
        height: 150,
        child: GestureDetector(
          key: const Key('current-node'),
          onTap: () => _openLesson(context, l),
          child: _GlowingNode(icon: l.icon, size: size),
        ),
      ),
      // Maestra Luna badge + bubble.
      Positioned(
        left: max(8, c.dx - 180),
        top: c.dy - 105,
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Avatar(Img.lunaBadge, size: 64, ring: AppColors.support, ringWidth: 3),
            SizedBox(width: 6),
            Padding(padding: EdgeInsets.only(top: 18), child: SpeechBubble('¡Vamos!')),
          ],
        ),
      ),
      Positioned(
        left: 20,
        right: 20,
        top: c.dy + 70,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: AppCard(
              onTap: () => _openLesson(context, l),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.accentFill),
                      SizedBox(width: 6),
                      Text('CURRENT LESSON', style: AppText.overline),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(l.title, style: const TextStyle(fontFamily: AppFonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Text(l.subtitle, style: AppText.body.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  const StepPills(active: 0, compact: true),
                ],
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

class _GlowingNode extends StatefulWidget {
  const _GlowingNode({required this.icon, required this.size});
  final IconData icon;
  final double size;

  @override
  State<_GlowingNode> createState() => _GlowingNodeState();
}

class _GlowingNodeState extends State<_GlowingNode> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = Curves.easeInOut.transform(_c.value);
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Container(
              width: widget.size + 22 + t * 18,
              height: widget.size + 22 + t * 18,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.18 - t * 0.08)),
            ),
            Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFAE90F0), AppColors.accentFill],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white, width: 5),
                boxShadow: AppShadows.glow(AppColors.accent),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 48),
            ),
            Positioned(
              right: 14,
              top: 10,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.support,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter(this.points, this.currentIdx);
  final List<Offset> points;
  final int currentIdx;

  Path _curve() {
    final p = Path()..moveTo(points.first.dx, points.first.dy + 120);
    p.lineTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final a = points[i], b = points[i + 1];
      final midY = (a.dy + b.dy) / 2;
      p.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }
    p.relativeLineTo(0, -120);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _curve();
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 44
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.linear(
        Offset(0, size.height),
        Offset.zero,
        [AppColors.support.withValues(alpha: 0.45), AppColors.accent.withValues(alpha: 0.35)],
      );
    canvas.drawPath(path, band);

    // Dashed centre line.
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.9);
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 22) {
        canvas.drawPath(m.extractPath(d, d + 10), dash);
      }
    }
  }

  @override
  bool shouldRepaint(_PathPainter old) => old.points != points;
}

// ------------------------------------------------------------- first run

class _FirstRunPath extends ConsumerWidget {
  const _FirstRunPath();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final first = MockContent.lessons.first;
    return Column(
      children: [
        const KidHeader(),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(gradient: AppGradients.pathBackdrop),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          const Avatar(Img.luna, size: 64, ring: AppColors.supportTint),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                              child: const Icon(Icons.check, size: 10, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Ready for your first lesson?', style: AppText.label),
                            Text('¡Vamos! 👋', style: TextStyle(fontFamily: AppFonts.display, fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accentFill)),
                            Text('Let\'s start with Hello and Goodbye.', style: AppText.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.card + 3),
                    gradient: AppGradients.heroDiagonal,
                    boxShadow: AppShadows.glow(AppColors.accent),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Pill('START HERE • LESSON 1', icon: Icons.play_arrow_rounded, small: true),
                        const SizedBox(height: 12),
                        Text(first.title, style: AppText.displayS),
                        Text(first.titleEs, style: AppText.body.copyWith(color: AppColors.accentFill)),
                        const SizedBox(height: 14),
                        const StepPills(active: -1, compact: true),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          key: const Key('start-first-lesson'),
                          label: 'Start',
                          icon: Icons.arrow_forward_rounded,
                          kid: true,
                          onTap: () => _openLesson(context, first),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                for (final l in MockContent.lessons.skip(1).take(3)) ...[
                  Center(child: Container(width: 3, height: 26, color: AppColors.accent.withValues(alpha: 0.25))),
                  Opacity(
                    opacity: 0.6,
                    child: Row(
                      children: [
                        const SizedBox(width: 30),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border, width: 2)),
                          child: Icon(l.icon, color: AppColors.textTertiary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LESSON ${l.number}', style: AppText.overline.copyWith(color: AppColors.textTertiary)),
                              Text('${l.title} • ${l.titleEs}', style: AppText.label.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.lock_outline_rounded, color: AppColors.textTertiary),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------- tablet

class _TabletPath extends ConsumerWidget {
  const _TabletPath();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentLessonProvider);
    final child = ref.watch(activeChildProvider);
    final done = ref.watch(activeProgressProvider).completed.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card), boxShadow: AppShadows.soft),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    color: AppColors.surface,
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Pill('Unit 1: Everyday Explorers', icon: Icons.route_outlined, small: true),
                              const SizedBox(height: 6),
                              Text("${child.nickname}'s Learning Path", style: AppText.title),
                            ],
                          ),
                        ),
                        Pill('$done of 5 completed', icon: Icons.check_circle_outline, small: true, color: AppColors.successTint, textColor: AppColors.success),
                      ],
                    ),
                  ),
                  const Expanded(child: _WindingPath()),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: ListView(
              children: [
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Photo(current.cover, height: 170, radius: 18),
                      const SizedBox(height: 14),
                      Pill('Lección ${current.number} • Español & English', small: true, support: true),
                      const SizedBox(height: 8),
                      Text('${current.title}: ${current.subtitle}', style: AppText.title),
                      const SizedBox(height: 6),
                      const Text('Learn with Maestra Luna through 3 fun, interactive activities!', style: AppText.body),
                      const SizedBox(height: 14),
                      const StepPills(active: 0),
                      const SizedBox(height: 18),
                      PrimaryButton(label: 'Start Lesson', icon: Icons.arrow_forward_rounded, kid: true, onTap: () => _openLesson(context, current)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Row(
                    children: [
                      const Avatar(Img.luna, size: 56),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SpeechBubble('Maestra Luna dice:', sub: '"¡Vamos, ${child.nickname}! Ready to catch and say the colors?"'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
