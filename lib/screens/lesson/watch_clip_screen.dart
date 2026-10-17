import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

/// Step 1, Watch. In production this plays the lesson's start..end window of
/// the episode HLS stream. Here a still with a slow Ken Burns move stands in
/// for the clip, and the vocabulary cards follow the clip timeline.
class WatchClipScreen extends StatefulWidget {
  const WatchClipScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  State<WatchClipScreen> createState() => _WatchClipScreenState();
}

class _WatchClipScreenState extends State<WatchClipScreen> with SingleTickerProviderStateMixin {
  late final Lesson l = MockContent.lesson(widget.lessonId);
  static const _clipSec = 125;

  /// Demo clock: one real second = 10 clip seconds (30 in recorded demos).
  static const _rate = demoAutoplay ? 30 : 10;
  double _pos = 0;
  double _speed = 1;
  bool _playing = true;
  Timer? _t;
  late final AnimationController _kb =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_playing || _pos >= _clipSec) return;
      setState(() => _pos = (_pos + _rate * 0.1 * _speed).clamp(0, _clipSec.toDouble()));
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    _kb.dispose();
    super.dispose();
  }

  String _fmt(double s) => '${s ~/ 60}:${(s % 60).toInt().toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final done = _pos >= _clipSec;
    final vocabIdx = l.vocab.isEmpty ? 0 : ((_pos / _clipSec) * l.vocab.length).floor().clamp(0, l.vocab.length - 1);
    final word = l.vocab.isEmpty ? null : l.vocab[vocabIdx];
    final rep = ((_pos / _clipSec) * l.vocab.length * 3).floor() % 3 + 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LessonTopBar(lesson: l, step: 0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: AspectRatio(
                      aspectRatio: 4 / 3.4,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          AnimatedBuilder(
                            animation: _kb,
                            builder: (_, child) => Transform.scale(scale: 1.05 + _kb.value * 0.08, child: child),
                            child: Image.asset(l.clip, fit: BoxFit.cover),
                          ),
                          const Positioned(
                            left: 12,
                            top: 12,
                            child: Pill('Maestra Luna', icon: Icons.verified_rounded, small: true, color: Colors.white),
                          ),
                          const Positioned(
                            right: 12,
                            top: 12,
                            child: Pill('Español', icon: Icons.translate_rounded, small: true, support: true),
                          ),
                          if (!_playing)
                            Container(
                              color: Colors.black26,
                              child: const Icon(Icons.play_circle_fill_rounded, size: 84, color: Colors.white),
                            ),
                          Positioned(
                            right: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                              child: const Text('HD Clip', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (word != null)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: AppCard(
                        key: ValueKey(word.word),
                        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(word.word, style: TextStyle(fontFamily: AppFonts.display, fontSize: 32, fontWeight: FontWeight.w700, color: word.color)),
                                const SizedBox(width: 10),
                                Text(word.translation, style: AppText.title.copyWith(fontSize: 20)),
                                const Spacer(),
                                const CircleIconButton(Icons.volume_up_outlined, size: 40, tint: true),
                              ],
                            ),
                            Text('(${word.phonetic})', style: AppText.caption),
                            const SizedBox(height: 6),
                            const Row(children: [
                              Icon(Icons.record_voice_over_outlined, size: 16, color: AppColors.textTertiary),
                              SizedBox(width: 6),
                              Text('Listen carefully and say it aloud!', style: AppText.caption),
                            ]),
                            const Divider(height: 22, color: AppColors.border),
                            Row(children: [
                              const Icon(Icons.auto_awesome, size: 16, color: AppColors.accent),
                              const SizedBox(width: 6),
                              Text('Vocab: ${l.titleEs}', style: AppText.caption.copyWith(color: AppColors.textSecondary)),
                              const Spacer(),
                              Text('Repetition $rep of 3', style: AppText.caption),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 6,
                            activeTrackColor: AppColors.accent,
                            inactiveTrackColor: AppColors.accentTint,
                            thumbColor: AppColors.support,
                            overlayShape: SliderComponentShape.noOverlay,
                          ),
                          child: Slider(
                            value: _pos,
                            max: _clipSec.toDouble(),
                            onChanged: (v) => setState(() => _pos = v),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          Text(_fmt(_pos), style: AppText.caption),
                          const Spacer(),
                          Text(_fmt(_clipSec.toDouble()), style: AppText.caption),
                        ]),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            CircleIconButton(Icons.replay_10_rounded, size: 52, onTap: () => setState(() => _pos = (_pos - 10).clamp(0, _clipSec.toDouble()))),
                            GestureDetector(
                              onTap: () => setState(() => _playing = !_playing),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(color: AppColors.accentFill, shape: BoxShape.circle, boxShadow: AppShadows.glow(AppColors.accent)),
                                child: Icon(_playing && !done ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 38),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _speed = _speed == 1 ? 0.75 : 1),
                              child: Container(
                                width: 52,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                                child: Text('${_speed}x', style: AppText.label.copyWith(fontSize: 14)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                children: [
                  PrimaryButton(
                    key: const Key('next-play'),
                    label: 'Next: Play',
                    icon: Icons.arrow_forward_rounded,
                    kid: true,
                    onTap: done ? () => context.pushReplacement('/lesson/${l.id}/play') : null,
                  ),
                  if (!done)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Finish watching to unlock Play 🎮', style: AppText.caption),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared top bar for lesson steps: close, lesson chip, sound, step pills.
class LessonTopBar extends StatelessWidget {
  const LessonTopBar({super.key, required this.lesson, required this.step, this.trailing});
  final Lesson lesson;
  final int step;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Row(
            children: [
              CircleIconButton(Icons.close_rounded, onTap: () => context.go('/learn'), semantic: 'Close lesson'),
              const Spacer(),
              Pill('${lesson.title} • ${lesson.titleEs}', icon: lesson.icon, small: true),
              const Spacer(),
              trailing ?? const CircleIconButton(Icons.volume_up_outlined, tint: true),
            ],
          ),
          const SizedBox(height: 12),
          StepPills(active: step),
        ],
      ),
    );
  }
}
