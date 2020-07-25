import 'package:adios_unite/constants/strings.dart';
import 'package:adios_unite/models/call.dart';
import 'package:adios_unite/models/log.dart';
import 'package:adios_unite/resources/call_methods.dart';
import 'package:adios_unite/resources/local_db/repository/log_repository.dart';
import 'package:adios_unite/screens/callscreens/videocall_screen.dart';
import 'package:adios_unite/screens/chatscreens/widgets/cached_image.dart';
import 'package:adios_unite/utils/permissions.dart';
import 'package:adios_unite/utils/universal_variables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';



class PickupScreen extends StatefulWidget {
  final Call call;

  PickupScreen({
    @required this.call,
  });

  @override
  _PickupScreenState createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  final CallMethods callMethods = CallMethods();

  bool isCallMissed = true;


  // initialize and store log in local db
 addToLocalStorage({@required String callStatus}) {
    Log log = Log(
      callerName: widget.call.callerName,
      callerPic: widget.call.callerPic,
      receiverName: widget.call.receiverName,
      receiverPic: widget.call.receiverPic,
      timestamp: DateTime.now().toString(),
      callStatus: callStatus,
    );
    // adds the data to db
    LogRepository.addLogs(log);
  }

  @override
  void dispose() {
    if (isCallMissed) {
      addToLocalStorage(callStatus: CALL_STATUS_MISSED);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    FlutterRingtonePlayer.playRingtone();
    return Scaffold(
      body: Container(        
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 100),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Unite Call",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: UniversalVariables.orangeColor,
              ),
            ),
            SizedBox(height: 50),
            CachedImage(
              widget.call.callerPic,
              isRound: true,
              radius: 180,
            ),
            SizedBox(height: 15),
            Text(
              widget.call.callerName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 75),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.call_end),
                  color: Colors.redAccent,
                  iconSize: 35,
                  onPressed: () async {
                    isCallMissed = false;
                    addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                    await callMethods.endCall(call: widget.call);
                    FlutterRingtonePlayer.stop();
                  },
                ),
                SizedBox(width: 25),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Colors.green,
                  iconSize: 35,
                  onPressed: () async {
                      isCallMissed = false;
                      addToLocalStorage(callStatus: CALL_STATUS_RECEIVED);
                      await Permissions.cameraandmicrophonePermissionsGranted()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VideoCallScreen(call: widget.call),
                              ),
                            )
                          : FlutterRingtonePlayer.stop();
                  }),
              ],
            ),
          ],
        ),
        
      ),
      
    );
   
  }
}

