import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.width, required this.height, required this.text, required this.icon, this.borderRadius = 22, this.customChild, this.customText, this.customIcon});
  final dynamic onPressed;
  final double width;
  final double height;
  final String text;
  final dynamic icon;
  final double borderRadius;
  final dynamic customChild;
  final dynamic customText;
  final dynamic customIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(borderRadius), color: Colors.white),
          width: width,
          height: height,
          child: (customChild == null) ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (customText == null ) ? Text(text, style: GoogleFonts.robotoFlex(color: Colors.black, fontSize: 30, decoration: TextDecoration.none)): customText,
              (customIcon == null) ?Icon(icon, size: 50,) : customIcon,
            ],
          ) : customChild,
      ),
    );
  }
}
