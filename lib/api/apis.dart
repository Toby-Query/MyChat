import 'dart:developer';
import 'dart:io';
import 'package:chat_app/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../message.dart';

class APIs {
  static FirebaseAuth auth = FirebaseAuth.instance;
  static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static FirebaseStorage storage = FirebaseStorage.instance;
  static get user => auth.currentUser!;
  static late ChatUser me;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((value) {
      if (value != null) {
        me.pushToken = value;
        //updateUserInfo();
        log(me.pushToken);
      }
    });
  }

  static Future<bool> userExists() async {
    return await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) => value.exists);
  }

  static Future<void> updateProfilePhoto(File image) async {
    log('I was called');
    final ext = image.path.split('.').last;
    final ref = storage
        .ref()
        .child('profile_photos/${auth.currentUser!.uid}.$ext')
        .child(auth.currentUser!.uid);
    await ref.putFile(image);

    me.image = await ref.getDownloadURL();
    log(me.image);
    updateUserInfo();
  }

  static Future<void> getSelfInfo() async {
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) async {
      if (await userExists()) {
        me = ChatUser.fromJson(value.data()!);
        await getFirebaseMessagingToken();
        APIs.updateActiveStatus(true);
      } else {
        createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> updateUserInfo() async {
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update(me.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser user) {
    return APIs.firestore
        .collection('users')
        .where('id', isEqualTo: user.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool status) async {
    await APIs.firestore.collection('users').doc(auth.currentUser!.uid).update({
      'is_online': status,
      'last_active': DateTime.now().microsecondsSinceEpoch.toString(),
      'push_token': me.pushToken
    });
  }

  static createUser() async {
    final ChatUser chatUser = ChatUser(
      id: APIs.auth.currentUser!.uid,
      name: APIs.auth.currentUser!.displayName!.toString(),
      email: APIs.auth.currentUser!.email!.toString(),
      image: APIs.auth.currentUser!.photoURL!.toString(),
      about: '',
      createdAt: DateTime.now().millisecondsSinceEpoch.toString(),
      pushToken: '',
      isOnline: false,
      lastActive: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .set(chatUser.toJson());
  }

  static Future<void> updateUserStatus(bool status) async {
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'status': status});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsersExceptMe() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: APIs.user.id)
        .snapshots();
  }

  static Future<void> updateLastOnline() async {
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'lastOnline': DateTime.now()});
  }

  static Future<void> updateToken(String fcmToken) async {
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'fcmToken': fcmToken});
  }

  static Future<void> updateDisplayName(String name) async {
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'name': name});
  }

  static Future<void> updateEmail(String email) async {
    await APIs.firestore
        .collection('users')
        .doc(auth.currentUser!.uid)
        .update({'email': email});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserById(String uid) {
    return APIs.firestore
        .collection('users')
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserByUserName(
      String name) {
    return APIs.firestore
        .collection('users')
        .where('name', isEqualTo: name)
        .snapshots();
  }

  //chat screen apis

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(ChatUser user, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final message = Message(
      msg: msg,
      toId: user.id,
      read: '',
      type: type,
      sent: time,
      fromId: APIs.user.uid,
    );
    await firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .doc(time)
        .set(message.toJson());
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    return firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Future<void> sendChatImage(ChatUser user, File image) async {
    final ext = image.path.split('.').last;
    final ref = storage
        .ref()
        .child('chat_images/${getConversationID(user.id)}.$ext')
        .child(DateTime.now().millisecondsSinceEpoch.toString());

    await ref.putFile(image);

    final imageUrl = await ref.getDownloadURL();

    await sendMessage(user, imageUrl, Type.image);
  }

  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) storage.refFromURL(message.msg).delete();
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for getting all users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    log('\nUserIds: $userIds');

    return firestore
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }
}
