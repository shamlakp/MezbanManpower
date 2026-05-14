import 'package:flutter/material.dart';
import 'package:hirehub_ui/constants/text_styles.dart';

class CustomSnackbar extends SnackBar {
  static const EdgeInsets _margin = EdgeInsets.all(30);
  static final TextStyle _textStyle =
      CustomTextStyle.body14.copyWith(color: Colors.white);
  static const EdgeInsetsGeometry _padding = EdgeInsets.all(16.0);

  // Constructor allowing only text customization
  CustomSnackbar({
    super.key,
    required String text,
    Color? backgroundColor,
    Duration? duration,
  }) : super(
            content: Text(text, style: _textStyle),
            duration: duration ?? const Duration(milliseconds: 3000),
            backgroundColor: backgroundColor ?? Colors.blue,
            padding: _padding,
            behavior: SnackBarBehavior.floating,
            margin: _margin);
}
