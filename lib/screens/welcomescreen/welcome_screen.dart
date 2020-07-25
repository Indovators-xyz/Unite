import 'package:adios_unite/utils/universal_variables.dart';
import 'package:flutter/material.dart';
import 'package:adios_unite/screens/welcomescreen/utils/my_navigator.dart';
import 'package:adios_unite/screens/welcomescreen/widgets/walkthrough.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  WelcomeScreenState createState() {
    return WelcomeScreenState();
  }
}

class WelcomeScreenState extends State<WelcomeScreen> {
  final PageController controller = new PageController();
  int currentPage = 0;
  bool lastPage = false;

  void _onPageChanged(int page) {
    setState(() {
      currentPage = page;
      if (currentPage == 3) {
        lastPage = true;
      } else {
        lastPage = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFEEEEEE),
      padding: EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Expanded(
            flex: 3,
            child: PageView(
              children: <Widget>[
                Walkthrough(
                  title: "Welcome To Unite",
                  content: "Unite is a premium Video conferencing and chatting application.",
                  imageIcon: Icons.voice_chat,
                ),
                Walkthrough(
                  title: "HD Video Calls",
                  content: "Reach out to your friends and family with real-time high quality Video calls",
                  imageIcon: Icons.videocam
                ),
                Walkthrough(
                  title: "Made in India",
                  content: "Made with ♥ in India",
                  imageIcon: Icons.thumb_up,
                ),
                Walkthrough(
                  title: "Fully Secure",
                  content: "Your privacy and security is of utmost importance to us.",
                  imageIcon: Icons.verified_user,
                ),
              ],
              controller: controller,
              onPageChanged: _onPageChanged,
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                FlatButton(
                  child: Text(lastPage ? "" : "SKIP",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0)),
                  onPressed: () =>
                      lastPage ? null : MyNavigator.goToLogin(context),
                ),
                FlatButton(
                  child: Text(lastPage ? "GOT IT" : "NEXT",
                      style: TextStyle(
                          color: UniversalVariables.orangeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0)),
                  onPressed: () => lastPage
                      ? MyNavigator.goToLogin(context)
                      : controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}