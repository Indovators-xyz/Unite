import 'dart:io';

import 'package:adios_unite/constants/strings.dart';
import 'package:adios_unite/enum/view_state.dart';
import 'package:adios_unite/models/message.dart';
import 'package:adios_unite/models/user.dart';
import 'package:adios_unite/provider/image_upload_provider.dart';
import 'package:adios_unite/resources/auth_methods.dart';
import 'package:adios_unite/resources/chat_methods.dart';
import 'package:adios_unite/resources/storage_methods.dart';
import 'package:adios_unite/screens/callscreens/pickup/pickup_layout.dart';
import 'package:adios_unite/screens/chatscreens/widgets/cached_image.dart';
import 'package:adios_unite/utils/call_utilities.dart';
import 'package:adios_unite/utils/permissions.dart';
import 'package:adios_unite/utils/universal_variables.dart';
import 'package:adios_unite/utils/utilities.dart';
import 'package:adios_unite/widgets/appbar.dart';
import 'package:adios_unite/widgets/custom_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final User receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

   TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  final AuthMethods _authMethods = AuthMethods();

  ScrollController _listScrollController = ScrollController();

  ImageUploadProvider _imageUploadProvider;

  User sender;

  String _currentUserId;

  bool isWriting = false;

  bool showEmojiPicker = false;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        sender = User(
          uid: user.uid,
          name: user.displayName,
          profilePhoto: user.photoUrl,
        );
      });
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterRingtonePlayer.stop();

    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.whiteColor,
        appBar: customAppBar(context),
        body: Column(
          children: <Widget>[
            Flexible(
              child: messageList(),
            ),
            _imageUploadProvider.getViewState == ViewState.LOADING
                ? Container(
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(right: 15),
                  child: CircularProgressIndicator(
                    valueColor: new AlwaysStoppedAnimation<Color>(UniversalVariables.orangeColor),
                  ),
                )
                : Container(),
            chatControls(),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.whiteColor,
      indicatorColor: UniversalVariables.orangeColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

   Widget messageList() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection(MESSAGES_COLLECTION)
          .document(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(UniversalVariables.orangeColor),
          ));
        }

        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _listScrollController.animateTo(
        //     _listScrollController.position.minScrollExtent,
        //     duration: Duration(milliseconds: 250),
        //     curve: Curves.easeInOut,
        //   );
        // });

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.documents.length,
          itemBuilder: (context, index) {
            // mention the arrow syntax if you get the time
            return chatMessageItem(snapshot.data.documents[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

   Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        color: UniversalVariables.greyColor,
        borderRadius: BorderRadius.only(
          topLeft: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
            message.message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            ),
          )
        : message.photoUrl != null
            ? CachedImage(
                message.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              )
            : Text("Url was null");
  }

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
        gradient: UniversalVariables.fabGradient,
        borderRadius: BorderRadius.only(
          bottomRight: messageRadius,
          topRight: messageRadius,
          bottomLeft: messageRadius,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

    void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

    addMediaModal(context) {
      showModalBottomSheet(
          context: context,
          elevation: 0,
          backgroundColor: UniversalVariables.whiteColor,
          builder: (context) {
            return Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        child: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Share and tools",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ListView(
                    children: <Widget>[
                      ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Videos",
                        icon: Icons.perm_media,
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
                      ModalTile(
                        title: "File",
                        subtitle: "Share files",
                        icon: Icons.description),
                    ModalTile(
                        title: "Contact",
                        subtitle: "Share contacts",
                        icon: Icons.contacts),
                    ModalTile(
                        title: "Location",
                        subtitle: "Share a location",
                        icon: Icons.location_on),
                    ModalTile(
                        title: "Schedule Call",
                        subtitle: "Schedule an Unite call with reminders",
                        icon: Icons.schedule),
                    ModalTile(
                        title: "Create Poll",
                        subtitle: "Create a poll",
                        icon: Icons.poll)
                    ],
                  ),
                ),
              ],
            );
          });
    }

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _chatMethods.addMessageToDb(_message, sender, widget.receiver);
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textFieldController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer(),
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  onChanged: (val) {
                    (val.length > 0 && val.trim() != "")
                        ? setWritingTo(true)
                        : setWritingTo(false);
                  },
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(
                      color: UniversalVariables.greyColor,
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    fillColor: UniversalVariables.lightgreyColor,
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.insert_emoticon),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.keyboard_voice),
                ),
          isWriting ? Container() : GestureDetector(
            onTap: () => pickImage(source: ImageSource.camera),
            child: Icon(Icons.camera_alt),
            ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 20,
                    ),
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, 
        color: Colors.black,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
        ),
        centerTitle: false,
        title: Text(
          widget.receiver.name,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.video_call,
              color: Colors.black,
            ),
            onPressed: () async =>
              await Permissions.cameraandmicrophonePermissionsGranted()
                  ? CallUtils.dialVideo(
                      from: sender,
                      to: widget.receiver,
                      context: context,
                      callis: "video")
                  : {},
          ),
          IconButton(
            icon: Icon(
              Icons.phone,
              color: Colors.black,
            ),
           onPressed: () async =>
              await Permissions.microphonePermissionsGranted()
                  ? CallUtils.dialVoice(
                      from: sender,
                      to: widget.receiver,
                      context: context,
                      callis: "audio")
                  : {},
          ),
        ]
    );
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Function onTap;

  const ModalTile({
    @required this.title,
    @required this.subtitle,
    @required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        mini: false,
        onTap: onTap,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: UniversalVariables.lightgreyColor,
          ),
          padding: EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Color(0xfff94301),
            size: 38,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: UniversalVariables.greyColor,
            fontSize: 14,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}