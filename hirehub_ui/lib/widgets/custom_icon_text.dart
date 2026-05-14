import 'package:flutter/material.dart';
import 'package:hirehub_ui/constants/text_styles.dart';

class CustomIconText extends StatelessWidget {
  final String imgUrl;
  final String name;
  final double? width, containerWidth;
  const CustomIconText(this.imgUrl, this.name,
      {this.width, super.key, this.containerWidth});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.onBackground,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imgUrl,
                width: width ?? 40,
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          name,
          style: CustomTextStyle.label14.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
