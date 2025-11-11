import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'home.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final db = FirebaseFirestore.instance;

  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<bool> CreateUser() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      final userData = <String, dynamic>{
        "bgImg":
        "https://static.vecteezy.com/system/resources/previews/060/467/587/non_2x/anonymous-person-wearing-suit-and-fedora-hat-silhouette-graphic-illustration-vector.jpg",
        "email": emailController.text,
        "username": usernameController.text, //"followers": 0,
        "pfp":
        "https://static.vecteezy.com/system/resources/previews/060/467/587/non_2x/anonymous-person-wearing-suit-and-fedora-hat-silhouette-graphic-illustration-vector.jpg",
        "followers": [],
        "following": [],
        // "friends": [],
        "bio": "",
      };

      await db
          .collection("profiles")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set((userData));

      return true;
    } catch (error) {
      print(error);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: const Color(0xFF123456),
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffffffffff),
                      borderRadius: BorderRadius.circular(37.5)),
                  width: 250,
                  height: 400,
                  child: Form(
                    //key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Sign up",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                )),
                            TextFormField(
                              controller: emailController,

                              decoration: const InputDecoration(
                                  hintText: 'Enter your email'),
                              // validator: (String? value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter some text';
                              //   }
                              //   return null;
                              // },
                            ),
                            TextFormField(
                              controller: usernameController,

                              decoration: const InputDecoration(
                                  hintText: 'Enter your new username'),
                              // validator: (String? value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter some text';
                              //   }
                              //   return null;
                              // },
                            ),
                            TextFormField(
                              obscureText: true,

                              controller: passwordController,

                              decoration: const InputDecoration(
                                  hintText: 'Enter your password'),
                              // validator: (String? value) {
                              //   if (value == null || value.isEmpty) {
                              //     return 'Please enter some text';
                              //   }
                              //   return null;
                              // },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (await CreateUser()) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                  const HomeScreen()));
                                        }
                                      },
                                      child: const Text('Submit'),
                                    ),
                                    SizedBox(height: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                const SignIn()));
                                      },
                                      child: const Text('Already have an account'),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ))))),
    );
  }
}
