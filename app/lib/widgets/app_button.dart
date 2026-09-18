import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Filled primary action button — 60px tall by default, `#1B6FE3` background
/// darkening on press, matching the prototype's `Entrar` / `Salvar` / etc.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;
  final Color bg;
  final Color textColor;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 60,
    this.fontSize = 17,
    this.bg = AppColors.acc,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: disabled ? AppColors.line : bg,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.button),
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: AppColors.accD.withValues(alpha: 0.25),
          child: Center(
            child: Text(
              label,
              style: AppText.ps(fontSize, weight: FontWeight.w600, color: disabled ? AppColors.mut : textColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined secondary button — `Cancelar` / `Refazer` style.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double height;
  final Color textColor;
  final Color borderColor;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.textColor = AppColors.ink,
    this.borderColor = AppColors.line,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: AppColors.surf,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadii.button),
          highlightColor: borderColor.withValues(alpha: 0.15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.button),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: AppText.ps(16, weight: FontWeight.w600, color: textColor)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 36×36 square icon button used for back arrows and similar chrome.
class SquareIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final String? semanticLabel;

  const SquareIconButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 36,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: Material(
          color: AppColors.surf,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.line),
              ),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
