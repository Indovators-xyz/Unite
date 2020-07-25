import 'package:adios_unite/provider/image_upload_provider.dart';
import 'package:adios_unite/provider/user_provider.dart';
import 'package:adios_unite/resources/auth_methods.dart';
import 'package:adios_unite/screens/home_screen.dart';
import 'package:adios_unite/screens/login_screen.dart';
import 'package:adios_unite/screens/search_screen.dart';
import 'package:adios_unite/screens/welcomescreen/welcome_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthMethods _authMethods = AuthMethods();


 @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: "ADIOS Unite",
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          '/search_screen': (context) => SearchScreen(),
          "/welcome": (context) => WelcomeScreen(),
          "/login": (context) => LoginScreen(),
        },
         theme: ThemeData(brightness: Brightness.light),
        home: FutureBuilder(
          future: _authMethods.getCurrentUser(),
          builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.hasData) {
              return HomeScreen();
            } else {
              return WelcomeScreen();
            }
          },
        ),
      ),
    );
  }
}
