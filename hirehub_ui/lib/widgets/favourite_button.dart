import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:troobot_mobile/core/utils/color_plt/colors.dart';

class FavouriteButton extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;

  const FavouriteButton({super.key, this.backgroundColor, this.color});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 13,
      backgroundColor: backgroundColor ?? Colors.white,
      child: Icon(
        Clarity.heart_line,
        color: color ?? NeutralColors.c900,
      ),
    );
  }
}

class FavouriteButtonNoBg extends StatelessWidget {
  final Color? color;
  const FavouriteButtonNoBg({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(
      Clarity.heart_line,
      color: color ?? NeutralColors.c900,
    );
  }
}
