import 'package:my_app/widgets/products/products_widget.dart';
import 'package:my_app/widgets/ui_elements/logout_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:my_app/scoped-models/main.dart';

class ProductsPage extends StatefulWidget {
  // Class Attributes
  final MainModel model;
  // Product Page Constructor
  ProductsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  initState() {
    // fetching products when initialized the page
    widget.model.fetchProducts();
    super.initState();
  }

  // Side Drawer Widget Method
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose Bar'),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),
            onTap: () {
              // Replace the page with custom Route
              Navigator.pushReplacementNamed(context, '/admin');
            },
          ),
          Divider(
            color: Colors.black,
          ),
          // Log out list tile widget
          LogoutListTile(),
        ],
      ),
    );
  }

  // build container spinner widget
  Widget _buildContainerSpinnerWidget() {
    return Center(
      child: Container(
        decoration: new BoxDecoration(
            //color: Colors.blue[50],
            borderRadius: new BorderRadius.circular(10.0)),
        width: 300.0,
        height: 200.0,
        alignment: AlignmentDirectional.center,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Center(
              child: new SizedBox(
                height: 50.0,
                width: 50.0,
                child: new CircularProgressIndicator(
                  value: null,
                  strokeWidth: 5.0,
                ),
              ),
            ),
            new Container(
              margin: const EdgeInsets.only(top: 25.0),
              child: new Center(
                child: new Text(
                  "loading.. wait...",
                  style: new TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // loading spinner widget
  Widget _buildLoadingSpinner() {
    return Container(
      child: new Stack(
        children: <Widget>[
          _buildContainerSpinnerWidget(),
        ],
      ),
    );
  }

  // build products list page or spinner widget while loading data from the server
  Widget _buildProductsList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget content =
            model.isLoading ? _buildLoadingSpinner() : Products();
        return RefreshIndicator(
            child: content,
            onRefresh: () => model.fetchProducts(customLoading: false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildSideDrawer(context),
      appBar: AppBar(
        title: Text('All Products'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () {
                  print('[favorite] button pressed');
                  model.toggleDisplayMode();
                },
              );
            },
          )
        ],
      ),
      // ProductManager Costructor
      body: _buildProductsList(),
    );
  }
}
