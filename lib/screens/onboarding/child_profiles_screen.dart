import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class ChildProfilesScreen extends ConsumerWidget {
  const ChildProfilesScreen({super.key});

  static const _photos = {'mia': Img.mia, 'leo': Img.leo, 'sofia': Img.sofia};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(Img.appIcon, width: 40, height: 40),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Watch Play Talk', style: AppText.label),
                      Text('Bilingual Learning', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await context.push<bool>('/gate');
                      if (ok == true && context.mounted) context.push('/parent');
                    },
                    icon: const Icon(Icons.lock_outline_rounded, size: 16),
                    label: const Text('Parents'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 44),
              const Text('Who is learning today?', textAlign: TextAlign.center, style: AppText.displayS),
              const SizedBox(height: 8),
              const Text('Tap your picture to start playing!', style: AppText.body),
              const SizedBox(height: 28),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.86,
                children: [
                  for (final c in MockContent.children)
                    _ProfileTile(
                      child: c,
                      photo: _photos[c.id]!,
                      onTap: () {
                        ref.read(activeChildIdProvider.notifier).select(c.id);
                        context.go('/learn');
                      },
                    ),
                  const _AddTile(),
                ],
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.successTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user_outlined, size: 16, color: AppColors.success),
                    SizedBox(width: 6),
                    Text('Ad-free & kid-safe learning space', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.success)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({required this.child, required this.photo, required this.onTap});
  final ChildProfile child;
  final String photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        key: Key('profile-${child.id}'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Avatar(photo, size: 92, ring: AppColors.accentTint, ringWidth: 4),
          const SizedBox(height: 10),
          Text(child.nickname, style: const TextStyle(fontFamily: AppFonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Pill('Age ${child.age}', small: true),
              const SizedBox(width: 4),
              Pill(child.language.label, small: true, support: child.language == LessonLanguage.spanish),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  const _AddTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 2, strokeAlign: BorderSide.strokeAlignInside),
        color: AppColors.surface.withValues(alpha: 0.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A grown-up adds new profiles in the Parent area.')),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(radius: 26, backgroundColor: AppColors.accentTint, child: Icon(Icons.add_rounded, color: AppColors.accentFill, size: 30)),
            SizedBox(height: 12),
            Text('+ Add child', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accentFill)),
            Text('New profile', style: AppText.caption),
          ],
        ),
      ),
    );
  }
}
