import 'package:flutter/material.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class ProductFAB extends StatefulWidget {
  // Class Attributes
  final Product product;

  @override
  _ProductFABState createState() => _ProductFABState();

  // ProductFAB Constructor
  ProductFAB(this.product) {
    print('[ProductFAB] Constructor');
  }
}

// launch Url mail
void _launchURL(String mail, String name) async {
  final url =
      'mailto:$mail?subject=Product&body=I%20want%20to%20contact%20about%20your%20product%20$name';
  if (await canLaunch(url)) {
    await launch(url); // launch the url
  } else {
    // if there was an error
    throw 'Could not launch $url';
  }
}

class _ProductFABState extends State<ProductFAB> with TickerProviderStateMixin {
  // animation controller
  AnimationController _controller;

  @override
  void initState() {
    // set animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            // Contact Container
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                  // set the curved animation
                  parent: _controller,
                  curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                heroTag: 'contact',
                mini: true,
                onPressed: () async {
                  // send email to contact
                  _launchURL(widget.product.userEmail, widget.product.title);
                },
                child: Icon(
                  // mail icon
                  Icons.mail,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Container(
            // Favorite Container
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: ScaleTransition(
              scale: CurvedAnimation(
                  // set the curved animation
                  parent: _controller,
                  curve: Interval(0.0, 1.0, curve: Curves.easeOut)),
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).cardColor,
                heroTag: 'favorite',
                mini: true,
                onPressed: () {
                  model.toggleProductFavoriteStatus(
                      model.selectedProduct); // pass model.selectedProduct
                },
                child: Icon(
                  model.selectedProduct.isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Container(
            // Options Container
            height: 70.0,
            width: 56.0,
            alignment: FractionalOffset.topCenter,
            child: FloatingActionButton(
              heroTag: 'options',
              onPressed: () {
                // forward or reverse according to the animation controller
                if (_controller.isDismissed) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              },
              backgroundColor: Theme.of(context).accentColor,
              child: AnimatedBuilder(
                // Animated More, Close Icon
                animation: _controller,
                builder: (BuildContext context, Widget child) {
                  return Transform(
                    // set the transformatin
                    alignment: FractionalOffset.center,
                    child: Icon(_controller.isDismissed
                        ? Icons.more_vert
                        : Icons.close),
                    transform: // rotation on the z axis
                        Matrix4.rotationZ(_controller.value * 0.5 * math.pi),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }
}
