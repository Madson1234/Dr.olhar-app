import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import 'app_button.dart';

/// White header bar with a back arrow, title/subtitle stack, and an
/// optional trailing widget (used for the 1/3, 2/3, 3/3 step counters).
class ScreenHeader extends StatelessWidget {
  final VoidCallback? onBack;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const ScreenHeader({
    super.key,
    required this.onBack,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: AppColors.surf,
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            SquareIconButton(
              onPressed: onBack,
              semanticLabel: 'Voltar',
              child: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.ink),
            ),
          if (onBack != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: AppText.ps(16, weight: FontWeight.w600, height: 1.2), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.ps(12.5, color: AppColors.mut), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
