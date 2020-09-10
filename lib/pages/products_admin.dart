import 'package:my_app/widgets/ui_elements/logout_list_tile.dart';
import 'package:flutter/material.dart';
import './product_edit.dart';
import './product_list.dart';
import '../scoped-models/main.dart';

class ProductsAdminPage extends StatelessWidget {
  // Class Attributes
  final MainModel model;
  // ProductAdmin Page Constructor
  ProductsAdminPage(this.model);

  // // Side Drawer Widget Method
  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            automaticallyImplyLeading: false,
            title: Text('Choose Bar'),
          ),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All Products'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
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

  // Tab Bar widget method
  Widget _buildTabBar() {
    return TabBarView(
      children: <Widget>[
        // ProductCreatePage Constructor
        ProductEditPage(),
        // ProductListPage Constructor
        ProductListPage(model),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default Tab Controller that Raps-up the Scaffold
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: _buildSideDrawer(context),
          appBar: AppBar(
            title: Text('Manage Products'),
            bottom: TabBar(
              // list of tabs widgets
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.create),
                  text: 'Create Product',
                ),
                Tab(
                  icon: Icon(Icons.list),
                  text: 'My Products',
                ),
              ],
            ),
          ),
          // manage TabBarView
          body: _buildTabBar(),
        ));
  }
}
