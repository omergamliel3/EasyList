import 'package:my_app/models/product.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/products/product_fab.dart';
import '../widgets/ui_elements/title_default.dart';
import 'dart:async';
import '../scoped-models/main.dart';

class ProductPage extends StatelessWidget {
  // Class Attributes
  final Product product;
  // ProductPage Construtor
  ProductPage(this.product);
  // Warning Dialog Function
  _showWarningDialog(BuildContext context, MainModel model) {
    // set the Dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Are you sure?'),
            content: Text('This action cannot be undone!'),
            actions: <Widget>[
              FlatButton(
                child: Text('DISCARD'),
                onPressed: () {
                  // Back without doing nothing
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('CONTINUE'),
                onPressed: () {
                  // Back and delete the product
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                  // Delete Product via ScopedModel MainModel
                  model.selectProduct(
                      model.allProducts[model.selectedProductIndex].id);
                  model.deleteProduct();
                },
              ),
            ],
          );
        });
  }

  _showDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('You Pressed Product\'s Owner Email'),
            actions: <Widget>[
              FlatButton(
                child: Text('BACK'),
                onPressed: () {
                  // Back without doing nothing
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Container _buildTitle(String title) {
    return Container(
      alignment: Alignment.center,
        padding: EdgeInsets.all(3.0),
        // Row: Product's title and price
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Flexible can take all available space but doesn't have to
            TitleDefault(title),
          ],
        ));
  }

  Widget _buildAddressPriceRow(String address, double price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            print(['[Adress Price Tap]']);
          },
          child: Text(
            address,
            style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          child: Text(
            '|',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Text(
          '\$' + price.toString(),
          style: TextStyle(fontFamily: 'Oswald', color: Colors.grey),
        )
      ],
    );
  }

  Container _buildDescriptionContainer(String description) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(3.0),
      child:
          // description text
          Text(
        description,
        style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black54),
      ),
    );
  }

  // Delete Button Container widget method
  Container _buildDeleteButtonContainer(BuildContext context, MainModel model) {
    return Container(
      padding: EdgeInsets.all(10.0),
      // DELETE Button
      child: RaisedButton(
        color: Theme.of(context).accentColor,
        child: Text(
          'DELETE',
          style: TextStyle(color: Colors.white),
        ),
        // Navigator onPressed to navigate into another page (works like stuck)
        onPressed: () => _showWarningDialog(context, model),
      ),
    );
  }

  // GestureDetector - event listener for any user action
  GestureDetector _buildContactText(BuildContext context) {
    return GestureDetector(
      // optional check for any kind of taps
      onTap: () {
        _showDialog(context);
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Text(
          'Contact: ${product.userEmail}',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }

  Container _buildImage(String imageUrl) {
    return Container(
      padding: EdgeInsets.only(top: 5.0),
      child: Hero(
        tag: product.id,
        child: FadeInImage(
          image: NetworkImage(
            imageUrl,
          ),
          height: 300.0,
          fit: BoxFit.cover,
          placeholder: AssetImage('images/loading.jpg'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        print('Back button pressed');
        // Mainualy passing our own data back
        Navigator.pop(context, false);
        // allow the user to leave the page
        return Future.value(false);
      },
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(product.title),
        // ),
        // Body, Product Details
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 256.0,
              pinned: true, 
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(product.title),
                background: Hero(
                  tag: product.id,
                  child: FadeInImage(
                    image: NetworkImage(
                      product.image,
                    ),
                    height: 300.0,
                    fit: BoxFit.cover,
                    placeholder: AssetImage('images/loading.jpg'),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                // imageUrl
                // _buildImage(product.image),
                // SizedBox(
                //   height: 30.0,
                // ),
                // title
                _buildTitle(product.title),
                SizedBox(
                  height: 10.0,
                ),
                // address and price
                _buildAddressPriceRow(product.location, product.price),
                SizedBox(
                  height: 20.0,
                ),
                // description
                _buildDescriptionContainer(product.description),
              ]),
            )
          ],
        ),
        floatingActionButton: ProductFAB(product),
      ),
    );
  }
}
