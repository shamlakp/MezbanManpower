import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomIcon extends StatelessWidget {
  final EdgeInsetsGeometry? padding;
  final double? width;
  final String name;
  final Color? color;
  final bool? svg;
  final Function() onTap;
  const CustomIcon({
    super.key,
    this.padding,
    this.width,
    required this.name,
    this.color,
    required this.onTap,
    this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: padding,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: color),
          child: svg == false
              ? Image.asset(
                  name,
                  width: width ?? 35,
                )
              : SvgPicture.asset(
                  name,
                  width: width ?? 35,
                )),
    );
  }
}
