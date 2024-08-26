import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/helper/my_date_util.dart';
import 'package:chat_app/message.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: _showBottomSheet,
      child: APIs.user.uid != widget.message.fromId
          ? _blueMessage()
          : _greenMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      width: mq.width * .7,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        Row(
          children: [
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black26,
              ),
            ),
            // const SizedBox(width: 5),
            // const Icon(
            //   Icons.done_all,
            //   size: 20,
            //   color: Colors.blue,
            // ),
          ],
        ), //time
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            if (widget.message.read.isNotEmpty)
              const Icon(
                Icons.done_all,
                size: 20,
                color: Colors.green,
              ),
            const SizedBox(width: 5),
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black26,
              ),
            ),
          ],
        ),
        Container(
          alignment: Alignment.centerRight,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: widget.message.type == Type.text
                ? Text(
                    widget.message.msg,
                    style: const TextStyle(color: Colors.white),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: widget.message.msg,
                      width: mq.width * .7,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(
                          Icons.image,
                          size: 70,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return ListView(
          children: [
            // widget.message.type == Type.text
            //     ? ListTile(
            //         leading: const Icon(
            //           Icons.copy,
            //           color: Colors.blue,
            //         ),
            //         title: const Text('Copy'),
            //         onTap: () {
            //           Clipboard.setData(
            //               ClipboardData(text: widget.message.msg));
            //           Navigator.pop(context);
            //         },
            //       )
            //     : const SizedBox(),
            // widget.message.type == Type.text
            //     ? const SizedBox()
            //     : ListTile(
            //         leading: const Icon(
            //           Icons.share,
            //           color: Colors.blue,
            //         ),
            //         title: const Text('Share'),
            //         onTap: () {
            //           // Share.share(widget.message.msg);
            //           Navigator.pop(context);
            //         },
            //       ),
            widget.message.type == Type.text
                ? _optionItem(
                    icon: Icon(Icons.copy, color: Colors.blue),
                    title: 'Copy Text',
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: widget.message.msg));
                      Navigator.pop(context);
                      Dialogs.showSnackBar(
                        context,
                        'Text Copied',
                      );
                    })
                : _optionItem(
                    icon: Icon(Icons.file_download, color: Colors.blue),
                    title: 'Save Image',
                    onTap: () async {
                      await Dio().download(
                        widget.message.msg,
                        'images/${widget.message.sent}.jpg',
                      );
                      ImageGallerySaver.saveFile(widget.message.msg);
                      Dialogs.showSnackBar(
                        context,
                        'Image Downloaded',
                      );
                      Navigator.pop(context);
                    }),
            if (widget.message.type == Type.text &&
                APIs.user.uid == widget.message.fromId)
              _optionItem(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  title: 'Edit',
                  onTap: () {
                    Navigator.pop(context);
                  }),
            _optionItem(
                icon: Icon(Icons.delete, color: Colors.red),
                title: 'Delete',
                onTap: () {
                  APIs.deleteMessage(
                    widget.message,
                  );
                  Navigator.pop(context);
                }),

            const Divider(
              height: 2,
              thickness: 2,
            ),
            _optionItem(
                icon: Icon(Icons.done, color: Colors.blue),
                title: 'Sent At: ${MyDateUtil.getLastMessageTime(
                  context: context,
                  time: widget.message.sent,
                )}',
                onTap: () {
                  Navigator.pop(context);
                }),
            _optionItem(
                icon: Icon(Icons.done_all, color: Colors.blue),
                title: widget.message.read.isEmpty
                    ? 'Not Read yet'
                    : 'Read At: ${MyDateUtil.getLastMessageTime(
                        context: context,
                        time: widget.message.read,
                      )}',
                onTap: () {
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }
}

class _optionItem extends StatelessWidget {
  final Icon icon;
  final String title;
  final VoidCallback onTap;
  const _optionItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(left: 15, top: 25, bottom: 25),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '     $title',
              style: const TextStyle(fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
      ),
    );
  }
}
