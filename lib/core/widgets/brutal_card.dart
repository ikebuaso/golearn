import 'package:flutter/material.dart';
import '../theme/theme.dart';

class BrutalCard extends StatelessWidget {
  const BrutalCard({
    super.key,
    required this.child,
    this.color = NeobrutalismTheme.cardWhite,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 12,
    this.borderWidth = 2.5,
    this.shadowOffset = const Offset(4, 4),
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      padding: padding,
      decoration: NeobrutalismTheme.neobrutalCardDecoration(
        color: color,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
        shadowOffset: shadowOffset,
      ),
      child: child,
    );

    if (margin != null) {
      return Padding(padding: margin!, child: container);
    }
    return container;
  }
}
