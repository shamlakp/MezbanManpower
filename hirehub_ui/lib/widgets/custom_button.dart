import 'package:flutter/material.dart';
import 'package:troobot_mobile/core/utils/color_plt/colors.dart';
import 'package:troobot_mobile/core/utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final Color? fontColor;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final Color? buttonBgColor;
  final BorderSide? borderSide;
  final double? elevation;
  final OutlinedBorder? shape;
  const CustomButton(
      {required this.onPressed,
      required this.text,
      this.fontColor,
      this.width,
      this.height,
      this.textStyle,
      this.buttonBgColor,
      this.borderSide,
      this.elevation,
      this.shape,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 45,
      width: width ?? double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          side: borderSide,
          shape: shape,
          backgroundColor:
              buttonBgColor ?? const Color.fromARGB(255, 71, 133, 249),
        ),
        child: Text(
          text,
          style: textStyle ??
              CustomTextStyle.body16.copyWith(
                  color: fontColor ?? Colors.white,
                  fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class CustomButtonIcon extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final TextStyle? textStyle;
  final double? height;
  final double? width;
  final IconData icon;
  final Color? color;
  const CustomButtonIcon(
      {required this.onPressed,
      required this.text,
      this.color,
      required this.icon,
      this.width,
      this.height,
      this.textStyle,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40,
      width: width ?? double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? BrandColor.c500,
        ),
        label: Icon(
          icon,
          color: Colors.white,
          size: 25,
        ),
        icon: Text(
          text,
          style: textStyle ??
              CustomTextStyle.body16
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
