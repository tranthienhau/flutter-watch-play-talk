import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

/// Parental consent before the microphone is used. Shown behind the gate,
/// before the OS permission prompt. Talk works with tap answers when off.
class MicConsentScreen extends ConsumerWidget {
  const MicConsentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const points = [
      (Icons.chat_bubble_outline_rounded, 'Your child answers out loud in lessons', 'Builds confidence speaking real words with Maestra Luna'),
      (Icons.security_rounded, 'Speech is recognized on this device only', 'Powered by on-device recognition models'),
      (Icons.cloud_off_rounded, 'No audio is ever recorded, saved or sent', '100% private to your living room'),
      (Icons.toggle_on_outlined, 'You can turn it off any time', 'Easily toggled in Parent Settings whenever you wish'),
    ];
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Row(children: [
                const Pill('Parent area', icon: Icons.lock_outline_rounded, small: true),
                const Spacer(),
                CircleIconButton(Icons.close_rounded, onTap: () => context.pop(), semantic: 'Close'),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                children: [
                  Stack(children: [
                    const Photo(Img.micConsent, height: 210),
                    const Positioned(left: 12, bottom: 12, child: Pill('Watch • Play • Talk', icon: Icons.mic_rounded, small: true, color: Colors.white)),
                  ]),
                  const SizedBox(height: 18),
                  const Text('Turn on Talk?', textAlign: TextAlign.center, style: AppText.displayS),
                  const SizedBox(height: 6),
                  const Text('Practice spoken Spanish words together with playful voice games.', textAlign: TextAlign.center, style: AppText.body),
                  const SizedBox(height: 18),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(children: [
                      for (final p in points)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            CircleAvatar(radius: 18, backgroundColor: AppColors.accentTint, child: Icon(p.$1, size: 18, color: AppColors.accentFill)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(p.$2, style: AppText.label.copyWith(fontSize: 15)),
                                Text(p.$3, style: AppText.caption),
                              ]),
                            ),
                          ]),
                        ),
                    ]),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(children: [
                PrimaryButton(
                  key: const Key('allow-mic'),
                  label: 'Allow microphone',
                  leadingIcon: Icons.mic_rounded,
                  onTap: () {
                    ref.read(settingsProvider.notifier).setMic(true);
                    context.pop();
                  },
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  label: 'Use tap answers instead',
                  onTap: () {
                    ref.read(settingsProvider.notifier).setMic(false);
                    context.pop();
                  },
                ),
                const SizedBox(height: 10),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.verified_user_outlined, size: 15, color: AppColors.success),
                  SizedBox(width: 6),
                  Text('You are in control. Built for COPPA.', style: AppText.caption),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
