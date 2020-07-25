import 'dart:math';

import 'package:adios_unite/constants/strings.dart';
import 'package:adios_unite/models/call.dart';
import 'package:adios_unite/models/log.dart';
import 'package:adios_unite/models/user.dart';
import 'package:adios_unite/resources/call_methods.dart';
import 'package:adios_unite/resources/local_db/repository/log_repository.dart';
import 'package:adios_unite/screens/callscreens/videocall_screen.dart';
import 'package:adios_unite/screens/callscreens/voicecall_screen.dart';
import 'package:flutter/material.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dialVideo({User from, User to, context, String callis}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    Log log = Log(
      callerName: from.name,
      callerPic: from.profilePhoto,
      callStatus: CALL_STATUS_DIALLED,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      timestamp: DateTime.now().toString(),
    );

    bool callMade = await callMethods.makeVideoCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      // adds call log to local db
      LogRepository.addLogs(log);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCallScreen(call: call),
          ));
    }
  }

  static dialVoice({User from, User to, context, String callis}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeVoiceCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceCallScreen(call: call),
          ));
}}}