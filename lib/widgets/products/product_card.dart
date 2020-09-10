import 'package:my_app/models/product.dart';
import 'package:flutter/material.dart';
import './price_tag.dart';
import '../ui_elements/title_default.dart';
import '../ui_elements/location_default.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:my_app/scoped-models/main.dart';

class ProductCard extends StatelessWidget {
  // Class Attributes
  final Product product;

  // ProductCard Constructor
  ProductCard(this.product) {
    print('[ProductCard] Constructor');
  }
  // buildImage method
  Container _buildImage() {
    return Container(
        padding: EdgeInsets.only(top: 5.0),
        child: Hero(
          tag: product.id,
          child: FadeInImage(
            // Fade in the image
            image: NetworkImage(
              // product image
              product.image,
            ),
            height: 300.0,
            fit: BoxFit.cover,
            placeholder:
                AssetImage('images/loading.jpg'), // the placeholder image
          ),
        ));
  }

  Padding _buildTitlePriceRow() {
    return Padding(
        padding: EdgeInsets.all(3.0),
        // Row: Product's title and price
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Flexible can take all available space but doesn't have to
            Flexible(
              child: TitleDefault(product.title),
            ),
            Flexible(
              child: SizedBox(
                width: 8.0,
              ),
            ),
            // styling the product's price tag
            // Expanded take all available space
            Flexible(
              child: PriceTag(product.price.toString()),
            )
          ],
        ));
  }

  Widget _buildEmailTextContainer() {
    return Container(
      child: Text(product.userEmail),
      padding: EdgeInsets.only(top: 20.0),
    );
  }

  Widget _buildInfoProductButton(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return ButtonBar(
        alignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.info),
              color: Theme.of(context).accentColor,
              onPressed: () {
                model.selectProduct(product.id);
                Navigator.pushNamed<bool>(
                  context,
                  '/product/' + product.id,
                ).then((_) => model.selectProduct(null));
              }),
          IconButton(
            icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border),
            color: Colors.red,
            onPressed: () {
              // model.selectProduct(product.id); => Don't do this anymore
              model.toggleProductFavoriteStatus(
                  product); // Pass the product used in this card
            },
          ),
        ],
      );
    });
  }

  Padding _buildCredits() {
    return Padding(
      padding: EdgeInsets.all(3.0),
      child: Text('- By Omer Gamliel -',
          style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: <Widget>[
          // build image asset widget
          _buildImage(),
          // build title, price UI row
          _buildTitlePriceRow(),
          // space between the product UI elements
          SizedBox(
            height: 10.0,
          ),
          // build product location
          LocationDefault(product.location),
          // build user's email
          //_buildEmailTextContainer(),
          // build product delete button
          _buildInfoProductButton(context),
          // build product credits
          //_buildCredits()
        ],
      ),
    );
  }
}
