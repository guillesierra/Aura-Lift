import 'package:flutter/material.dart';

class TintedBackground extends StatelessWidget {
  const TintedBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.72, -0.92),
          radius: 1.35,
          colors: isDark
              ? const [
                  Color(0xFF123A34),
                  Color(0xFF102821),
                  Color(0xFF0F1518),
                ]
              : const [
                  Color(0xFFE7F5F1),
                  Color(0xFFF2F8F5),
                  Color(0xFFF6F8F7),
                ],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF2BC2A5).withValues(alpha: 0.18),
                    const Color(0xFF0F1518).withValues(alpha: 0),
                    const Color(0xFF0B7E6C).withValues(alpha: 0.18),
                  ]
                : [
                    const Color(0xFF5CE0C4).withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.2),
                    const Color(0xFFA7F3DF).withValues(alpha: 0.18),
                  ],
          ),
        ),
        child: child,
      ),
    );
  }
}
