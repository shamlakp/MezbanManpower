import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:troobot_mobile/core/utils/color_plt/colors.dart';

class BackwardButton extends StatelessWidget {
  final Color? color;
  final Function()? onTapExtra;
  final Color? backgroundColor;

  const BackwardButton(
      {super.key, this.backgroundColor, this.color, this.onTapExtra});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTapExtra != null) {
          onTapExtra!();
          
        } else {
          Navigator.pop(context, true);
        }
      },
      child: RotatedBox(
        quarterTurns: -1,
        child: CircleAvatar(
          radius: 13,
          backgroundColor: backgroundColor ?? Colors.white,
          child: Icon(
            Clarity.arrow_line,
            color: color ?? NeutralColors.c900,
          ),
        ),
      ),
    );
  }
}

class BackwardButtonNoBg extends StatelessWidget {
  final Color? color;
  const BackwardButtonNoBg({this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, true);
      },
      child: RotatedBox(
        quarterTurns: -1,
        child: Icon(
          Clarity.arrow_line,
          color: color ?? NeutralColors.c900,
        ),
      ),
    );
  }
}




// class BackwardButton extends StatelessWidget {
//   const BackwardButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pop(context, true);
//       },
//       child: CircleAvatar(
//         maxRadius: 25,
//         backgroundColor: Colors.black.withOpacity(0.7),
//         child: const Icon(
//           CupertinoIcons.back,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
// }
