import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../create.dart';
import 'custom_button.dart';

enum WidgetTileType {
  imagePicker,
  ingredientsList,
}

class WidgetTile extends StatefulWidget {
  const WidgetTile({super.key, required this.type, required this.delete, required this.index});
  final WidgetTileType type;
  final Function delete;
  final int index;

  @override
  State<WidgetTile> createState() => _WidgetTileState();
}

class _WidgetTileState extends State<WidgetTile> {


  @override
  Widget build(BuildContext context) { // stack?
    if (widget.type == WidgetTileType.imagePicker) {
      return Padding(padding: EdgeInsets.all(20), child: Container(
              decoration: BoxDecoration(color: Color(0xFFFDFBFF), borderRadius: BorderRadius.circular(25)),
              width: 360,
              height: 430,
              child: Align(
                  alignment: AlignmentGeometry.topCenter,
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600), "Image Picker Widget"),
                      SizedBox(height: 20),
                      GestureDetector(onTap: () {},//CreatePage.pickImg,
                        child: Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Color(0xFFD1D1EF)),
                            // onPressed: () {print("Image Picker");},
                            width: 310, height: 310,
                            child: Icon(Icons.add_circle, size: 67, color: Colors.white)
                        ),
                      ),
                      IconButton(onPressed: widget.delete(widget.index), icon: Icon(Icons.delete)),
                    ]
                  )
              )
          ),);// child: IconButton(onPressed: widget.delete(widget.index), icon: Icon(Icons.delete)));
    } else if (widget.type == WidgetTileType.ingredientsList) {
      return Padding(
          padding: EdgeInsets.all(20),
          child: Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
                  color: Colors.white,

              ),
            child: Column(children: [
              SizedBox(height: 15),
              Text("Ingredients", style: GoogleFonts.robotoFlex(fontWeight: FontWeight.w600, fontSize: 25,)),

              ListView.builder(

                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 5,
                itemBuilder: (context, index) {return Align(alignment: Alignment.center, child: Padding(padding: EdgeInsets.only(left: 10, right: 10), child: Text("- ex")));},

              ),

              SizedBox(height: 5),
              CustomButton(backgroundColor: Color(0xFFFFCCCC ), onPressed: () {}, width: 50, height: 30, text: Text("Add"), icon: null, borderRadius: 15,),
              SizedBox(height: 5),
            ]
            ),
          )
      );
    }
    return ingredientsList();
  }
  Widget ingredientsList() {
    return Container(color: Colors.grey, height: 50);
  }
}
