import 'package:adios_unite/resources/auth_methods.dart';
import 'package:adios_unite/screens/home_screen.dart';
import 'package:adios_unite/utils/universal_variables.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final AuthMethods _authMethods = AuthMethods();

  bool isLoginPressed = false;

  @override
  Widget build(BuildContext context) {
    
    Size size = MediaQuery.of(context).size;
      return Scaffold(
        backgroundColor: UniversalVariables.whiteColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: size.height * 0.05),
            Image.asset(
              "assets/unite_logo.png",
              height: size.height * 0.45,
            ),
         
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: loginButton(),
              ),
            ),

            ClipRRect(
            borderRadius: BorderRadius.circular(29),
            child: FlatButton(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          color: UniversalVariables.orangeColor,
          onPressed: () => launch('https://www.indovators.xyz/privacy-policy'),
          child: Text("Privacy Policy", style: TextStyle(color: Colors.white,),
          ),
          ),
          ),
          isLoginPressed
            ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(UniversalVariables.orangeColor)
              ),
              )
            : Container(),
          
          ],
          
          ) ,
       
      );
      
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: UniversalVariables.orangeColor,
      highlightColor: UniversalVariables.blackColor,
        child: FlatButton(
      padding: EdgeInsets.all(35),
      child: Text(
        "LOGIN",
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,)
      ),
      onPressed: ()=>performLogin(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    );
  }

  void performLogin(){
    print("trying to perform login");

    setState(() {
      isLoginPressed = true;
    });

    _authMethods.signIn().then((FirebaseUser user) {
      if (user != null) {
        authenticateUser(user);
      }
      else {
        print("There was an error");
      }
    });
  }

  void authenticateUser(FirebaseUser user){
     _authMethods.authenticateUser(user).then((isNewUser) {

      setState(() {
        isLoginPressed = false;
      });

      if(isNewUser){
        _authMethods.addDataToDb(user).then((value){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
            return HomeScreen();
            }));
        });
      }  else{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
            return HomeScreen();
          }));
      }
    });
  }

}