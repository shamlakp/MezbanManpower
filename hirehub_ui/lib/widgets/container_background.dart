import 'package:flutter/material.dart';

class CustomContainerBackground extends StatelessWidget {
  const CustomContainerBackground(
      {super.key,
      this.borderRadiusValue,
      this.width,
      this.height,
      this.margin,
      required this.child,
      this.padding});

  final double? borderRadiusValue, width, height;
  final EdgeInsets? margin, padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onBackground,
        borderRadius: BorderRadius.circular(borderRadiusValue ?? 15),
        image: const DecorationImage(
            image:
                AssetImage('assets/images/background/troobot_placeholder.png'),
            fit: BoxFit.cover),
      ),
      margin: margin,
      height: height,
      width: width,
      padding: padding,
      child: child,
    );
  }
}
