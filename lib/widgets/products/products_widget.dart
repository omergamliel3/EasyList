import 'package:my_app/models/product.dart';
import 'package:my_app/scoped-models/main.dart';
import 'package:flutter/material.dart';
import './product_card.dart';
import 'package:scoped_model/scoped_model.dart';

class Products extends StatelessWidget {
  // Widget _buildProductList method
  Widget _buildProductList(BuildContext context, List<Product> products) {
    Widget productCards;
    // Conditions
    // if products is not empty
    if (products.length > 0) {
      // ListView for scrolling a list
      productCards = ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: _targetPadding(context)),
        // builder is called only for those children that are actually visible
        itemBuilder: (BuildContext context, int index) {
          return ProductCard(products[index]);
        },
        itemCount: products.length,
      );
      // if products is empty
    } else {
      productCards = Center(
          child: Image.network(
              'https://proxy.duckduckgo.com/iu/?u=https%3A%2F%2Fdlinkmea.com%2Fimages%2Fno-product.png&f=1'));
      //productCards = Center(
      //child: Text('No products found, pls add some'),
      //);
    }
    return productCards;
  }

  // Responsive Design Media Query Calculations.
  double _targetPadding(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return targetPadding / 3;
  }

  @override
  Widget build(BuildContext context) {
    print('[Products Widget] build()');
    // Construct _buildProductList
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildProductList(context, model.displayedProducts);
      },
    );
  }
}
