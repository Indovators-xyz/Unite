import 'package:flutter/material.dart';

class MyNavigator {
  static void goToLogin(BuildContext context) {
    Navigator.pushNamed(context, "/login");
  }

  static void goToWelcome(BuildContext context) {
    Navigator.pushNamed(context, "/welcome");
  }
}




