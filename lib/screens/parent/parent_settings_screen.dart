import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../models/models.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class ParentSettingsScreen extends ConsumerWidget {
  const ParentSettingsScreen({super.key});

  void _toast(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final account = ref.watch(accountProvider);
    final n = ref.read(settingsProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(children: [
                CircleIconButton(Icons.arrow_back_rounded, key: const Key('settings-back'), onTap: () => context.pop(), semantic: 'Back'),
                const Spacer(),
                const Text('Settings', style: AppText.title),
                const Spacer(),
                const SizedBox(width: 44, child: Icon(Icons.lock_outline_rounded, color: AppColors.accentFill)),
              ]),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                children: [
                  const SectionLabel('Learning'),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Lesson language', style: AppText.label),
                        const Text('Primary instruction language for audio & prompts', style: AppText.caption),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadius.pill)),
                          child: Row(children: [
                            for (final l in LessonLanguage.values)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => n.setLanguage(l),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: s.language == l ? AppColors.accentFill : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppRadius.pill),
                                    ),
                                    child: Text(l.label, style: TextStyle(fontWeight: FontWeight.w600, color: s.language == l ? Colors.white : AppColors.textSecondary)),
                                  ),
                                ),
                              ),
                          ]),
                        ),
                        const Divider(height: 30, color: AppColors.border),
                        InkWell(
                          onTap: () => n.setLimit(s.dailyLimitMin >= 60 ? 15 : s.dailyLimitMin + 15),
                          child: Row(children: [
                            const Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Daily time limit', style: AppText.label),
                                Text('App locks gently when time is reached', style: AppText.caption),
                              ]),
                            ),
                            Pill('${s.dailyLimitMin} min', small: true),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SectionLabel('Talk & Microphone'),
                  AppCard(
                    child: Column(
                      children: [
                        Row(children: [
                          const CircleAvatar(backgroundColor: AppColors.accentTint, child: Icon(Icons.mic_none_rounded, color: AppColors.accentFill)),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Use microphone for Talk', style: AppText.label),
                              Text('Allows playful verbal mini-games', style: AppText.caption),
                            ]),
                          ),
                          Switch(
                            key: const Key('mic-switch'),
                            value: s.micEnabled,
                            onChanged: (on) => on ? context.push('/parent/mic') : n.setMic(false),
                          ),
                        ]),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.successTint, borderRadius: BorderRadius.circular(AppRadius.input)),
                          child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Icon(Icons.verified_user_outlined, size: 18, color: AppColors.success),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('Speech is checked on this device and never saved or sent.', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                SizedBox(height: 2),
                                Text('Kid voice data never leaves your phone. Protected by on-device recognition models.', style: AppText.caption),
                              ]),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  const SectionLabel('Account'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _row(
                        title: 'Subscription: ${account.plan == Plan.monthly ? 'Monthly' : 'Annual'}',
                        sub: account.trialEndsOn != null ? 'Free trial • ends ${_d(account.trialEndsOn!)}' : 'Renews Nov 12, 2026',
                        trailing: const Pill('Active', icon: Icons.circle, small: true, color: AppColors.successTint, textColor: AppColors.success),
                        onTap: () => _toast(context, 'Opens App Store subscription management.'),
                      ),
                      _row(title: 'Restore purchases', icon: Icons.sync_rounded, onTap: () => _toast(context, 'Purchases restored. Family Plan is active.')),
                      _row(
                        title: 'Manage children',
                        sub: '${MockContent.children.length} active learner profiles',
                        onTap: () => _toast(context, 'Up to 4 profiles: nickname, age band and avatar only.'),
                        last: true,
                      ),
                    ]),
                  ),
                  const SectionLabel('Privacy & Security'),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(children: [
                      _row(title: 'Privacy policy', icon: Icons.open_in_new_rounded, onTap: () => _toast(context, 'Opens the privacy notice for parents.')),
                      _row(title: 'Download my data', leading: Icons.download_rounded, onTap: () => _toast(context, 'Export ready: profiles and lesson events (no audio, ever).')),
                      _row(
                        title: 'Delete account',
                        leading: Icons.delete_outline_rounded,
                        danger: true,
                        last: true,
                        onTap: () => showDialog(
                          context: context,
                          builder: (d) => AlertDialog(
                            title: const Text('Delete account?'),
                            content: const Text('This removes the parent account, every child profile and all progress within 30 days, including backups.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(d);
                                  _toast(context, 'Deletion scheduled. You will get an email confirmation.');
                                },
                                child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 22),
                  const Center(child: Text('Watch Play Talk v1.0.0 (Parental verification enabled)', style: AppText.caption)),
                  const Center(child: Text('COPPA • Apple Kids • Google Play Families', style: AppText.caption)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _d(DateTime d) => '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.day}';

  Widget _row({
    required String title,
    String? sub,
    Widget? trailing,
    IconData? icon,
    IconData? leading,
    bool danger = false,
    bool last = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: AppColors.border))),
        child: Row(children: [
          if (leading != null) ...[Icon(leading, color: danger ? AppColors.danger : AppColors.textSecondary, size: 22), const SizedBox(width: 12)],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: AppText.label.copyWith(color: danger ? AppColors.danger : AppColors.textPrimary)),
              if (sub != null) Text(sub, style: AppText.caption),
            ]),
          ),
          ?trailing,
          Icon(icon ?? Icons.chevron_right_rounded, color: AppColors.textTertiary, size: icon != null ? 20 : 24),
        ]),
      ),
    );
  }
}
