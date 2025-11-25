import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.width, required this.height, required this.text, required this.icon, this.borderRadius = 22, this.customChild, this.backgroundColor = Colors.white, this.customText, this.customIcon});
  final dynamic onPressed;
  final double width;
  final double height;
  final dynamic text;
  final dynamic icon;
  final double borderRadius;
  final dynamic backgroundColor;
  final dynamic customChild;
  final dynamic customText;
  final dynamic customIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), color: backgroundColor),
          width: width,
          height: height,
          child: (customChild == null) ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (customText == null ) ? text : customText,
              (customIcon == null) ? (!(icon == null)) ? icon : SizedBox() : customIcon,
            ],
          ) : customChild,
      ),
    );
  }
}
