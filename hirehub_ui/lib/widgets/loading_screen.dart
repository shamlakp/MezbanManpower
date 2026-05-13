import 'package:flutter/material.dart';

Widget loadingBuilder(BuildContext context) {
  return const Center(
    child: SizedBox(
      width: 55,
      height: 55,
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
          strokeWidth: 5),
    ),
  );
}
