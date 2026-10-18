import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../theme/tokens.dart';
import '../../widgets/kid_chrome.dart';
import '../../widgets/ui.dart';

class EpisodesScreen extends StatefulWidget {
  const EpisodesScreen({super.key});

  @override
  State<EpisodesScreen> createState() => _EpisodesScreenState();
}

class _EpisodesScreenState extends State<EpisodesScreen> {
  static const _filters = ['All', 'Español', 'English', 'Songs'];
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final featured = MockContent.episodes.first;
    final more = MockContent.episodes.skip(1).where((e) => _filter == 'All' || e.category == _filter).toList();
    return Column(
      children: [
        const KidHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              const Row(
                children: [
                  Text('Episodes', style: AppText.displayS),
                  Spacer(),
                  Pill('No ads, ever', icon: Icons.verified_user_outlined, small: true),
                ],
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final f in _filters)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(f),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                          showCheckmark: false,
                          selectedColor: AppColors.accentFill,
                          backgroundColor: AppColors.surface,
                          side: BorderSide(color: _filter == f ? AppColors.accentFill : AppColors.border),
                          shape: const StadiumBorder(),
                          labelStyle: TextStyle(fontWeight: FontWeight.w600, color: _filter == f ? Colors.white : AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _FeaturedCard(ep: featured),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text('More Episodes', style: AppText.title),
                  const Spacer(),
                  Text('${more.length} available', style: AppText.caption),
                ],
              ),
              const SizedBox(height: 10),
              for (final e in more) ...[
                _EpisodeRow(ep: e, watched: e.number == 39),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.ep});
  final Episode ep;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/episode/${ep.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Photo(ep.image, height: 180, radius: 18),
              const Positioned(left: 10, top: 10, child: Pill('New this week', support: true, small: true)),
              Positioned(
                right: 10,
                bottom: 10,
                child: Pill('${ep.minutes} min', icon: Icons.schedule_rounded, small: true, color: Colors.black54, textColor: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 6, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Episode ${ep.number}: ${ep.title}', style: AppText.title.copyWith(fontSize: 19)),
                const SizedBox(height: 4),
                Text(ep.description, style: AppText.body.copyWith(fontSize: 15)),
                const SizedBox(height: 14),
                PrimaryButton(
                  key: const Key('play-episode'),
                  label: 'Play Episode',
                  leadingIcon: Icons.play_arrow_rounded,
                  onTap: () => context.push('/episode/${ep.id}'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EpisodeRow extends StatelessWidget {
  const _EpisodeRow({required this.ep, this.watched = false});
  final Episode ep;
  final bool watched;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(10),
      onTap: () => context.push('/episode/${ep.id}'),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(ep.image, width: 96, height: 64, fit: BoxFit.cover),
              ),
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                child: Icon(watched ? Icons.check_rounded : Icons.play_arrow_rounded, size: 18, color: AppColors.accentFill),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ep ${ep.number}: ${ep.title}', style: AppText.label),
                Text('${ep.minutes} min • ${ep.languages}', style: AppText.caption),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: watched ? 1 : (ep.number == 41 ? 0.35 : 0),
                    minHeight: 4,
                    color: AppColors.accent,
                    backgroundColor: AppColors.accentTint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          CircleIconButton(watched ? Icons.replay_rounded : Icons.play_arrow_rounded, size: 40, tint: true),
        ],
      ),
    );
  }
}
