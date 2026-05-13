import 'package:flutter/material.dart';
import 'package:troobot_mobile/core/utils/text_styles.dart';

class DrawerList extends StatelessWidget {
  final String name;
  final IconData icon;
  const DrawerList({super.key, required this.name, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(
            width: 15,
          ),
          Text(
            name,
            style: CustomTextStyle.label14.copyWith(color: Colors.black),
          ),
        ],
      ),
    );
  }
}
