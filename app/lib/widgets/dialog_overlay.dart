import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Full-screen modal backdrop with a centered card, matching the
/// prototype's `subir` entrance animation (fade + slide up, .22s ease).
class DialogOverlay extends StatefulWidget {
  final Widget child;
  final double maxWidth;

  const DialogOverlay({super.key, required this.child, this.maxWidth = 320});

  @override
  State<DialogOverlay> createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 220))..forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _c, curve: Curves.ease);
    return Positioned.fill(
      child: Container(
        color: AppColors.overlay,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: widget.maxWidth),
            child: FadeTransition(
              opacity: curved,
              child: AnimatedBuilder(
                animation: curved,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, 6 * (1 - curved.value)),
                  child: child,
                ),
                child: Material(
                  color: AppColors.surf,
                  borderRadius: BorderRadius.circular(AppRadii.dialog),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.dialog),
                      boxShadow: AppShadows.dialog,
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
