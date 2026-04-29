import 'dart:ui';

import 'package:flutter/material.dart';

class AuraCard extends StatelessWidget {
  const AuraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderColor,
    this.borderWidth = 1,
    this.color,
    this.gradient,
  });

  static const radius = 8.0;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final double borderWidth;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fillColor = color ??
        theme.colorScheme.surface.withValues(alpha: isDark ? 0.66 : 0.76);
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            fillColor.withValues(alpha: isDark ? 0.86 : 0.92),
            theme.colorScheme.surface.withValues(alpha: isDark ? 0.54 : 0.68),
          ],
        );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: effectiveGradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor ??
                  theme.colorScheme.outline
                      .withValues(alpha: isDark ? 0.46 : 0.72),
              width: borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow
                    .withValues(alpha: isDark ? 0.16 : 0.07),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: isDark ? 0.12 : 0.34),
                Colors.white.withValues(alpha: 0),
              ],
              stops: const [0, 0.42],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
