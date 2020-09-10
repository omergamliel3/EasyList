import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:my_app/scoped-models/main.dart';

class LogoutListTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ListTile(
        leading: Icon(Icons.exit_to_app),
        title: Text('Log Out'),
        onTap: () {
          // logout function
          model.logout();
        },
      );
    });
  }
}
