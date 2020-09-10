import 'package:flutter/material.dart';

class GridPage extends StatefulWidget {
  @override
  _GridPageState createState() => _GridPageState();
}

// create a card widget
Widget _buildCard(String text, BuildContext context) {
  return Card(
      color: Theme.of(context).accentColor,
      // Card Widget
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      clipBehavior: Clip.antiAlias,
      elevation: 10.0,
      margin: EdgeInsets.all(0.0),
      child: Center(
        child: Text(text),
      ));
}

class _GridPageState extends State<GridPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grid View Test'),
      ),
      body: GridView.count(
        crossAxisCount:
            MediaQuery.of(context).orientation == Orientation.portrait ? 2 : 3,
        primary: false,
        padding: const EdgeInsets.all(20.0),
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        children: <Widget>[
          _buildCard('1', context),
          _buildCard('2', context),
          _buildCard('3', context),
          _buildCard('4', context),
          _buildCard('5', context),
          _buildCard('6', context),
          _buildCard('7', context),
          _buildCard('8', context),
          _buildCard('9', context),
          _buildCard('10', context),
          _buildCard('11', context)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Text('Grid'),
        onPressed: () => print('Grid Floating Action Button'),
      ),
    );
  }
}
