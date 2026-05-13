import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:troobot_mobile/core/utils/text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField(
      {super.key,
      this.controller,
      this.prefixIcon,
      this.onChanged,
      this.onTap,
      this.hintStyle,
      this.hintText,
      this.contentPadding,
      this.enabledBorder,
      this.focusedBorder,
      this.fillColor,
      this.readOnly,
      required this.size,
      this.validator,
      this.errorStyle,
      this.style,
      this.inputFormatters,
      this.keyboardType,
      this.maxLines,
      this.autocorrect,
      this.enableSuggestions,
      this.obscureText,
      this.focusNode,
      this.suffixIcon,
      this.onSaved});
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final Color? fillColor;
  final bool? readOnly;
  final Size size;
  final TextStyle? style;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;

  final FocusNode? focusNode;
  final int? maxLines;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      enableSuggestions: enableSuggestions ?? true,
      autocorrect: autocorrect ?? true,
      validator: validator,
      controller: controller,
      onTap: onTap,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      onSaved: onSaved,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      style:
          style ?? CustomTextStyle.body14.copyWith(fontWeight: FontWeight.w500),
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
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        suffixIcon: suffixIcon,
        label: Text(hintText ?? ''),
        labelStyle: hintStyle ??
            CustomTextStyle.body14.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w400),
      ),
    );
  }
}

class CustomUnderlineTextFormField extends StatelessWidget {
  const CustomUnderlineTextFormField(
      {super.key,
      this.controller,
      this.prefixIcon,
      this.onChanged,
      this.onTap,
      this.hintStyle,
      this.hintText,
      this.contentPadding,
      this.enabledBorder,
      this.focusedBorder,
      this.fillColor,
      this.readOnly,
      required this.size,
      this.validator,
      this.errorStyle,
      this.style,
      this.inputFormatters,
      this.keyboardType,
      this.maxLines,
      this.autocorrect,
      this.enableSuggestions,
      this.obscureText,
      this.focusNode,
      this.suffixIcon,
      this.onSaved});
  final TextEditingController? controller;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final String? hintText;
  final EdgeInsets? contentPadding;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final Color? fillColor;
  final bool? readOnly;
  final Size size;
  final TextStyle? style;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final String? Function(String? value)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;

  final FocusNode? focusNode;
  final int? maxLines;
  final bool? obscureText;
  final bool? enableSuggestions;
  final bool? autocorrect;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      obscureText: obscureText ?? false,
      enableSuggestions: enableSuggestions ?? true,
      autocorrect: autocorrect ?? true,
      validator: validator,
      controller: controller,
      onTap: onTap,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      maxLines: maxLines ?? 1,
      onSaved: onSaved,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      style:
          style ?? CustomTextStyle.body14.copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        border: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
                color:
                    Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
                width: 2)),
        enabledBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .onBackground
                    .withOpacity(0.1))),
        focusedBorder: UnderlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                width: 2)),
        prefixIcon: prefixIcon,
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        suffixIcon: suffixIcon,
        label: Text(hintText ?? ''),
        labelStyle: hintStyle ??
            CustomTextStyle.body14.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w400),
      ),
    );
  }
}
