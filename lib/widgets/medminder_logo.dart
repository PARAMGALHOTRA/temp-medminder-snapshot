import 'package:flutter/material.dart';

class MedMinderLogo extends StatelessWidget {
  final double width;
  final double height;
  final double fontSize;
  const MedMinderLogo({
    super.key,
    this.width = 220,
    this.height = 56,
    this.fontSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF23262F) : const Color(0xFFEDF1F7);
    final textColor = isDark ? Colors.white : const Color(0xFF222B45);
    final accent = isDark ? const Color(0xFF6C8AE4) : const Color(0xFF3D5AFE);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, width: 2),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: RichText(
          text: TextSpan(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
              letterSpacing: 1.5,
              color: textColor,
            ),
            children: [
              TextSpan(text: 'Med', style: TextStyle(color: accent)),
              TextSpan(text: 'Minder', style: TextStyle(color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}
