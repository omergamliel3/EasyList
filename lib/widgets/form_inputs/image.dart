import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_app/models/product.dart';

class ImageInput extends StatefulWidget {
  // Class Attributes
  final Function setImage;
  final Product product;

  // ImageInput Constructor
  ImageInput(this.setImage, this.product);

  @override
  State<StatefulWidget> createState() {
    return ImageInputState();
  }
}

class ImageInputState extends State<ImageInput> {
  // Class Attributes
  File _imageFile;

  void _getImage(ImageSource imageSource) async {
    File image =
        await ImagePicker.pickImage(source: imageSource, maxWidth: 400.0);
    setState(() {
      _imageFile = image;
    });
    // setting up the image from the device
    widget.setImage(image);
    Navigator.pop(context);
  }

  void _openImagePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 150.0,
            padding: EdgeInsets.all(10.0),
            child: Column(children: [
              Text(
                'Pick an Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10.0,
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Camera'),
                onPressed: () {
                  _getImage(ImageSource.camera);
                },
              ),
              FlatButton(
                textColor: Theme.of(context).primaryColor,
                child: Text('Use Gallery'),
                onPressed: () {
                  _getImage(ImageSource.gallery);
                },
              )
            ]),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // image preview check
    Widget previewImage = Text('Please select an Image');
    String imageText = 'Add Image';

    if (_imageFile != null) {
      previewImage = Image.file(
        _imageFile,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.95,
        alignment: Alignment.topCenter,
      );
    } else if (widget.product != null) {
      imageText = 'Change Image';
      previewImage = Image.network(
        widget.product.image,
        fit: BoxFit.cover,
        height: MediaQuery.of(context).size.height * 0.4,
        width: MediaQuery.of(context).size.width * 0.95,
        alignment: Alignment.topCenter,
      );
    }

    return Column(
      children: <Widget>[
        OutlineButton(
          onPressed: () {
            _openImagePicker(context);
          },
          borderSide:
              BorderSide(color: Theme.of(context).accentColor, width: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.camera_alt),
              SizedBox(
                width: 5.0,
              ),
              Text(imageText),
            ],
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        // default image preview
        previewImage
      ],
    );
  }
}
