import 'package:flutter/material.dart';
import './product_edit.dart';
import 'package:scoped_model/scoped_model.dart';
import '../scoped-models/main.dart';

class ProductListPage extends StatefulWidget {
  // Class Attributes
  final MainModel model;
  // ProductListPage Constructor
  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductListPageState();
  }
}

class _ProductListPageState extends State<ProductListPage> {
  // fetch products from firebase to keep the products update
  @override
  initState() {
    widget.model.fetchProducts(onlyForUser: true, clearExisting: false);
    super.initState();
  }

  _showDialog(BuildContext context, String action) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('You can only $action your own products!'),
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

  // build Products Dismisslbe ListTile Container Method (for the itemBuilder)
  Widget _buildProductsListTileContainer(
      BuildContext context, int index, MainModel model) {
    return Container(
      padding: EdgeInsets.only(top: 10.0),
      child: _buildDismissbleListTile(index, context, model),
    );
  }

  // Product Dismissble List Tile Method
  Widget _buildDismissbleListTile(
      int index, BuildContext context, MainModel model) {
    return Dismissible(
      key: Key(model.allProducts[index].title),
      background: Container(
        color: Colors.red,
      ),
      // Swipe check
      onDismissed: (DismissDirection direction) {
        // if the user Swipes Right to Left
        if (direction == DismissDirection.endToStart) {
          print('Swipe end to start - delete product');
          // Delete the Product
          model.selectProduct(model.allProducts[index].id);
          model.deleteProduct();
        } else if (direction == DismissDirection.startToEnd) {
          print('Swipe start to end');
        } else
          print('Other Swipe');
      },
      child: Column(
        children: <Widget>[
          _buildProductListTile(index, context, model),
          Divider(
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

// build Product List Tile inside Dismissble
  ListTile _buildProductListTile(
      int index, BuildContext context, MainModel model) {
    return ListTile(
      // Navigator pushNamed for this Products index
      onTap: () => Navigator.pushNamed<bool>(
              // passing our custom Route from main file
              context,
              '/product/' + index.toString())
          // Waits for a future value
          .then((bool value) {
        // if value, deleting the product
        if (value) {
          print('Delete Product');
        }
      }),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(model.allProducts[index].image),
      ),
      title: Text(model.allProducts[index].title),
      subtitle: Text(
        '\$${model.allProducts[index].price.toString()}',
        style: TextStyle(fontSize: 13.0),
      ),
      trailing: _buildEditButton(index, context, model),
    );
  }

  // build Edit Button Method
  Widget _buildEditButton(int index, BuildContext context, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        // select product before move to ProductEditPage and edit the product
        model.selectProduct(model.allProducts[index].id);
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (BuildContext context) {
          return ProductEditPage();
        })).then((_) {
          model.selectProduct(null);
        });
      },
    );
  }

  // Responsive Design Media Query Calculations.
  double _targetPadding(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.98;
    final double targetPadding = deviceWidth - targetWidth;
    return targetPadding / 3;
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return RefreshIndicator(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: _targetPadding(context)),
            itemBuilder: (BuildContext context, int index) =>
                _buildProductsListTileContainer(context, index, model),
            itemCount: model.allProducts.length,
          ),
          onRefresh: () => model.fetchProducts(customLoading: false),
        );
      },
    );
  }
}
