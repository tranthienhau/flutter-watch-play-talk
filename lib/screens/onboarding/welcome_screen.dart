import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_content.dart';
import '../../state/providers.dart';
import '../../theme/tokens.dart';
import '../../widgets/ui.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  void _signIn(BuildContext context, WidgetRef ref) {
    ref.read(accountProvider.notifier).signIn();
    context.go('/subscribe');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.soft,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(Img.appIcon, fit: BoxFit.cover),
              ),
              const SizedBox(height: 10),
              const Text('Watch Play Talk', style: TextStyle(fontFamily: AppFonts.display, fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 18),
              const Photo(Img.welcomeHero, height: 250),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Pill('Spanish + English', small: true),
                  SizedBox(width: 8),
                  Pill('Ages 2-6', support: true, small: true),
                ],
              ),
              const SizedBox(height: 14),
              const Text('Watch to learn.\nPlay to learn.', textAlign: TextAlign.center, style: AppText.display),
              const SizedBox(height: 10),
              const Text(
                'Spanish and English lessons for ages 2 to 6, led by Maestra Luna. Ad-free.',
                textAlign: TextAlign.center,
                style: AppText.body,
              ),
              const SizedBox(height: 24),
              _SignInButton(
                key: const Key('sign-in-apple'),
                label: 'Continue with Apple',
                icon: Icons.apple,
                dark: true,
                onTap: () => _signIn(context, ref),
              ),
              const SizedBox(height: 12),
              _SignInButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                onTap: () => _signIn(context, ref),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => _signIn(context, ref),
                child: const Text('Use email instead', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.accentFill)),
              ),
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.textTertiary),
                  SizedBox(width: 6),
                  Text('For grown-ups: a parent sets up the account.', style: AppText.caption),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignInButton extends StatelessWidget {
  const _SignInButton({super.key, required this.label, required this.icon, required this.onTap, this.dark = false});
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: dark ? Colors.black : Colors.white,
        shape: StadiumBorder(side: dark ? BorderSide.none : const BorderSide(color: AppColors.border, width: 1.5)),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: dark ? Colors.white : AppColors.textPrimary, size: dark ? 24 : 32),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: dark ? Colors.white : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
