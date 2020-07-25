import 'package:adios_unite/models/log.dart';
import 'package:adios_unite/resources/local_db/repository/log_repository.dart';
import 'package:adios_unite/screens/callscreens/pickup/pickup_layout.dart';
import 'package:adios_unite/screens/pageviews/logs/widgets/floating_column.dart';
import 'package:adios_unite/screens/pageviews/logs/widgets/log_list_container.dart';
import 'package:adios_unite/utils/universal_variables.dart';
import 'package:adios_unite/widgets/unite_appbar.dart';
import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PickupLayout(
      scaffold: Scaffold(
        backgroundColor: UniversalVariables.whiteColor,
        appBar: UniteAppBar(
          title: "Calls",
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () => Navigator.pushNamed(context, "/search_screen"),
            ),
          ],
        ),
        floatingActionButton: FloatingColumn(),
        body: Padding(
          padding: EdgeInsets.only(left: 15),
          child: LogListContainer(),
        ),
      ),
    );
  }
}