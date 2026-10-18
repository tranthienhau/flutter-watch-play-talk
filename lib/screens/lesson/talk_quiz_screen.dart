import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';
import 'watch_clip_screen.dart';

enum _Phase { ask, listening, praise, retry }

/// Step 3, Talk. A fixed flow (question, listen, check, praise or gentle
/// correction) that only plays pre-approved teacher lines. The recognizer
/// is simulated behind the mic tap; [SpeechCheck] is the real matcher.
class TalkQuizScreen extends ConsumerStatefulWidget {
  const TalkQuizScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<TalkQuizScreen> createState() => _TalkQuizScreenState();
}

class _TalkQuizScreenState extends ConsumerState<TalkQuizScreen> with SingleTickerProviderStateMixin {
  late final Lesson l = MockContent.lesson(widget.lessonId);
  int _q = 0;
  int _attempt = 0;
  _Phase _phase = _Phase.ask;
  String? _heard;
  TalkResult? _last;
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);

  TalkQuestion get q => l.talk[_q];

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    setState(() => _phase = _Phase.listening);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final nBest = q.simulatedHeard.isEmpty ? <String>[] : q.simulatedHeard[_attempt.clamp(0, q.simulatedHeard.length - 1)];
    final result = ref.read(speechCheckProvider).check(nBest, q.accepted);
    _heard = nBest.isEmpty ? null : nBest.first;
    _resolve(result);
  }

  void _tap(String option) {
    final right = option.toLowerCase() == q.answer.toLowerCase();
    _heard = null;
    _resolve(right ? TalkResult.tap : TalkResult.none);
  }

  void _resolve(TalkResult r) {
    final childId = ref.read(activeChildIdProvider);
    ref.read(progressProvider.notifier).recordTalk(childId, q.answer, r);
    _last = r;
    if (r == TalkResult.none) {
      _attempt++;
      setState(() => _phase = _Phase.retry);
    } else {
      setState(() => _phase = _Phase.praise);
      Future.delayed(const Duration(milliseconds: 1400), _next);
    }
  }

  void _next() {
    if (!mounted) return;
    if (_q + 1 >= l.talk.length) {
      final childId = ref.read(activeChildIdProvider);
      ref.read(progressProvider.notifier).completeLesson(childId, l, 3);
      context.pushReplacement('/lesson/${l.id}/done');
      return;
    }
    setState(() {
      _q++;
      _attempt = 0;
      _phase = _Phase.ask;
      _heard = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mic = ref.watch(settingsProvider).micEnabled;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LessonTopBar(lesson: l, step: 2),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _phase == _Phase.retry ? _retryView(mic) : _askView(mic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------- ask

  Widget _askView(bool mic) {
    final child = ref.watch(activeChildProvider);
    return ListView(
      key: ValueKey('ask-$_q'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        Row(
          children: [
            Text('Question ${_q + 1} of ${l.talk.length}', style: AppText.caption),
            const Spacer(),
            for (var i = 0; i < l.talk.length; i++)
              Container(
                margin: const EdgeInsets.only(left: 5),
                width: i == _q ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i <= _q ? AppColors.accentFill : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Avatar(Img.luna, size: 56, ring: AppColors.supportTint),
            const SizedBox(width: 10),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.prompt, style: const TextStyle(fontFamily: AppFonts.display, fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          Text(q.promptEn, style: AppText.caption),
                        ],
                      ),
                    ),
                    const CircleIconButton(Icons.volume_up_outlined, size: 38, tint: true),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _targetArt(96),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Pill('Target Word', support: true, small: true),
                  const SizedBox(height: 6),
                  Text(q.targetWord, style: AppText.title),
                  Text(q.targetEn, style: AppText.caption),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (_phase == _Phase.praise) _praise(child.nickname) else if (mic) _micBlock(),
        const SizedBox(height: 14),
        Center(child: Text(mic ? 'Or tap your answer:' : 'Tap your answer:', style: AppText.caption)),
        const SizedBox(height: 10),
        Row(
          children: [
            for (final o in q.options)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _AnswerButton(label: o.$1, dot: o.$2, onTap: _phase == _Phase.ask ? () => _tap(o.$1) : null),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _targetArt(double size) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: q.image != null
          ? Image.asset(q.image!, width: size, height: size, fit: BoxFit.cover)
          : Container(
              width: size,
              height: size,
              color: AppColors.accentTint,
              alignment: Alignment.center,
              child: Text(q.emoji ?? '', style: TextStyle(fontSize: size * 0.5)),
            ),
    );
  }

  Widget _micBlock() {
    final listening = _phase == _Phase.listening;
    return Column(
      children: [
        GestureDetector(
          key: const Key('mic-button'),
          onTap: _phase == _Phase.ask ? _listen : null,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, _) {
              final t = listening ? _pulse.value : 0.0;
              return Container(
                width: 190,
                height: 190,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.08 + t * 0.1)),
                child: Container(
                  width: 150 + t * 10,
                  height: 150 + t * 10,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accent.withValues(alpha: 0.14)),
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentFill,
                      boxShadow: AppShadows.glow(AppColors.accent),
                    ),
                    child: const Icon(Icons.mic_rounded, color: Colors.white, size: 54),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Pill(listening ? 'Listening...' : 'Tap to talk', icon: Icons.circle, small: true),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'Say ',
            style: AppText.title.copyWith(fontSize: 20),
            children: [
              TextSpan(
                text: '"${q.answer}"',
                style: const TextStyle(color: AppColors.gameRed, decoration: TextDecoration.underline, decorationColor: AppColors.gameRed),
              ),
              TextSpan(text: '! • ¡Di ${q.answer}!'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _praise(String name) {
    final close = _last == TalkResult.close;
    return Container(
      key: const Key('talk-praise'),
      height: 250,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.successTint, boxShadow: AppShadows.glow(AppColors.success)),
            child: const Icon(Icons.star_rounded, size: 72, color: Color(0xFFF59E0B)),
          ),
          const SizedBox(height: 14),
          Text('¡Muy bien, $name!', style: AppText.displayS),
          Text('${q.answer} • ${q.answerEn}', style: AppText.body),
          if (_heard != null) ...[
            const SizedBox(height: 6),
            Text(
              'Heard "$_heard" • ${close ? 'close enough' : 'match'} • checked on this device',
              style: AppText.caption.copyWith(fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------ retry

  Widget _retryView(bool mic) {
    final child = ref.watch(activeChildProvider);
    final out = _attempt >= 2;
    return ListView(
      key: ValueKey('retry-$_q-$_attempt'),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      children: [
        Center(child: Text('Try ${_attempt.clamp(1, 2)} of 2', style: AppText.caption)),
        const SizedBox(height: 16),
        Center(
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppGradients.heroDiagonal),
            child: const Avatar(Img.luna, size: 120, ringWidth: 4),
          ),
        ),
        const SizedBox(height: 10),
        const Center(child: Pill('👋 ¡Casi! Almost there!', support: true)),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            children: [
              const Pill('Great try! • ¡Buen intento!', icon: Icons.favorite_border_rounded, small: true, color: AppColors.supportTint, textColor: Color(0xFFC2410C)),
              const SizedBox(height: 14),
              const Text("Let's say it together:", style: AppText.body),
              const SizedBox(height: 4),
              Text(q.answer.toUpperCase(), style: const TextStyle(fontFamily: AppFonts.display, fontSize: 52, fontWeight: FontWeight.w700, color: AppColors.accentFill, letterSpacing: 2)),
              Text('(${q.phonetic})  "${q.answerEn}"', style: AppText.caption),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(color: AppColors.accentTint, borderRadius: BorderRadius.circular(AppRadius.control)),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.volume_up_rounded, color: AppColors.accentFill),
                          SizedBox(width: 8),
                          Text('Hear\nLuna', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.accentFill, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 64,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.control)),
                      child: Row(
                        children: [
                          _targetArt(52),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q.targetWord, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(q.targetEn, style: AppText.caption.copyWith(fontSize: 12), maxLines: 1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (!out && mic)
          PrimaryButton(key: const Key('say-again'), label: 'Say it again', leadingIcon: Icons.mic_rounded, kid: true, onTap: _listen),
        if (!out && !mic)
          PrimaryButton(label: 'Try again', kid: true, onTap: () => setState(() => _phase = _Phase.ask)),
        const SizedBox(height: 12),
        SecondaryButton(key: const Key('keep-going'), label: 'Keep going', icon: Icons.arrow_forward_rounded, kid: true, onTap: _next),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text('Every try earns a star! Take your time, ${child.nickname}!', style: AppText.caption),
          ],
        ),
      ],
    );
  }
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({required this.label, required this.dot, this.onTap});
  final String label;
  final Color dot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.control),
        side: const BorderSide(color: AppColors.border, width: 1.5),
      ),
      child: InkWell(
        key: Key('answer-${label.toLowerCase()}'),
        borderRadius: BorderRadius.circular(AppRadius.control),
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(radius: 8, backgroundColor: dot),
              const SizedBox(width: 8),
              Flexible(child: Text(label, style: AppText.label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}
