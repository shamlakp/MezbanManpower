import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:hirehub_ui/constants/colors.dart';

class FavButton extends StatefulWidget {
  final Color? color;
  const FavButton({super.key, this.color});

  @override
  State<FavButton> createState() => _FavButtonState();
}

class _FavButtonState extends State<FavButton>
    with SingleTickerProviderStateMixin {
  bool filled = false;
  late AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    // ..repeat(reverse: true);
    animation = Tween<double>(begin: 1, end: 1.2).animate(controller);

    controller.addStatusListener((status) {
      if (status.isCompleted) {
        controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          filled = !filled;
          controller.forward();
        });
      },
      child: ScaleTransition(
        scale: animation,
        child: filled
            ? const Icon(
                size: 27,
                Clarity.heart_solid,
                color: Color.fromARGB(255, 220, 4, 4),
              )
            : Icon(
                size: 27,
                Clarity.heart_line,
                color: widget.color ?? NeutralColors.c100,
              ),
      ),
    );
  }
}
