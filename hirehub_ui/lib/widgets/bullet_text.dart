import 'package:flutter/material.dart';

class BulletText extends StatelessWidget {
  final String text;
  final String? symbol;
  final TextStyle? symbolStyle;
  final TextStyle? textStyle;

  const BulletText(this.text,
      {super.key, this.symbol, this.symbolStyle, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(symbol ?? '✓ ', style: symbolStyle),
        const SizedBox(
          width: 5,
        ),
        Expanded(child: Text(text, style: textStyle)),
      ],
    );
  }
}

class BulletText2 extends StatelessWidget {
  final String text;
  final String? symbol;
  final TextStyle? textStyle;
  final TextStyle? symbolStyle;

  const BulletText2(this.text,
      {super.key, this.symbol, this.symbolStyle, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(symbol ?? '● ', style: symbolStyle),
        const SizedBox(
          width: 5,
        ),
        Text(text, style: textStyle),
      ],
    );
  }
}
