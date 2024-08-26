import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/message.dart';
import 'package:chat_app/screens/view_profile_screen.dart';
import 'package:chat_app/widgets/message_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../chat_user.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({
    super.key,
    required this.user,
  });

  static const routeName = '/chat';

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _list = [];

  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        systemNavigationBarColor: Colors.white,
      ),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            // title: Text(widget.user.name),
            // centerTitle: false,
            automaticallyImplyLeading: false,
            flexibleSpace: _appBar(),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: APIs.getAllMessages(widget.user),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return const SizedBox();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        dynamic _list;
                        if (snapshot.hasData) {
                          QuerySnapshot querySnapshot =
                              snapshot.data as QuerySnapshot;
                          _list = querySnapshot.docs
                              .map((e) => Message.fromJson(
                                  e.data() as Map<String, dynamic>))
                              .toList();
                        } else if (snapshot.hasError) {
                          log('\n error: ${snapshot.error}');
                        }

                        if (_list.isNotEmpty) {
                          return ListView.builder(
                            reverse: true,
                            itemCount: _list.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              //return const CharUserCard();
                              return MessageCard(message: _list[index]);
                            },
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'Send a message',
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
              _chatInput(),
              // SizedBox(
              //   height: 260,
              //   child: EmojiPicker(
              //     textEditingController: _textController,
              //     // scrollController: _scrollController,
              //     config: Config(
              //       height: 256,
              //       checkPlatformCompatibility: true,
              //       emojiViewConfig: EmojiViewConfig(
              //         // Issue: https://github.com/flutter/flutter/issues/28894
              //         emojiSizeMax: 28 *
              //             (foundation.defaultTargetPlatform ==
              //                     TargetPlatform.iOS
              //                 ? 1.2
              //                 : 1.0),
              //       ),
              //       swapCategoryAndBottomBar: false,
              //       skinToneConfig: const SkinToneConfig(),
              //       categoryViewConfig: const CategoryViewConfig(),
              //       bottomActionBarConfig: const BottomActionBarConfig(),
              //       searchViewConfig: const SearchViewConfig(),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          ViewProfileScreen.routeName,
          arguments: widget.user,
        );
      },
      child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            dynamic list = [];
            if (snapshot.hasData) {
              list = snapshot.data!.docs
                      .map((e) => ChatUser.fromJson(e.data()))
                      .toList() ??
                  [];
            } else if (snapshot.hasError) {
              log('\n error: ${snapshot.error}');
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.width * .03),
                  child: CachedNetworkImage(
                    imageUrl: widget.user.image,
                    width: mq.width * .1,
                    height: mq.width * .1,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive),
                    ),
                  ],
                ),
                // const Spacer(),
                // IconButton(
                //   onPressed: () {},
                //   icon: const Icon(Icons.more_vert),
                // ),
              ],
            );
          }),
    );
  }

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: mq.width * .01, vertical: mq.height * .02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              color: Colors.white,
              elevation: 3,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Row(
                        children: [
                          // IconButton(
                          //   onPressed: () {
                          //     setState(() {
                          //       _showEmoji = !_showEmoji;
                          //     });
                          //   },
                          //   icon: Icon(CupertinoIcons.smiley),
                          // ),
                          // IconButton(
                          //   onPressed: () {},
                          //   icon: const Icon(Icons.attach_file),
                          // ),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final List<XFile> images =
                                  await picker.pickMultiImage();

                              if (images.isNotEmpty) {
                                // log('image path: ${images.path}');
                                for (final image in images) {
                                  await APIs.sendChatImage(
                                      widget.user, File(image.path));
                                }
                              }
                            },
                            icon: const Icon(CupertinoIcons.photo),
                          ),
                          IconButton(
                            onPressed: () async {
                              final ImagePicker picker = ImagePicker();
                              final XFile? photo = await picker.pickImage(
                                  source: ImageSource.camera);
                              if (photo != null) {
                                log('image path: ${photo.path}');
                                await APIs.sendChatImage(
                                    widget.user, File(photo.path));
                              }
                            },
                            icon: const Icon(CupertinoIcons.camera),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                }
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
