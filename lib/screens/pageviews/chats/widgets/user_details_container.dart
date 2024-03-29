import 'package:adios_unite/utils/universal_variables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:adios_unite/enum/user_state.dart';
import 'package:adios_unite/models/user.dart';
import 'package:adios_unite/provider/user_provider.dart';
import 'package:adios_unite/resources/auth_methods.dart';
import 'package:adios_unite/screens/chatscreens/widgets/cached_image.dart';
import 'package:adios_unite/screens/login_screen.dart';
import 'package:adios_unite/widgets/appbar.dart';

class UserDetailsContainer extends StatelessWidget {
  final AuthMethods authMethods = AuthMethods();

  @override 
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    signOut() async {
      final bool isLoggedOut = await AuthMethods().signOut();
      if (isLoggedOut) {
        // set userState to offline as the user logs out'
        authMethods.setUserState(
          userId: userProvider.getUser.uid,
          userState: UserState.Offline,
        );

        // move the user to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    }

    return Container(
      margin: EdgeInsets.only(top:25),
      child: Column(
        children: <Widget>[
          CustomAppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
                ),
              onPressed: () => Navigator.maybePop(context),
            ),
            centerTitle: true,
            title: Text(
              "My Profile",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => signOut(),
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          UserDetailsBody(),
        ],
      ),
    );
  }
}

class UserDetailsBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final User user = userProvider.getUser;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          CachedImage(
            user.profilePhoto,
            isRound: true,
            radius: 50,
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                user.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: UniversalVariables.orangeColor,
                ),
              ),
              SizedBox(height: 10),
              Text(
                user.email,
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}