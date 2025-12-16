import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_button.dart';

class CartItem extends StatefulWidget {
  CartItem({super.key, required this.add, required this.subtract, required this.itemName, required this.child, required this.height, required this.width, this.amount = 0});
  String itemName;
  Function add;
  Function subtract;
  dynamic child;
  double width;
  double height;
  dynamic amount;

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Color(0xFFFDFBFF), borderRadius: BorderRadius.circular(25)),
        width: widget.width,
        height: widget.height,
        child: Align(
            alignment: AlignmentGeometry.center,
            child: Column(
                children: [
                  SizedBox(height: 20),
                  Text("${widget.itemName} Widget"),
                  SizedBox(height: 20),
                  widget.child, // <--
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(width: 50),
                      CustomButton(backgroundColor: Colors.transparent, onPressed: widget.add, width: 35, height: 35, text: SizedBox(), icon: Icon(color: Color(0xFFAAB7FD), size: 35, Icons.add)),
                      Text("${widget.amount}", style: TextStyle(fontWeight: FontWeight.w900)),
                      CustomButton(backgroundColor: Colors.transparent, onPressed: widget.subtract, width: 35, height: 35, text: SizedBox(), icon: Icon(color: Color(0xFFAAB7FD), size: 35, Icons.remove)),
                      SizedBox(width: 50),
                    ],
                  ),
                  // CustomButton(
                  //   backgroundColor: Color(0xFFE5E5FF),
                  //   onPressed: widget.onPressed,
                  //   width: 235,
                  //   height: 45,
                  //   text: SizedBox(),
                  //   icon: null,
                  //   customChild: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Text("ADD TO CART", style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w600)),
                  //       SizedBox(width: 7),
                  //       Icon(Icons.add_shopping_cart, color: Color(0xFF9AA7ED)),
                  //     ],
                  //   ),
                  // ),
                ]
            )
        )
    );
  }
}
