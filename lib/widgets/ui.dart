import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/tokens.dart';

/// Primary pill: soft accent -> support gradient, white label.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.leadingIcon,
    this.kid = false,
    this.solid = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? leadingIcon;
  final bool kid;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final h = kid ? 64.0 : 56.0;
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: Container(
        height: h,
        decoration: BoxDecoration(
          gradient: solid ? null : AppGradients.hero,
          color: solid ? AppColors.accentFill : null,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: onTap == null ? null : AppShadows.glow(AppColors.accent).map((s) => s.scale(0.5)).toList(),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, color: Colors.white, size: kid ? 26 : 22),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: kid ? AppFonts.display : AppFonts.body,
                    fontSize: kid ? 22 : 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (icon != null) ...[
                  const SizedBox(width: 10),
                  Icon(icon, color: Colors.white, size: kid ? 26 : 22),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary pill: white, 2px accent border, accent-fill label.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.onTap, this.icon, this.leadingIcon, this.kid = false});

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final IconData? leadingIcon;
  final bool kid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kid ? 64 : 56,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.accent, width: 2),
          shape: const StadiumBorder(),
          foregroundColor: AppColors.accentFill,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[Icon(leadingIcon, size: 22), const SizedBox(width: 8)],
            Text(
              label,
              style: TextStyle(
                fontFamily: kid ? AppFonts.display : AppFonts.body,
                fontSize: kid ? 20 : 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (icon != null) ...[const SizedBox(width: 8), Icon(icon, size: 22)],
          ],
        ),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(20), this.onTap, this.border});
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
        border: border,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Pill chip. Default: accent tint fill + accent-fill label.
class Pill extends StatelessWidget {
  const Pill(this.label, {super.key, this.icon, this.support = false, this.color, this.textColor, this.small = false});
  final String label;
  final IconData? icon;
  final bool support;
  final Color? color;
  final Color? textColor;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? (support ? AppColors.support : AppColors.accentTint);
    final fg = textColor ?? (support ? AppColors.textPrimary : AppColors.accentFill);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 10 : 14, vertical: small ? 4 : 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: small ? 14 : 16, color: fg), const SizedBox(width: 5)],
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: small ? 12 : 14, fontWeight: FontWeight.w600, color: fg)),
          ),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  const Avatar(this.image, {super.key, this.size = 48, this.ring = AppColors.surface, this.ringWidth = 3});
  final String image;
  final double size;
  final Color ring;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(color: ring, shape: BoxShape.circle, boxShadow: AppShadows.soft),
      child: ClipOval(child: Image.asset(image, fit: BoxFit.cover)),
    );
  }
}

class Photo extends StatelessWidget {
  const Photo(this.image, {super.key, this.height, this.radius = AppRadius.card, this.alignment = Alignment.center});
  final String image;
  final double? height;
  final double radius;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(image, height: height, width: double.infinity, fit: BoxFit.cover, alignment: alignment),
    );
  }
}

/// Round icon button used in headers (close, back, sound, lock).
class CircleIconButton extends StatelessWidget {
  const CircleIconButton(this.icon, {super.key, this.onTap, this.size = 44, this.tint = false, this.semantic});
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool tint;
  final String? semantic;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semantic,
      button: true,
      child: Material(
        color: tint ? AppColors.accentTint : AppColors.surface,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, size: size * 0.5, color: tint ? AppColors.accentFill : AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Watch / Play / Talk pills. done = check, active = accent fill, upcoming = outline.
class StepPills extends StatelessWidget {
  const StepPills({super.key, required this.active, this.compact = false});

  /// Index of the active step (0..2). 3 = all done.
  final int active;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final s in LessonStep.values) ...[
          _pill(s, s.index < active ? 0 : (s.index == active ? 1 : 2)),
          if (s != LessonStep.talk) SizedBox(width: compact ? 4 : 6),
        ],
      ],
    );
  }

  Widget _pill(LessonStep s, int state) {
    final done = state == 0;
    final on = state == 1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: on ? AppColors.accentFill : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: on ? AppColors.accentFill : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : s.icon,
            size: compact ? 15 : 17,
            color: done ? AppColors.success : (on ? Colors.white : AppColors.textTertiary),
          ),
          const SizedBox(width: 5),
          Text(
            s.label,
            style: TextStyle(
              fontSize: compact ? 12.5 : 14,
              fontWeight: FontWeight.w600,
              color: on ? Colors.white : (done ? AppColors.textPrimary : AppColors.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class StarCounter extends StatelessWidget {
  const StarCounter(this.stars, {super.key});
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
      decoration: BoxDecoration(color: AppColors.warningTint, borderRadius: BorderRadius.circular(AppRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 22),
          const SizedBox(width: 4),
          Text('$stars', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

/// Section label for parent screens (e.g. LEARNING).
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
        child: Text(text.toUpperCase(), style: AppText.overline.copyWith(color: AppColors.textTertiary)),
      );
}

/// Teacher speech bubble.
class SpeechBubble extends StatelessWidget {
  const SpeechBubble(this.text, {super.key, this.sub});
  final String text;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
        ),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, style: const TextStyle(fontFamily: AppFonts.display, fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.accentFill)),
          if (sub != null) Text(sub!, style: AppText.caption.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
