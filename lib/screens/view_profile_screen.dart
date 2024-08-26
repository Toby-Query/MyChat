import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat_user.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import 'login_screen.dart';

class ViewProfileScreen extends StatefulWidget {
  static const routeName = '/viewprofile';
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.5,
          // leading: const Icon(
          //   CupertinoIcons.home,
          // ),
          title: Text(widget.user.name),
          actions: const [],
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Joined On: ${MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt, showYear: true)}',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                SizedBox(width: mq.width),
                SizedBox(height: mq.height * .05),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.width * .1),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    width: mq.width * .4,
                    height: mq.width * .4,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                SizedBox(height: mq.height * .03),
                Text(
                  widget.user.email,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: mq.height * .05),
                Text(
                  widget.user.about,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                ),

                // ElevatedButton(
                //   onPressed: () {},
                //   child: const Text('Update'),
                // )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
