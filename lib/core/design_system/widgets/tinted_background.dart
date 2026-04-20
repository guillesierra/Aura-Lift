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
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF0C1013),
                  Color(0xFF10171A),
                  Color(0xFF0D1114),
                ]
              : const [
                  Color(0xFFF7FAFB),
                  Color(0xFFF2F6F7),
                  Color(0xFFF4F7F8),
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -70,
            right: -10,
            child: _GlowOrb(
              color: isDark
                  ? const Color(0x332BC2A5)
                  : const Color(0x335ED8C0),
              size: 220,
            ),
          ),
          Positioned(
            top: 180,
            left: -50,
            child: _GlowOrb(
              color: isDark
                  ? const Color(0x1AFFFFFF)
                  : const Color(0x22A9BBC4),
              size: 180,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}
