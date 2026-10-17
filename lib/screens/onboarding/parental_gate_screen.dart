import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

/// Grown-up check before purchases, settings, links and mic permission
/// (Apple Kids Category + Google Play Families). Pops `true` on success.
class ParentalGateScreen extends StatefulWidget {
  const ParentalGateScreen({super.key});

  @override
  State<ParentalGateScreen> createState() => _ParentalGateScreenState();
}

class _ParentalGateScreenState extends State<ParentalGateScreen> with SingleTickerProviderStateMixin {
  static const _ones = ['', 'one', 'two', 'three', 'four', 'five', 'six', 'seven', 'eight', 'nine'];
  static const _tens = ['', '', 'twenty', 'thirty', 'forty', 'fifty', 'sixty', 'seventy', 'eighty', 'ninety'];

  late final int _target = demoAutoplay ? 47 : 21 + Random().nextInt(78);
  String _typed = '';
  late final AnimationController _shake =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 400));

  String get _words {
    final t = _target ~/ 10, o = _target % 10;
    return o == 0 ? _tens[t] : '${_tens[t]}-${_ones[o]}';
  }

  void _press(String k) {
    setState(() {
      if (k == 'del') {
        if (_typed.isNotEmpty) _typed = _typed.substring(0, _typed.length - 1);
      } else if (k == 'clear') {
        _typed = '';
      } else if (_typed.length < 2) {
        _typed += k;
      }
    });
    if (_typed.length == 2) {
      if (int.parse(_typed) == _target) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted) context.pop(true);
        });
      } else {
        _shake.forward(from: 0).then((_) => setState(() => _typed = ''));
      }
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleIconButton(Icons.close_rounded, onTap: () => context.pop(false), semantic: 'Close'),
                  const Spacer(),
                  const Pill('Adult verification', small: true),
                  const Spacer(),
                  const SizedBox(width: 44),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(color: AppColors.accentTint, shape: BoxShape.circle),
                child: const Icon(Icons.lock_outline_rounded, color: AppColors.accentFill, size: 34),
              ),
              const SizedBox(height: 18),
              const Text('Grown-ups only', style: AppText.title),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  text: 'Type the number: ',
                  style: AppText.body,
                  children: [
                    TextSpan(
                      text: _words,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.accent,
                        decorationThickness: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              AnimatedBuilder(
                animation: _shake,
                builder: (_, child) => Transform.translate(
                  offset: Offset(sin(_shake.value * pi * 6) * 10 * (1 - _shake.value), 0),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [for (var i = 0; i < 2; i++) _box(i)],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'This keeps purchases and settings away from little hands.',
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
              const Spacer(),
              _keypad(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(int i) {
    final filled = i < _typed.length;
    final focus = i == _typed.length;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 64,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        border: Border.all(color: focus ? AppColors.accent : AppColors.border, width: focus ? 2.5 : 1.5),
        boxShadow: AppShadows.soft,
      ),
      child: filled
          ? Text(_typed[i], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: AppColors.textPrimary))
          : focus
              ? Container(width: 10, height: 10, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle))
              : null,
    );
  }

  Widget _keypad() {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['clear', '0', 'del'],
    ];
    return Column(
      children: [
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                for (final k in r)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _key(k),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _key(String k) {
    final plain = k == 'clear';
    return SizedBox(
      height: 60,
      child: Material(
        color: plain ? Colors.transparent : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control),
        elevation: 0,
        child: InkWell(
          key: Key('key-$k'),
          borderRadius: BorderRadius.circular(AppRadius.control),
          onTap: () => _press(k),
          child: Container(
            alignment: Alignment.center,
            decoration: plain
                ? null
                : BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.control), boxShadow: AppShadows.soft),
            child: k == 'del'
                ? const Icon(Icons.backspace_outlined, color: AppColors.textSecondary)
                : Text(
                    k == 'clear' ? 'Clear' : k,
                    style: TextStyle(
                      fontSize: plain ? 15 : 24,
                      fontWeight: plain ? FontWeight.w500 : FontWeight.w600,
                      color: plain ? AppColors.textTertiary : AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
