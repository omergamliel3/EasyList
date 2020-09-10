import 'package:flutter/material.dart';

class Listile extends StatelessWidget {

  // Class Attributes 
  final Icon icon;
  final String text;
  final String subtitle;
  final String trailing;
  
  // Listile Constructor
  Listile({this.icon, this.text, this.subtitle, this.trailing}) {
    print("[Listile widget] Constructor");
  }

  @override
  Widget build(BuildContext context) {
    print('Listile build()');
    return _buildListTileContainer(icon, text, subtitle, trailing, context);
  }

   // _buildListTileContainer method
  Container _buildListTileContainer(Icon icon, String text,
      String subtitle, String trailing, BuildContext context) {
    Container listTileContainer = Container(
      // container style
      margin: EdgeInsets.all(10.0),
      color: Theme.of(context).primaryColor,
      alignment: Alignment.center,
      child: ListTile(
        leading: Icon(icon.icon),
        title: Text(text),
        subtitle: Text(subtitle),
        trailing: Text(trailing),
        onLongPress: () { print('Long Press $text'); } ,
        onTap: () { print('Tap $text'); } ,
      ),
    );
    return listTileContainer;
  }

}