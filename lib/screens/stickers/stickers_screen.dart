import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/kid_chrome.dart';
import '../../widgets/ui.dart';

class StickersScreen extends ConsumerWidget {
  const StickersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(activeProgressProvider).stickers;
    final latest = owned.isEmpty ? null : MockContent.allStickers.firstWhere((s) => s.id == owned.first);
    final count = owned.length;
    const total = 12;

    return Column(
      children: [
        const KidHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('My Stickers', style: AppText.displayS),
                  Spacer(),
                  Text('¡Mis Pegatinas!', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentFill)),
                ],
              ),
              const SizedBox(height: 12),
              AppCard(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    Row(children: [
                      const Icon(Icons.circle, size: 8, color: AppColors.accentFill),
                      const SizedBox(width: 6),
                      Text('Page 1 • $count of $total stickers collected', style: AppText.caption.copyWith(color: AppColors.textSecondary)),
                      const Spacer(),
                      Text('${(count / total * 100).round()}%', style: AppText.caption),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(value: count / total, minHeight: 8, color: AppColors.accent, backgroundColor: AppColors.accentTint),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (latest != null) _LatestCard(sticker: latest),
              const SizedBox(height: 22),
              const Row(children: [
                Text('Sticker Album', style: AppText.title),
                Spacer(),
                Text('Tap sticker to view', style: AppText.caption),
              ]),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
                children: [
                  for (final s in MockContent.allStickers.take(9))
                    _StickerTile(sticker: s, owned: owned.contains(s.id), isNew: s.id == latest?.id),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.supportTint, borderRadius: BorderRadius.circular(AppRadius.control)),
                child: const Row(
                  children: [
                    Icon(Icons.emoji_events_outlined, color: Color(0xFFC2410C)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Play 1 more game to unlock Lesson 7!', style: AppText.label),
                          Text('¡Juega una vez más para ganar!', style: AppText.caption),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.sticker});
  final Sticker sticker;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppRadius.card + 3), gradient: AppGradients.heroDiagonal),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.card)),
        child: Column(
          children: [
            const Row(children: [
              Pill('New! • ¡Nuevo!', icon: Icons.auto_awesome, small: true, support: true),
              Spacer(),
              Text('Latest Unlocked', style: AppText.caption),
            ]),
            const SizedBox(height: 8),
            _StickerArt(sticker: sticker, size: 130),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sticker.name, style: AppText.title),
                    Text(sticker.nameEs, style: AppText.caption.copyWith(color: AppColors.accentFill)),
                  ],
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Maestra Luna: "${sticker.nameEs}"')),
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('Tap to listen'),
                  style: TextButton.styleFrom(backgroundColor: AppColors.accentTint, foregroundColor: AppColors.accentFill, shape: const StadiumBorder()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StickerTile extends StatelessWidget {
  const _StickerTile({required this.sticker, required this.owned, this.isNew = false});
  final Sticker sticker;
  final bool owned;
  final bool isNew;

  @override
  Widget build(BuildContext context) {
    final locked = !owned;
    return Container(
      decoration: BoxDecoration(
        color: locked ? AppColors.surface.withValues(alpha: 0.6) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.control + 4),
        border: Border.all(color: isNew ? AppColors.accent : AppColors.border, width: isNew ? 2 : 1),
        boxShadow: locked ? null : AppShadows.soft,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (locked)
                  const Icon(Icons.lock_outline_rounded, size: 34, color: AppColors.border)
                else
                  _StickerArt(sticker: sticker, size: 56),
                const SizedBox(height: 6),
                Text(locked ? 'Locked' : sticker.name, style: AppText.label.copyWith(fontSize: 14, color: locked ? AppColors.textTertiary : AppColors.textPrimary)),
                Text(locked ? sticker.name : sticker.nameEs, style: AppText.caption.copyWith(fontSize: 12)),
              ],
            ),
          ),
          if (owned)
            const Positioned(right: 8, top: 8, child: CircleAvatar(radius: 4, backgroundColor: AppColors.success)),
          if (isNew) const Positioned(left: 8, top: 8, child: Pill('New', small: true)),
        ],
      ),
    );
  }
}

/// Flat 2D sticker art: emoji glyph on a soft tinted disc.
class _StickerArt extends StatelessWidget {
  const _StickerArt({required this.sticker, required this.size});
  final Sticker sticker;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isNumber = int.tryParse(sticker.emoji) != null;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentTint),
      child: Text(
        sticker.emoji,
        style: isNumber
            ? TextStyle(fontFamily: AppFonts.display, fontSize: size * 0.62, fontWeight: FontWeight.w700, color: AppColors.accentFill, height: 1)
            : TextStyle(fontSize: size * 0.55, height: 1.1),
      ),
    );
  }
}
