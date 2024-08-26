import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../chat_user.dart';
import '../main.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});
  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(10),
      backgroundColor: Colors.white,
      content: SizedBox(
        height: mq.width * .9,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: user.image,
                  height: mq.width * .8,
                  width: mq.width * .8,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(CupertinoIcons.person),
                ),
              ),
            ),
            // const SizedBox(
            //   height: 10,
            // ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),

            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    ViewProfileScreen.routeName,
                    arguments: user,
                  );
                },
                icon: const Icon(Icons.info_outline),
              ),
            )
            // const SizedBox(
            //   height: 10,
            // ),
            // Text(
            //   user.email,
            //   style: const TextStyle(
            //     fontWeight: FontWeight.bold,
            //     fontSize: 20,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
