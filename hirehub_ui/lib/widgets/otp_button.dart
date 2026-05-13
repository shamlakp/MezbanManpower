import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpButton extends StatefulWidget {
  final bool Function(String) onValueCheck;
  const OtpButton({super.key, required this.onValueCheck});

  @override
  State<OtpButton> createState() => _OtpButtonState();
}

class _OtpButtonState extends State<OtpButton> {
  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.of(context).size);
    return Padding(
      padding: EdgeInsets.all(size.width * 0.015),
      child: SizedBox(
        height: 60,
        width: 50,
        child: TextFormField(
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly
          ],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            if (value.isEmpty) {
              FocusScope.of(context).previousFocus();
            }
            widget.onValueCheck(value);
          },
          decoration: InputDecoration(
            hintText: 'X',
            hintStyle:
                const TextStyle(color: Color.fromARGB(255, 200, 200, 200)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface, width: 2)),
          ),
        ),
      ),
    );
  }
}
