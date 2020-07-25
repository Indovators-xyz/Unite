import 'package:flutter/material.dart';
import 'package:adios_unite/screens/pageviews/chats/widgets/user_circle.dart';
import 'package:adios_unite/widgets/appbar.dart';

class UniteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final title;
  final List<Widget> actions;

  const UniteAppBar({
    Key key,
    @required this.title,
    @required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(
          Icons.notifications,
          color: Colors.black,
        ),
        onPressed: () {},
      ),
      title: (title is String)
          ? Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            )
          : title,
      centerTitle: true,
      actions: actions,
    );
  }

  final Size preferredSize = const Size.fromHeight(kToolbarHeight + 10);
}