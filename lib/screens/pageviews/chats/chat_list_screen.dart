import 'package:adios_unite/models/contact.dart';
import 'package:adios_unite/provider/user_provider.dart';
import 'package:adios_unite/resources/auth_methods.dart';
import 'package:adios_unite/resources/chat_methods.dart';
import 'package:adios_unite/screens/callscreens/pickup/pickup_layout.dart';
import 'package:adios_unite/screens/pageviews/chats/widgets/contact_view.dart';
import 'package:adios_unite/screens/pageviews/chats/widgets/new_chat_button.dart';
import 'package:adios_unite/screens/pageviews/chats/widgets/quiet_box.dart';
import 'package:adios_unite/screens/pageviews/chats/widgets/user_circle.dart';
import 'package:adios_unite/utils/universal_variables.dart';
import 'package:adios_unite/widgets/appbar.dart';
import 'package:adios_unite/widgets/unite_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.whiteColor,
        appBar: UniteAppBar(
          title: UserCircle(),
          actions: <Widget>[
          IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pushNamed(context, "/search_screen");
          },
          ),
          IconButton(
          icon: Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
          onPressed: () {},
          ),
          ],
        ),
        floatingActionButton: NewChatButton(),
        body: ChatListContainer(),
      ),
    );
  }
}

class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return Container(
      child: StreamBuilder<QuerySnapshot>(
          stream: _chatMethods.fetchContacts(
            userId: userProvider.getUser.uid,
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var docList = snapshot.data.documents;

              if (docList.isEmpty) {
                return QuietBox(
                  heading: "This is where all the chats are listed",
                  subtitle: "Search for your friends and family to start calling or chatting with them",
                );
              }
              return ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: docList.length,
                itemBuilder: (context, index) {
                  Contact contact = Contact.fromMap(docList[index].data);

                  return ContactView(contact);
                },
              );
            }

            return Center(child: CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(UniversalVariables.orangeColor))
            );
          }),
    );
  }
}