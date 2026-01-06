import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/components/custom_button.dart';

import 'components/cart_item.dart';
import 'components/widget_tile.dart';
import 'create.dart';

class WidgetSelector extends StatefulWidget {
  const WidgetSelector({super.key, required this.startingCart, required this.delete,});
  final List<WidgetTile> startingCart;
  final Function delete;

  @override
  State<WidgetSelector> createState() => _WidgetSelectorState();
}

class _WidgetSelectorState extends State<WidgetSelector> {
  List<WidgetTile> cart = [];
  Map<String, int> amounts = {"imagePicker": 0, "ingredientsList": 0, "instructions": 0};
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    cart = widget.startingCart;

  }




  @override
  Widget build(BuildContext context) {
    // List<WidgetTile> cart = widget.startingCart; // Free widgets
    return DefaultTextStyle(
      style: GoogleFonts.robotoMono(fontSize: 25, color: Color(0xFFAAB7FD), fontWeight: FontWeight.w600),
      child: Stack(
        // color:
        children: [
          Container(
            width: double.infinity,
            color: Color(0xFFEAEBFF),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 80),

                  CartItem(
                    add: () {
                      cart.add(WidgetTile(type: WidgetTileType.imagePicker,  delete: widget.delete, index: cart.length, data: {"type": WidgetTileType.imagePicker, "imageUrl": ""}));
                      print(cart);
                      amounts["imagePicker"] = amounts["imagePicker"] !+ 1;
                      setState(() {});
                    },
                    subtract: () {if (cart.any((WidgetTile) => WidgetTile.type == WidgetTileType.imagePicker)) {amounts["imagePicker"] = amounts["imagePicker"] !- 1; cart.removeAt(cart.lastIndexWhere((WidgetTile) => WidgetTile.type == WidgetTileType.imagePicker)); setState(() {});} print(cart);},
                    itemName: "Image Picker",
                    width: 365,
                    height: 465,
                    child: Container(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Color(0xFFD1D1EF)),

                      width: 320, height: 320,
                      child: Icon(Icons.add_circle, size: 67, color: Colors.white),
                    ),
                    amount: amounts["imagePicker"],
                  ),

                  SizedBox(height: 30),

                  CartItem(
                      add: () {
                        cart.add(WidgetTile(type: WidgetTileType.ingredientsList, delete: widget.delete, index: cart.length, data: {"type": WidgetTileType.ingredientsList, "list": [],})); // enum
                        print("$cart <-- a list.");
                        amounts["ingredientsList"] = amounts["ingredientsList"] !+ 1;
                        setState(() {});
                      },
                      subtract: () {if (cart.any((WidgetTile) => WidgetTile.type == WidgetTileType.ingredientsList)) {amounts["ingredientsList"] = amounts["ingredientsList"] !- 1; cart.removeAt(cart.lastIndexWhere((WidgetTile) => WidgetTile.type == WidgetTileType.ingredientsList)); setState(() {});} print(cart);},
                      itemName: "Ingredients List",
                      width: 375,
                      height: 270,
                      child: Container(width: 300, decoration: BoxDecoration(color: Color(0xFFDFDFFF), borderRadius: BorderRadius.circular(17)), child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("- 5 grams ______"),Text("- 1 tsp ______"),Text("- 1 whole ______"),]))),
                      amount: amounts["ingredientsList"],
                  ),

                  SizedBox(height: 30),

                  CartItem(
                    add: () {
                      cart.add(WidgetTile(type: WidgetTileType.instructions, delete: widget.delete, index: cart.length, data: {"type": WidgetTileType.instructions, "list": [],})); // enum
                      print("$cart <-- a list.");
                      amounts["instructions"] = amounts["instructions"] !+ 1;
                      setState(() {});
                    },
                    subtract: () {if (cart.any((WidgetTile) => WidgetTile.type == WidgetTileType.instructions)) {amounts["instructions"] = amounts["instructions"] !- 1; cart.removeAt(cart.lastIndexWhere((WidgetTile) => WidgetTile.type == WidgetTileType.instructions)); setState(() {});} print(cart);},
                    itemName: "Instructions",
                    width: 375,
                    height: 270,
                    child: Container(width: 300, decoration: BoxDecoration(color: Color(0xFFDFDFFF), borderRadius: BorderRadius.circular(17)), child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("- 5 grams ______"),Text("- 1 tsp ______"),Text("- 1 whole ______"),]))),
                    amount: amounts["instructions"],
                  ),

                  SizedBox(height: 30),

                  CustomButton(
                      backgroundColor: Color(0xFFFAFAFF),
                      onPressed: () {
                        print(cart);
                        Navigator.pop(context, cart);
                        cart = [];
                      },
                      width: 300,
                      height: 55,
                      text: Row(
                        children: [
                          Text("ADD TO POST", style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w900)),
                          SizedBox(width: 10),
                        ],
                      ),
                      icon: Icon(Icons.add_box, color: Color(0xFFAAB7FD))
                  ),



                  // Container(
                  //     decoration: BoxDecoration(color: Color(0xFFFDFBFF), borderRadius: BorderRadius.circular(25)),
                  //     width: 380,
                  //     height: 465,
                  //     child: Align(
                  //         alignment: AlignmentGeometry.center,
                  //         child: Column(
                  //           children: [
                  //             SizedBox(height: 20),
                  //             Text("Image Picker Widget"),
                  //             SizedBox(height: 20),
                  //             Container(
                  //                 decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Color(0xFFD1D1EF)),
                  //                 // onPressed: () {print("Image Picker");},
                  //                 width: 320, height: 320,
                  //                 child: Icon(Icons.add_circle, size: 67, color: Colors.white)
                  //             ),
                  //             SizedBox(height: 15),
                  //             CustomButton(
                  //               backgroundColor: Color(0xFFE1E1FF),
                  //               onPressed: () {
                  //                 print("ADD IMAGE PICKER WIDGET TO CART");
                  //               },
                  //               width: 235,
                  //               height: 45,
                  //               text: SizedBox(),
                  //               icon: null,
                  //               customChild: Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   Text("ADD TO CART", style: GoogleFonts.ubuntuMono(fontWeight: FontWeight.w600)),
                  //                   SizedBox(width: 7),
                  //                   Icon(Icons.add_shopping_cart, color: Color(0xFF9AA7ED)),
                  //                 ],
                  //               ),
                  //             ),
                  //           ]
                  //         )
                  //     )
                  // ),


                  // SizedBox(height: 30),
                  //
                  // CustomButton(backgroundColor: Color(0xFFD1D1EF),onPressed: () {}, width: 340, height: 340, text: Text(""), icon: Icon(Icons.add_circle, size: 67, color: Colors.white)),
                  // SizedBox(height: 20),
                  // Text("Image Picker"),
                  //
                  // SizedBox(height: 30),
                  //
                  // CustomButton(backgroundColor: Color(0xFFD1D1EF),onPressed: () {}, width: 340, height: 340, text: Text(""), icon: Icon(Icons.add_circle, size: 67, color: Colors.white)),
                  // SizedBox(height: 20),
                  // Text("Image Picker"),
                // GestureDetector(
                //   onTap: () {
                //     pickImg();
                //     print("pick");
                //   },
                //   child: (imageFile == null)
                //       ? Container(
                //       width: 340,
                //       height: 340,
                //       color: Color(0xffb4b4b4),
                //       child: Icon(
                //         size: 67,
                //         Icons.add_circle,
                //         color: Colors.white,
                //       ))
                //       : Image.file(File(imageFile!.path)),
                // ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
          Opacity(opacity: 0.8, child: Container(color: Color(0xFFFBF7FF), height: 62)),
        ]
      ),
    );
  }
}
