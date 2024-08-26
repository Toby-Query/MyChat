import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/api/apis.dart';
import 'package:chat_app/chat_user.dart';
import 'package:chat_app/message.dart';
import 'package:chat_app/widgets/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../screens/view_profile_screen.dart';

class ChartUserCard extends StatefulWidget {
  final ChatUser user;
  const ChartUserCard({super.key, required this.user});

  @override
  State<ChartUserCard> createState() => _ChartUserCardState();
}

class _ChartUserCardState extends State<ChartUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/chat',
            arguments: widget.user,
          );
        },
        child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final list = snapshot.data!.docs
                    .map((e) => Message.fromJson(e.data()))
                    .toList();
                if (list.isNotEmpty) {
                  _message = list[0];
                }
              } else if (snapshot.hasError) {
                log('\n error: ${snapshot.error}');
              }

              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(mq.width * .03),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(user: widget.user));
                      },
                      child: CachedNetworkImage(
                        imageUrl: widget.user.image,
                        width: mq.width * .12,
                        height: mq.width * .12,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) =>
                            const CircleAvatar(
                          child: Icon(CupertinoIcons.person),
                        ),
                      ),
                    ),
                  ),
                  title: Text(widget.user.name),
                  subtitle: Text(
                    _message != null
                        ? (_message!.msg.isNotEmpty
                            ? _message!.type == Type.text
                                ? _message!.msg
                                : 'Photo'
                            : widget.user.about)
                        : widget.user.about,
                    maxLines: 1,
                  ),
                  trailing: _message == null
                      ? null
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: widget.user.isOnline
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            )
                          : Text(
                              MyDateUtil.getLastMessageTime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(color: Colors.grey),
                            ),
                  // trailing: const Text(
                  //   '12:00',
                  //   style: TextStyle(color: Colors.grey),
                  // ),
                ),
              );
            }),
      ),
    );
  }
}
