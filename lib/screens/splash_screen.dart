import 'dart:developer';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const routeName = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (APIs.auth.currentUser != null) {
        log('\nUser: ${APIs.auth.currentUser}');
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      } else {
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          automaticallyImplyLeading: false,
          //title: const Text('Welcome to MyChat'),
        ),
        body: Stack(
          children: [
            Positioned(
              width: mq.width * .5,
              left: mq.width * .25,
              top: mq.height * .15,
              child: Image.asset('assets/appCon.png'),
            ),
          ],
        ));
  }
}
