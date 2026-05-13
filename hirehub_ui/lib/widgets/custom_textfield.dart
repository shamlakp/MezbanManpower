import 'package:flutter/material.dart';
import 'package:troobot_mobile/core/utils/text_styles.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {super.key,
      this.controller,
      this.prefixIcon,
      this.onTap,
      this.hintStyle,
      this.hintText,
      this.contentPadding,
      this.enabledBorder,
      this.focusedBorder,
      this.fillColor,
      this.readOnly,
      required this.size,
      this.suffixIcon,
      this.onChanged,
      this.style,
      this.maxLines});
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextStyle? hintStyle;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final Color? fillColor;
  final bool? readOnly;
  final TextStyle? style;
  final Size size;
  final int? maxLines;
  final void Function(String value)? onChanged;
  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      controller: controller,
      onTap: onTap,
      style: style ?? CustomTextStyle.body14,
      readOnly: readOnly ?? false,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 247, 247, 247),
        border: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onPrimary, width: 0.3),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        enabledBorder: enabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.onPrimary, width: 0.3),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
        focusedBorder: focusedBorder ??
            const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 0.3),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelText: hintText,
        labelStyle: hintStyle ??
            CustomTextStyle.body14
                .copyWith(color: Theme.of(context).colorScheme.onPrimary),
      ),
    );
  }
}
