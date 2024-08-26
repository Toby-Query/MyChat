import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleBtnClick() {
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((value) async {
      Navigator.pop(context);
      if (value != null) {
        log('\nUser: ${value.user}');
        log('\nUserAdditionalInfo: ${value.additionalUserInfo}');

        if (await APIs.userExists()) {
          Navigator.pushReplacementNamed(context, HomeScreen.routeName);
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacementNamed(context, HomeScreen.routeName);
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      await InternetAddress.lookup('google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      log('\n_signInWithGoogle: $e');
      Dialogs.showSnackBar(context, 'Check internet connection, $e');
      return null;
    }
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
            Positioned(
              bottom: mq.height * .28,
              width: mq.width,
              child: const Text(
                'Sign in with Google',
                textAlign: TextAlign.center,
              ),
            ),
            Positioned(
              bottom: mq.height * .15,
              left: mq.width * .4,
              width: mq.width * .2,
              child: IconButton(
                style: ButtonStyle(
                  shape: WidgetStateProperty.all(const CircleBorder(
                    side: BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  )),
                ),
                icon: Image.asset('assets/google.png'),
                onPressed: () {
                  _handleGoogleBtnClick();
                },
              ),
            ),
          ],
        ));
  }
}
