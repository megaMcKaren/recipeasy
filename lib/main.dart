// Based on https://dartpad.dev/?id=d57c6c898dabb8c6fb41018588b8cf73
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'sign_up.dart';
import 'firebase_options.dart';

const Color darkBlue = Color.fromARGB(255, 18, 32, 47);

const messageLimit = 30;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
  } catch (e, st) {
    print(e);
    print(st);
  }

  // The first step to using Firebase is to configure it so that our code can
  // find the Firebase project on the servers. This is not a security risk, as
  // explained here: https://stackoverflow.com/a/37484053
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final DateFormat formatter = DateFormat('MM/dd HH:mm:SS');

  MyApp({super.key});

  bool signedIn = false;

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      signedIn = true;
    } else {
      signedIn = false;
    }

    return MaterialApp(
      // initialRoute: '/home',
      // routes: {'/home': (context) => HomeScreen()},
      debugShowCheckedModeBanner: false,
      // Ternary operator (?)
      // (condition) ? true stuff : false stuff
      home: (signedIn) ? HomeScreen() : SignUp(),
    );
  }
}
