import 'package:flutter/material.dart';
import 'package:troobot_mobile/core/utils/text_styles.dart';

class CustomDropdownMenu<T> extends StatelessWidget {
  const CustomDropdownMenu(
      {super.key,
      required this.dropdownMenuEntries,
      this.menuStyle,
      this.width,
      this.initialSelection,
      this.leadingIcon,
      this.label,
      this.requestFocusOnTap,
      this.enableFilter,
      this.onSelected,
      this.filled,
      this.fillColor,
      this.enabledBorder,
      this.focusedBorder,
      required this.labelText,
      this.labelStyle});
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;
  final MenuStyle? menuStyle;
  final double? width;
  final T? initialSelection;
  final Widget? leadingIcon;
  final Widget? label;
  final bool? requestFocusOnTap;
  final bool? enableFilter;
  final bool? filled;
  final Color? fillColor;
  final InputBorder? enabledBorder;
  final InputBorder? focusedBorder;
  final String labelText;
  final TextStyle? labelStyle;
  final void Function(T? value)? onSelected;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      dropdownMenuEntries: dropdownMenuEntries,
      menuStyle: menuStyle ??
          const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            surfaceTintColor: WidgetStatePropertyAll(Colors.white),
          ),
      textStyle: CustomTextStyle.body14,
      leadingIcon: leadingIcon,
      label: Text(
        labelText,
        style: CustomTextStyle.body14.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w400),
      ),

      // label: Text(
      //   labelText,
      //   style: labelStyle ??
      //       CustomTextStyle.body14.copyWith(
      //           color: Theme.of(context).colorScheme.onPrimary,
      //           fontWeight: FontWeight.w400),
      // ),
      requestFocusOnTap: requestFocusOnTap,
      enableFilter: enableFilter ?? false,
      width: width,
      onSelected: onSelected,
      initialSelection: initialSelection,
      inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color.fromARGB(255, 199, 197, 197).withOpacity(0.15),
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
              )),
    );
  }
}
