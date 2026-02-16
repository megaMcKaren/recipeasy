import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/components/custom_button.dart';
import 'package:social_media_app/sign_in.dart';
import 'package:social_media_app/sign_up.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFDDDDFF),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cake, size: 30,),
              SizedBox(width: 10),
              Text("Welcome to Recipeasy!", style: GoogleFonts.allertaStencil(fontSize: 25)),
            ]
          ),

          SizedBox(height: 20),

          CustomButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUp()));}, width: MediaQuery.of(context).size.width * 0.7, height: 35, text: Text("Create an Account"), icon: Icon(Icons.add)),

          SizedBox(height: 15),

          CustomButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (_) => const SignIn()));}, width: MediaQuery.of(context).size.width * 0.7, height: 35, text: Text("Login to an Existing Account"), icon: Icon(Icons.login)),
        ],
      )
    );
  }
}
