import 'package:flutter/material.dart';

class GradientIconBadge extends StatelessWidget {
  const GradientIconBadge({
    super.key,
    required this.icon,
    required this.colors,
    this.size = 48,
  });

  final IconData icon;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        color: colors.first.withValues(alpha: 0.12),
      ),
      child: Center(
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ).createShader(bounds);
          },
          child: Icon(icon, size: size * 0.46),
        ),
      ),
    );
  }
}
