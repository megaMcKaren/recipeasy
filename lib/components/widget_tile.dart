import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../create.dart';
import '../firestore_utils.dart';
import 'custom_button.dart';

enum WidgetTileType {
  imagePicker,
  ingredientsList,
  none, instructions, description,
}

class WidgetTile extends StatefulWidget {
  WidgetTile({super.key, required this.type, required this.delete, required this.index, required this.data});
  final WidgetTileType type;
  final Function delete;
  int index;
  final Map<String, dynamic> data;


  @override
  State<WidgetTile> createState() => _WidgetTileState();
}

class _WidgetTileState extends State<WidgetTile> {

  // late final data = widget.data;
  //
  // @override
  // void initState() {
  //   super.initState();
  //   data["imgUrl"] = ""; // what if its a list
  // }




  @override
  Widget build(BuildContext context) { // stack?
    if (widget.type == WidgetTileType.imagePicker) {
      return imagePicker();
    } else if (widget.type == WidgetTileType.ingredientsList) {
      return ingredientsList();
    } else if (widget.type == WidgetTileType.instructions) {
      return instructions();
    } else if (widget.type == WidgetTileType.description) {
      return description();
    }
    return Text("nothing :(");
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
  }
  // XFile? imageFile;
  ImagePicker imgPick = ImagePicker();
  Widget imagePicker() {
    print(widget.data["imageUrl"]);
    // final data = widget.data;

    void pickImg() async {

      try {
        var pickedImg = await imgPick.pickImage(source: ImageSource.gallery);

        if (pickedImg != null) {
          final String imageUrl = await FirestoreUtils.uploadImgToDb(pickedImg);

          setState((){
            widget.data["imageUrl"] = imageUrl;
            // imageFile = pickedImg;
            // print(imageFile);
          });
        }
      } catch (error) {
        print("pickImg: $error");
      }
    }
    return Padding(padding: EdgeInsets.only(left: 30, right: 30, top: 30), child: Container(
        decoration: BoxDecoration(color: Color(0xFFFDFBFF), borderRadius: BorderRadius.circular(25)),
        width: (widget.data["imageUrl"].isEmpty) ? 380: null,
        height: (widget.data["imageUrl"].isEmpty) ? 430: null,
        child: Align(
            alignment: AlignmentGeometry.topCenter,
            child: (widget.data["imageUrl"].isEmpty)
              ? Column(
                children: [
                  SizedBox(height: 20),
                  Text(style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600), "Image Picker Widget"),
                  SizedBox(height: 20),
                  GestureDetector(onTap: () => pickImg(),//CreatePage.pickImg,
                    child: Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Color(0xFFD1D1EF)),
                        // onPressed: () {print("Image Picker");},
                        width: 300, height: 300,
                        child: Icon(Icons.add_circle, size: 67, color: Colors.white)
                    ),
                  ),
                  SizedBox(height: 10),
                  IconButton(onPressed: () => widget.delete(widget.index), icon: Icon(Icons.delete)),
                ]
            ) : CupertinoContextMenu(actions: <Widget>[
              Align(
                alignment: AlignmentGeometry.center,
                child: CupertinoContextMenuAction(
                  onPressed: () {

                    Navigator.pop(context);
                    widget.delete(widget.index);
                  },
                  isDestructiveAction: true,
                  trailingIcon: CupertinoIcons.delete,
                  child: const Text('Delete'),
                ),
              ),
            ],
            child: GestureDetector(onTap: () => pickImg(), child: ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network(widget.data["imageUrl"]))))
        )
    ),);// child: IconButton(onPressed: widget.delete(widget.index), icon: Icon(Icons.delete)));
  }
  TextEditingController instructionsController = TextEditingController();
  Widget instructions() {
    final data = widget.data; // why not like this
    void addIngredient(x) {
      data["list"].add(x);

    }
    return Padding(
        padding: EdgeInsets.all(20),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),
            color: Colors.white,

          ),
          child: Column(children: [
            SizedBox(height: 15),
            Text("Instructions", style: GoogleFonts.robotoFlex(fontWeight: FontWeight.w600, fontSize: 25,)),

            ListView.builder(
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,


              itemCount: (data["list"].isNotEmpty) ? data["list"].length : 1,
              itemBuilder: (context, index) {
                return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                    child: (data["list"].isNotEmpty) ? Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text("${index + 1}. ${data["list"][index]}"),
                        CustomButton(
                          onPressed: () {
                            data["list"].removeAt(index);
                            setState(() {});
                          },
                          width: 20,
                          height: 20,
                          text: Text(""),
                          icon: Icon(Icons.delete, size: 18),
                        )
                      ],
                    ) : Center(
                        child: Text(
                            "Add a few steps...",
                            style: GoogleFonts.openSans(fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic)
                        )
                    )
                );
              },

            ),

            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 200, child: TextField(controller: instructionsController, decoration: InputDecoration(hintText: "Instructions", isDense: true, contentPadding: EdgeInsets.only(bottom: 2)), textAlign: TextAlign.center, )),
                SizedBox(width: 6.7),
                CustomButton(backgroundColor: Color(0xFFFFCCCC ), onPressed: () {(instructionsController.text.isNotEmpty) ? {addIngredient(instructionsController.text), instructionsController.clear(), setState(() {})} : print("hey put smth");} , width: 50, height: 30, text: Text("Add"), icon: null, borderRadius: 15,),
              ],
            ),
            SizedBox(height: 5),
            IconButton(onPressed: () => widget.delete(widget.index), icon: Icon(Icons.delete)),
          ]
          ),
        )
    );
  }
  TextEditingController descriptionController = TextEditingController();
  Widget description() {
    descriptionController.addListener(() async {
      widget.data["text"] = descriptionController.text;
    });
    print("${widget.data}    26y234623gagasgsggaga");
    return Padding(padding: EdgeInsets.all(20), child: TextField(
        textAlign: TextAlign.center,
        controller: descriptionController));
  }
  TextEditingController ingredientController = TextEditingController();
  Widget ingredientsList() {
    final data = widget.data; // why not like this
    void addIngredient(x) {
      data["list"].add(x);

    }
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
              padding: EdgeInsets.zero,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,


              itemCount: (data["list"].isNotEmpty) ? data["list"].length : 1,
              itemBuilder: (context, index) {
                return Padding(
                        padding: EdgeInsets.only(left: 10, right: 10, top: 5),
                        child: (data["list"].isNotEmpty) ? Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text("• ${data["list"][index]}"),
                              CustomButton(
                                  onPressed: () {
                                    data["list"].removeAt(index);
                                    setState(() {});
                                  },
                                  width: 20,
                                  height: 20,
                                  text: Text(""),
                                  icon: Icon(Icons.delete, size: 18),
                              )
                            ],
                        ) : Center(
                            child: Text(
                                "Add a few items...",
                                style: GoogleFonts.openSans(fontWeight: FontWeight.w300,
                                    fontStyle: FontStyle.italic)
                            )
                        )
                    );
              },

            ),

            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 200, child: TextField(controller: ingredientController, decoration: InputDecoration(hintText: "Ingredient", isDense: true, contentPadding: EdgeInsets.only(bottom: 2)), textAlign: TextAlign.center, )),
                SizedBox(width: 6.7),
                CustomButton(backgroundColor: Color(0xFFFFCCCC ), onPressed: () {(ingredientController.text.isNotEmpty) ? {addIngredient(ingredientController.text), ingredientController.clear(), setState(() {})} : print("hey put smth");} , width: 50, height: 30, text: Text("Add"), icon: null, borderRadius: 15,),
              ],
            ),
            SizedBox(height: 5),
            IconButton(onPressed: () => widget.delete(widget.index), icon: Icon(Icons.delete)),
          ]
          ),
        )
    );
  }
}
