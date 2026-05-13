import 'package:flutter/material.dart';

class Skelton extends StatefulWidget {
  const Skelton({
    super.key,
    required this.size,
    this.height,
    this.width,
    this.margin,
    this.borderRadiusValue,
  });

  final double? height, width, borderRadiusValue;
  final EdgeInsets? margin;

  final Size size;

  @override
  State<Skelton> createState() => _SkeltonState();
}

class _SkeltonState extends State<Skelton> with SingleTickerProviderStateMixin {
  late Animation<double> animation;

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100));
    animation = Tween(
            begin: widget.width != null
                ? -widget.width! / 0.25
                : -widget.size.width / 0.5,
            end: widget.width != null
                ? widget.width! * 1.3
                : widget.size.width * 1.2)
        .animate(controller);
    controller.forward();

    controller.addListener(() {
      if (controller.isCompleted) {
        controller.repeat();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadiusValue ?? 6),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            width: widget.width ?? double.infinity,
            height: widget.height ?? 10,
            margin: widget.margin,
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 237, 237, 237),
                borderRadius:
                    BorderRadius.circular(widget.borderRadiusValue ?? 6)),
          ),
          AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Positioned(
                    top: 0,
                    left: animation.value,
                    child: RotationTransition(
                      turns: const AlwaysStoppedAnimation(5 / 360),
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(255, 222, 222, 222),
                            offset: const Offset(1, 1),
                            blurRadius: 50,
                            spreadRadius: widget.width != null
                                ? widget.width! / 3
                                : widget.size.width / 5,
                          )
                        ]),
                        height: widget.height != null
                            ? widget.height! * 2
                            : 10 + 10,
                        width: widget.width != null
                            ? widget.width! / 10
                            : widget.size.width / 20,
                      ),
                    ));
              })
        ],
      ),
    );
  }
}
