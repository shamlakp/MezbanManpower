import 'package:flutter/cupertino.dart';
import 'package:hirehub_ui/constants/colors.dart';
import 'package:hirehub_ui/constants/text_styles.dart';

class CustomCounter extends StatelessWidget {
  final String label;
  final int value;
  final void Function() onTapAdd;
  final void Function() onTapMinus;
  const CustomCounter(
      {super.key,
      required this.onTapAdd,
      required this.onTapMinus,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
          color: NeutralColors.c100, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CustomTextStyle.body16,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onTapMinus,
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: NeutralColors.c300,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Icon(
                      CupertinoIcons.minus,
                      size: 18,
                    )),
              ),
              const SizedBox(
                width: 15,
              ),
              Text(
                value.toString(),
                style: CustomTextStyle.body16,
              ),
              const SizedBox(
                width: 15,
              ),
              GestureDetector(
                onTap: onTapAdd,
                child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                        color: NeutralColors.c300,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Icon(
                      CupertinoIcons.add,
                      size: 18,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
