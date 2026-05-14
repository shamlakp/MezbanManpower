import 'package:flutter/material.dart';
import 'package:hirehub_ui/constants/text_styles.dart';

class CustomCard extends StatelessWidget {
  const CustomCard(this.lst, {required this.title, super.key});
  final String title;
  final List<Map<String, dynamic>> lst;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(
            color: Theme.of(context).colorScheme.onPrimary, width: 0.3),
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onBackground,
                border: Border.all(
                    color: Theme.of(context).colorScheme.onPrimary, width: 0.3),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  title,
                  style: CustomTextStyle.heading20
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                Divider(
                  color:
                      Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
                  height: 50,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Wrap(
                      spacing: 60,
                      runSpacing: 30,
                      children: List.generate(lst.length, (index) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lst[index]['label'],
                                style: CustomTextStyle.body14
                                    .copyWith(fontWeight: FontWeight.w200)),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              lst[index]['value'],
                              style: CustomTextStyle.body16,
                            ),
                          ],
                        );
                      })),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
