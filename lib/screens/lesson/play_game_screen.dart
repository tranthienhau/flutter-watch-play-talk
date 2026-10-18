import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../game/catch_game.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import 'watch_clip_screen.dart';

/// Step 2, Play: the Flame "catch" template loaded with this lesson's
/// approved settings.
class PlayGameScreen extends StatefulWidget {
  const PlayGameScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  State<PlayGameScreen> createState() => _PlayGameScreenState();
}

class _PlayGameScreenState extends State<PlayGameScreen> {
  late final Lesson l = MockContent.lesson(widget.lessonId);
  late final CatchGame game = CatchGame(settings: l.game, autoplay: demoAutoplay, onWin: _win);
  bool _paused = false;

  void _win() {
    if (mounted) context.pushReplacement('/lesson/${l.id}/talk');
  }

  void _togglePause() {
    setState(() => _paused = !_paused);
    _paused ? game.pauseEngine() : game.resumeEngine();
  }

  @override
  Widget build(BuildContext context) {
    final s = l.game;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LessonTopBar(
              lesson: l,
              step: 1,
              trailing: CircleIconButton(_paused ? Icons.play_arrow_rounded : Icons.pause_rounded, onTap: _togglePause, semantic: 'Pause'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    const CircleIconButton(Icons.volume_up_rounded, size: 44, tint: true, semantic: 'Hear the prompt'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.promptEs, style: const TextStyle(fontFamily: AppFonts.display, fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text(s.promptEn, style: AppText.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Pill(s.targetLabel, icon: Icons.circle, color: const Color(0xFFFFE4E4), textColor: AppColors.gameRed),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
              child: ValueListenableBuilder<int>(
                valueListenable: game.score,
                builder: (_, score, _) {
                  final frac = score / s.goal;
                  return Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 24),
                      const SizedBox(width: 6),
                      Text('$score / ${s.goal}', key: const Key('game-score'), style: AppText.label),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(children: [
                            Container(height: 10, color: AppColors.accentTint),
                            FractionallySizedBox(
                              widthFactor: frac.clamp(0, 1),
                              child: Container(height: 10, decoration: const BoxDecoration(gradient: AppGradients.hero)),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 12),
                      for (var i = 0; i < 4; i++)
                        Icon(
                          Icons.star_rounded,
                          size: 20,
                          color: frac >= (i + 1) / 4 ? const Color(0xFFF59E0B) : AppColors.border,
                        ),
                    ],
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEDE6FC), Color(0xFFF7F1FF), Color(0xFFFFF1EA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(child: CustomPaint(painter: _SceneryPainter())),
                    GameWidget(game: game),
                    if (_paused)
                      Container(
                        color: Colors.white.withValues(alpha: 0.7),
                        alignment: Alignment.center,
                        child: PrimaryButton(label: 'Keep playing', leadingIcon: Icons.play_arrow_rounded, kid: true, onTap: _togglePause),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      _Arrow(icon: Icons.arrow_back_rounded, onDown: () => game.steer = -1, onUp: () => game.steer = 0),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.circle, size: 14, color: AppColors.gameRed),
                              SizedBox(width: 10),
                              Text('Mueve la\ncanasta', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.15)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _Arrow(icon: Icons.arrow_forward_rounded, onDown: () => game.steer = 1, onUp: () => game.steer = 0),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Usa las flechas para jugar', style: AppText.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onDown, required this.onUp});
  final IconData icon;
  final VoidCallback onDown, onUp;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => onDown(),
      onPointerUp: (_) => onUp(),
      onPointerCancel: (_) => onUp(),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accent, width: 2.5),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, color: AppColors.accentFill, size: 34),
      ),
    );
  }
}

/// Flat 2D clouds and hills behind the game.
class _SceneryPainter extends CustomPainter {
  const _SceneryPainter();

  @override
  void paint(Canvas c, Size s) {
    final cloud = Paint()..color = Colors.white.withValues(alpha: 0.9);
    void drawCloud(Offset o, double k) {
      c.drawCircle(o, 18 * k, cloud);
      c.drawCircle(o + Offset(20 * k, -8 * k), 22 * k, cloud);
      c.drawCircle(o + Offset(44 * k, 0), 17 * k, cloud);
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(o.dx - 10 * k, o.dy, 70 * k, 18 * k), Radius.circular(9 * k)), cloud);
    }

    drawCloud(Offset(s.width * 0.08, s.height * 0.1), 1);
    drawCloud(Offset(s.width * 0.68, s.height * 0.18), 0.8);

    final back = Path()
      ..moveTo(0, s.height * 0.8)
      ..quadraticBezierTo(s.width * 0.3, s.height * 0.68, s.width * 0.6, s.height * 0.78)
      ..quadraticBezierTo(s.width * 0.85, s.height * 0.84, s.width, s.height * 0.74)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    c.drawPath(back, Paint()..color = const Color(0xFFD9CCF7));
    final front = Path()
      ..moveTo(0, s.height * 0.88)
      ..quadraticBezierTo(s.width * 0.45, s.height * 0.8, s.width, s.height * 0.9)
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..close();
    c.drawPath(front, Paint()..color = const Color(0xFFBFE8C9));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
