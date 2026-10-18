import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/kid_chrome.dart';
import '../../widgets/ui.dart';

/// Full episode player with lesson chapters. Production plays adaptive HLS
/// from the video host; lesson clips are start/end windows on the same
/// stream. Here a still with a simulated clock stands in.
class EpisodePlayerScreen extends StatefulWidget {
  const EpisodePlayerScreen({super.key, required this.episodeId});
  final String episodeId;

  @override
  State<EpisodePlayerScreen> createState() => _EpisodePlayerScreenState();
}

class _EpisodePlayerScreenState extends State<EpisodePlayerScreen> {
  late final Episode ep = MockContent.episodes.firstWhere((e) => e.id == widget.episodeId);
  late double _pos = ep.chapters.length > 1 ? ep.chapters[1].startSec + 608.0 : 0;
  bool _playing = true;
  bool _english = false;
  double _speed = 1;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_playing) setState(() => _pos = (_pos + 0.25 * _speed).clamp(0, ep.minutes * 60.0));
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  String _fmt(num s) => '${s ~/ 60}:${(s % 60).toInt().toString().padLeft(2, '0')}';

  int get _chapter {
    var idx = 0;
    for (var i = 0; i < ep.chapters.length; i++) {
      if (_pos >= ep.chapters[i].startSec) idx = i;
    }
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    final total = ep.minutes * 60.0;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  CircleIconButton(Icons.close_rounded, key: const Key('close-player'), onTap: () => context.pop(), semantic: 'Close player'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _english = !_english),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.pill), border: Border.all(color: AppColors.border)),
                      child: Row(children: [
                        const Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(Icons.translate_rounded, size: 18, color: AppColors.accentFill)),
                        _seg('ES', !_english),
                        _seg('EN', _english),
                      ]),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleIconButton(Icons.lock_outline_rounded, semantic: 'Parent area', onTap: () => openParentArea(context)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.card),
                    child: AspectRatio(
                      aspectRatio: 16 / 10,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(Img.lunaSinging, fit: BoxFit.cover),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.transparent, Colors.black54], begin: Alignment.center, end: Alignment.bottomCenter),
                            ),
                          ),
                          const Positioned(left: 12, top: 12, child: Pill('Maestra Luna', icon: Icons.circle, small: true, color: Colors.white, textColor: AppColors.success)),
                          const Positioned(right: 12, top: 12, child: Pill('1080p', icon: Icons.closed_caption_outlined, small: true, color: Colors.black54, textColor: Colors.white)),
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: 10,
                            child: Column(
                              children: [
                                Text(
                                  _english ? '"What color is the apple? Red!"' : '"¿De qué color es la manzana? ¡Rojo!"',
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, shadows: [Shadow(blurRadius: 6)]),
                                ),
                                const SizedBox(height: 8),
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    activeTrackColor: AppColors.support,
                                    inactiveTrackColor: Colors.white38,
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                    overlayShape: SliderComponentShape.noOverlay,
                                  ),
                                  child: Slider(value: _pos, max: total, onChanged: (v) => setState(() => _pos = v)),
                                ),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Text(_fmt(_pos), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  const Spacer(),
                                  Text(_fmt(total), style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(icon: const Icon(Icons.replay_10_rounded, size: 28), color: AppColors.textSecondary, onPressed: () => setState(() => _pos = (_pos - 10).clamp(0, total))),
                        TextButton(
                          onPressed: () => setState(() => _speed = _speed == 1 ? 0.75 : 1),
                          child: Text('${_speed}x', style: AppText.label.copyWith(color: AppColors.textSecondary)),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _playing = !_playing),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(color: AppColors.accentFill, shape: BoxShape.circle, boxShadow: AppShadows.glow(AppColors.accent)),
                            child: Icon(_playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 34),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.forward_10_rounded, size: 28), color: AppColors.textSecondary, onPressed: () => setState(() => _pos = (_pos + 10).clamp(0, total))),
                        IconButton(icon: const Icon(Icons.fullscreen_rounded, size: 28), color: AppColors.textSecondary, onPressed: () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text('Episode ${ep.number}: ${ep.title}', style: AppText.title)),
                      const Icon(Icons.star_border_rounded, color: AppColors.accentFill),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(ep.description, style: AppText.body.copyWith(fontSize: 15)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    const Pill('Spanish + English', icon: Icons.record_voice_over_outlined, small: true),
                    const Pill('Ages 2-6', icon: Icons.child_care_rounded, small: true, support: true),
                    Pill('${ep.minutes} min', icon: Icons.schedule_rounded, small: true, color: AppColors.surface, textColor: AppColors.textSecondary),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('Lessons in this episode', style: AppText.label),
                      const SizedBox(width: 8),
                      Pill('${ep.chapters.length} chapters', small: true),
                      const Spacer(),
                      const Text('Autoplay ON', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentFill)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (var i = 0; i < ep.chapters.length; i++) ...[
                    _chapterRow(i),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seg(String label, bool on) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: on ? AppColors.accentFill : Colors.transparent, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: on ? Colors.white : AppColors.textTertiary)),
      );

  Widget _chapterRow(int i) {
    final c = ep.chapters[i];
    final cur = _chapter;
    final done = i < cur, now = i == cur;
    final thumbs = [Img.singingCircle, Img.lunaApple, Img.chapterCount, Img.chapterAnimals];
    return Container(
      decoration: BoxDecoration(
        color: now ? AppColors.accentTint : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control + 2),
        border: Border.all(color: now ? AppColors.accent : AppColors.border, width: now ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.control + 2),
        onTap: () => setState(() => _pos = c.startSec.toDouble()),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(thumbs[i % thumbs.length], width: 64, height: 46, fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${done ? 'COMPLETED' : now ? 'NOW PLAYING' : 'NEXT UP'} • ${_fmt(c.startSec)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: done ? AppColors.success : (now ? AppColors.accentFill : AppColors.textTertiary),
                      ),
                    ),
                    Text('${i + 1}. ${c.title}', style: AppText.label.copyWith(fontSize: 15)),
                  ],
                ),
              ),
              Icon(
                done ? Icons.replay_rounded : (now ? Icons.equalizer_rounded : Icons.play_arrow_rounded),
                color: now ? AppColors.accentFill : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
