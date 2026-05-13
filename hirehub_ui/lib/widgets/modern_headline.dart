import 'package:flutter/material.dart';
import '../constants/colors.dart';

class ModernHeadline extends StatelessWidget {
  final String title;
  final double fontSize;
  final double letterSpacing;
  final TextAlign textAlign;

  const ModernHeadline({
    super.key,
    required this.title,
    this.fontSize = 20,
    this.letterSpacing = -1,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final words = title.split(' ');
    if (words.isEmpty) return const SizedBox.shrink();

    final firstPart = words[0];
    final remainingPart = words.length > 1 ? words.sublist(1).join(' ') : '';

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: NeutralColor.c900,
          letterSpacing: letterSpacing,
        ),
        children: [
          TextSpan(
            text: '$firstPart ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (remainingPart.isNotEmpty)
            TextSpan(
              text: remainingPart,
              style: const TextStyle(
                color: NeutralColor.c500,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
