import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'sign_up.dart';
import 'home.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: const Color(0xFFCDCDFF),
          child: Center(
              child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffffffffff),
                      borderRadius: BorderRadius.circular(37.5)),
                  width: 270,
                  height: 320,
                  child: Form(
                    //key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Sign in",
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
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                try {
                                  FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                      email: emailController.text,
                                      password:
                                      passwordController.text);

                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              HomeScreen()));
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    print('No user found for that email.');
                                  } else if (e.code == 'wrong-password') {
                                    print(
                                        'Wrong password provided for that user.');
                                  } else {
                                    print("here");
                                  }
                                }
                              },
                              child: const Text('Log in'),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignUp()));
                              },
                              child: const Text("Don't have an account"),
                            ),
                          ],
                        ),
                      ))))),
    );
  }
}
