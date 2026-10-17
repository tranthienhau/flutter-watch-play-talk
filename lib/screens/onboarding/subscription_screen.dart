import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

/// Free trial + monthly / annual. Purchase sits behind the parental gate.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  Plan _plan = Plan.annual;

  Future<void> _start() async {
    final ok = await context.push<bool>('/gate');
    if (ok != true || !mounted) return;
    ref.read(accountProvider.notifier).startTrial(_plan);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your 7-day free trial has started. Welcome!')),
    );
    context.go('/profiles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  CircleIconButton(Icons.close_rounded, onTap: () => context.go('/'), semantic: 'Close'),
                  const Spacer(),
                  const Pill('Parent Area', icon: Icons.lock_outline_rounded, small: true),
                ],
              ),
              const SizedBox(height: 14),
              const Photo(Img.paywallHero, height: 190),
              const SizedBox(height: 20),
              const Text('Start your 7-day free trial', textAlign: TextAlign.center, style: AppText.displayS),
              const SizedBox(height: 6),
              const Text(
                'Unlock unlimited bilingual learning adventures for your little one.',
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              const SizedBox(height: 18),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Column(
                  children: [
                    for (final f in const ['Ad-free episodes', 'New lessons every week', 'Spanish and English', 'Up to 4 child profiles'])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            const CircleAvatar(radius: 11, backgroundColor: AppColors.accentTint, child: Icon(Icons.check_rounded, size: 15, color: AppColors.accentFill)),
                            const SizedBox(width: 12),
                            Text(f, style: AppText.body.copyWith(color: AppColors.textPrimary, fontSize: 16)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _PlanCard(
                selected: _plan == Plan.annual,
                title: 'Annual',
                badge: 'Best value',
                sub: '\$5.00 per month',
                price: '\$59.99',
                per: '/yr',
                save: 'Save 37%',
                onTap: () => setState(() => _plan = Plan.annual),
              ),
              const SizedBox(height: 12),
              _PlanCard(
                selected: _plan == Plan.monthly,
                title: 'Monthly',
                sub: '\$7.99 per month',
                price: '\$7.99',
                per: '/mo',
                onTap: () => setState(() => _plan = Plan.monthly),
              ),
              const SizedBox(height: 20),
              PrimaryButton(key: const Key('start-trial'), label: 'Start free trial', onTap: _start),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.accentFill),
                  SizedBox(width: 6),
                  Text('A grown-up check comes next.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accentFill)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Cancel anytime in App Store settings.', textAlign: TextAlign.center, style: AppText.caption),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No previous purchases found on this account.')),
                ),
                child: const Text('Restore purchases', style: TextStyle(color: AppColors.textSecondary, decoration: TextDecoration.underline)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.selected,
    required this.title,
    required this.sub,
    required this.price,
    required this.per,
    required this.onTap,
    this.badge,
    this.save,
  });

  final bool selected;
  final String title, sub, price, per;
  final String? badge, save;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: selected ? AppColors.accent : AppColors.border, width: selected ? 2.5 : 1.5),
        boxShadow: selected ? AppShadows.soft : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.card),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? AppColors.accentFill : Colors.transparent,
                  border: Border.all(color: selected ? AppColors.accentFill : AppColors.border, width: 2),
                ),
                child: selected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(title, style: AppText.label),
                      if (badge != null) ...[const SizedBox(width: 8), Pill(badge!, support: true, small: true)],
                    ]),
                    Text(sub, style: AppText.caption),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text.rich(TextSpan(
                    text: price,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    children: [TextSpan(text: per, style: AppText.caption)],
                  )),
                  if (save != null) Text(save!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
