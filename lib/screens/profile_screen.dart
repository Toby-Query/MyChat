import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: Padding(
          padding: EdgeInsets.only(top: mq.height * .05),
          child: FloatingActionButton(
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.updateActiveStatus(false);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacementNamed(
                      context, LoginScreen.routeName);
                });
              });
            },
            child: const Icon(
              Icons.logout,
            ),
          ),
        ),
        appBar: AppBar(
          elevation: 0.5,
          // leading: const Icon(
          //   CupertinoIcons.home,
          // ),
          title: const Text('Profile'),
          actions: const [],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(width: mq.width),
                  SizedBox(height: mq.height * .05),
                  Stack(children: [
                    _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(mq.width * .1),
                            child: Image.file(
                              File(_image!),
                              width: mq.width * .4,
                              height: mq.width * .4,
                              fit: BoxFit.cover,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(mq.width * .1),
                            child: CachedNetworkImage(
                              imageUrl: widget.user.image,
                              width: mq.width * .4,
                              height: mq.width * .4,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                child: Icon(CupertinoIcons.person),
                              ),
                            ),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          _showBottomSheet();
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.black, // Border color
                              width: 1.0, // Border width
                            ),
                          ),
                          child: const Icon(
                            CupertinoIcons.camera,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(height: mq.height * .03),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                  SizedBox(height: mq.height * .05),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (value) {
                      APIs.me.name = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      labelText: 'Name',
                    ),
                    onChanged: (value) {
                      APIs.me.name = value;
                    },
                  ),
                  SizedBox(height: mq.height * .04),
                  TextFormField(
                    onSaved: (value) {
                      APIs.me.about = value ?? '';
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                    initialValue: widget.user.about,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(CupertinoIcons.info_circle),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      labelText: 'About',
                    ),
                    onChanged: (value) {
                      APIs.me.about = value;
                    },
                  ),
                  SizedBox(height: mq.height * .04),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo().then((value) {
                          Dialogs.showSnackBar(
                              context, 'Profile updated successfully');
                          // Navigator.pop(context);
                        });
                        //Navigator.pop(context);
                      }
                    },
                    child: const Text('Update'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return Container(
          height: mq.height * .35,
          color: Colors.transparent,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Choose Profile Photo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.all(mq.width * .03),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.black,
                            width: 5.0,
                          )),
                      child: InkWell(
                        onTap: () async {
                          try {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              log('image path: ${image.path}');
                              setState(() {
                                _image = image.path;
                              });
                              APIs.updateProfilePhoto(File(_image!));
                            } else {
                              log('No image selected');
                            }
                          } catch (e) {
                            log('Error picking image: $e');
                          }
                          Navigator.pop(context);
                          // _pickImage(ImageSource.camera);
                        },
                        child: Icon(CupertinoIcons.photo, size: mq.width * .2),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(mq.width * .03),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: Colors.black,
                            width: 5.0,
                          )),
                      child: InkWell(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? photo = await picker.pickImage(
                              source: ImageSource.camera);
                          if (photo != null) {
                            log('image path: ${photo.path}');
                            setState(() {
                              _image = photo.path;
                            });
                            APIs.updateProfilePhoto(File(_image!));
                          }
                          Navigator.pop(context);
                        },
                        child: Icon(CupertinoIcons.camera, size: mq.width * .2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
