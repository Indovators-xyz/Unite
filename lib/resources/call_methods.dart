import 'package:adios_unite/constants/strings.dart';
import 'package:adios_unite/models/call.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class CallMethods {
  final CollectionReference callCollection =
      Firestore.instance.collection(CALL_COLLECTION);

  Stream<DocumentSnapshot> callStream({String uid}) =>
      callCollection.document(uid).snapshots();

  Future<bool> makeVideoCall({Call call}) async {
    try {
      call.hasDialled = true;
      call.isCall = "video";
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      call.isCall = "video";
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await callCollection.document(call.callerId).setData(hasDialledMap);
      await callCollection.document(call.receiverId).setData(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> makeVoiceCall({Call call}) async {
    try {
      call.hasDialled = true;
      call.isCall = "audio";
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      call.isCall = "audio";
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await callCollection.document(call.callerId).setData(hasDialledMap);
      await callCollection.document(call.receiverId).setData(hasNotDialledMap);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> endCall({Call call}) async {
    FlutterRingtonePlayer.stop();
    try {
      await callCollection.document(call.callerId).delete();
      await callCollection.document(call.receiverId).delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}