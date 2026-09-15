import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Notice with a small colored dot — used for LGPD notes and signal-quality
/// warnings (`Sinal bom`, `Ruído excessivo`, `Muito ruído...`).
class DotBanner extends StatelessWidget {
  final Color bg;
  final Color dotColor;
  final Color textColor;
  final String text;
  final double fontSize;

  const DotBanner({
    super.key,
    required this.bg,
    required this.dotColor,
    required this.textColor,
    required this.text,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppText.ps(fontSize, height: 1.4, color: textColor)),
          ),
        ],
      ),
    );
  }
}

/// Notice with a small monospace uppercase badge — used for the "LGPD" and
/// "UX-05" labelled notes.
class LabelBanner extends StatelessWidget {
  final Color bg;
  final Color labelColor;
  final Color textColor;
  final String label;
  final String text;
  final Border? border;

  const LabelBanner({
    super.key,
    required this.bg,
    required this.labelColor,
    required this.textColor,
    required this.label,
    required this.text,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(label, style: AppText.mono(10, weight: FontWeight.w600, color: labelColor)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppText.ps(12.5, height: 1.45, color: textColor)),
          ),
        ],
      ),
    );
  }
}
