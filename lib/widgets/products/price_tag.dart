import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PriceTag extends StatelessWidget {
  // Class Attributes
  final String price;

  PriceTag(this.price) {
    print('[PriceTag] Constructor');
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.5),
        decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Text(
          '\$$price',
          style: TextStyle(color: Colors.white),
        ));
  }
}
