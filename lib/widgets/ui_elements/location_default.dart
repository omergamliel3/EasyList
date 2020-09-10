import 'package:flutter/material.dart';

class LocationDefault extends StatelessWidget {
  
  // Class Attributes
  final String locationText;

  // LocationDefault Constcuctor
  LocationDefault(this.locationText) {
    print('[LocationDefault] Constructor');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
            padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
            // DecoretedBox for styling the text location
            decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).accentColor, width: 2.0),
                borderRadius: BorderRadius.circular(6.0)),
            child: Text(locationText),
          );
  }
  
}