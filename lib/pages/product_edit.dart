import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/form_inputs/image.dart';
import 'package:my_app/widgets/ui_elements/adaptive_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:my_app/models/product.dart';
import '../scoped-models/main.dart';

import '../widgets/helpers/ensure_visible.dart';

class ProductEditPage extends StatefulWidget {
  @override
  // Create State
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  // Class Attributes
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': null,
    'location': null,
    'image': null,
  };
  // Form Global Key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Title FocusNode
  final _titleFocusNode = FocusNode();

  // Alert Methods

  _showDialog(BuildContext context) {
    // set the Dialog
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Text(
            'Product \'${_formData['title']}\' has been saved.\n\n You can view it in \'My Products\'',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontWeight: FontWeight.bold),
          ));
        });
  }

  _showModal() {
    // Show Saved Modal
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child:
                Text('Your Product \'${_formData['title']}\' has been saved.'),
          );
        });
  }

  _showSnackBar() {
    // show snack bar at the buttom of the page
    final snackBar = SnackBar(
      content: Text('Product has been saved'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => print('[Snack Bar Undo] pressed'),
        textColor: Colors.white,
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  // Product Title TextField Widget
  Widget _buildProductTitleTextField(Product product) {
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(
          labelText: 'Product Title',
          hintText: '',
        ),
        keyboardType: TextInputType.text,
        initialValue: product == null ? '' : product.title,
        // autovalidate: true,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Title is required';
          }
        },
        onSaved: (String value) {
          _formData['title'] = value;
        },
      ),
    );
  }

  // Product Description TextField Widget
  Widget _buildProductDescriptionTextField(Product product) {
    return TextFormField(
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Product Description',
        hintText: '',
      ),
      keyboardType: TextInputType.text,
      initialValue: product == null ? '' : product.description,
      // autovalidate: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Description is required';
        }
      },
      onSaved: (String value) {
        _formData['description'] = value;
      },
    );
  }

  // Product Price TextField Widget
  Widget _buildProductPriceTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Price', hintText: ''),
      keyboardType: TextInputType.number,
      initialValue: product == null ? '' : product.price.toString(),
      // autovalidate: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Price is required';
        } else if (!RegExp(r'^(?:[1-9]\d*|0)?(?:\.\d+)?$').hasMatch(value)) {
          return 'Price should be a number';
        }
      },
      onSaved: (String value) {
        _formData['price'] =
            double.parse(value.replaceFirst(RegExp(r','), '.'));
      },
    );
  }

  // Product Location TextField Widget
  Widget _buildProductLocationTextField(Product product) {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Product Location', hintText: ''),
      keyboardType: TextInputType.text,
      initialValue: product == null ? '' : product.location,
      //autovalidate: true,
      validator: (String value) {
        if (value.isEmpty) {
          return 'Location is required';
        }
      },
      onSaved: (String value) {
        _formData['location'] = value;
      },
    );
  }

  // Save button Widget
  Widget _buildSaveButton() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return model.isLoading
            ? Center(child: AdaptiveProgressIndicator())
            : RaisedButton(
                color: Theme.of(context).accentColor,
                textColor: Colors.white,
                child: Text('Save'),
                // Submit the Form when pressed 'save'
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductIndex));
      },
    );
  }

  //
  void _setImage(File image) {
    _formData['image'] = image;
  }

  // method which called whenever the user submits the Form
  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [int selectedproductIndex]) {
    // stop submit form if not validate or if image is null and the user in edit mode.
    // image can be null when updating the exsiting product.
    if (!_formKey.currentState.validate() ||
        (_formData['image'] == null && selectedproductIndex == -1)) {
      return;
    }

    // activate 'onSave' form's fields
    _formKey.currentState.save();

    if (selectedproductIndex == -1) {
      // addProduct function from main.dart
      // Create Product Instance
      addProduct(
        _formData['title'],
        _formData['description'],
        _formData['price'],
        _formData['image'],
        _formData['location'],
        // checks the future boolean
      ).then((bool succes) {
        // if true - push to products page
        if (succes) {
          // 'product has been added' SnackBar
          _showSnackBar();
          // reset form fields
          _formKey.currentState.reset();
          Navigator.pushReplacementNamed(context, '/products')
              .then((_) => setSelectedProduct(null));
          // if false - show error alert dialog
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Something went wrong'),
                content: Text('Please try again'),
                actions: <Widget>[
                  FlatButton(
                      child: Text('Okay'),
                      onPressed: () => Navigator.pop(context))
                ],
              );
            },
          );
        }
      });
    } else {
      // updateProduct function from main.dart
      updateProduct(
        // Create Product Instance
        _formData['title'],
        _formData['description'],
        _formData['price'],
        _formData['image'],
        _formData['location'],
      ).then((_) {
        Navigator.pushReplacementNamed(context, '/products')
            .then((_) => setSelectedProduct(null));
      });
    }

    // exit keyboard
    _unFocusScope();
  }

  // UnFocusScope Method
  void _unFocusScope() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // build Scaffold for pageContent when user edit the product
  Scaffold _buildSaffoldPageContent(Widget pageContent) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit'),
      ),
      body: pageContent,
    );
  }

  // Responsive Design Media Query Calculations.
  double _targetPadding(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;
    return targetPadding / 3;
  }

  // build page content
  Widget _buildPageContent(BuildContext context, Product product) {
    return GestureDetector(
      onTap: _unFocusScope,
      child: Container(
        margin: EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: _targetPadding(context)),
            children: <Widget>[
              // Product title
              _buildProductTitleTextField(product),
              // Product description
              _buildProductDescriptionTextField(product),
              // Product price
              _buildProductPriceTextField(product),
              // Product location
              _buildProductLocationTextField(product),
              // Creat Space
              SizedBox(height: 10.0),
              // Static Map Location Widget
              //LocationInput(),
              SizedBox(
                height: 10.0,
              ),
              // Image Input Device Camera
              ImageInput(_setImage, product),
              SizedBox(
                height: 10.0,
              ),
              // Button Save
              _buildSaveButton()
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // build() return widget
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        final Widget pageContent =
            _buildPageContent(context, model.selectedProduct);
        return model.selectedProductIndex == -1
            ? pageContent
            : _buildSaffoldPageContent(pageContent);
      },
    );
  }
}
