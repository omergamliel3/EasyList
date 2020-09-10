import 'package:flutter/material.dart';

class Product {
  // Class Attributes
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String image;
  final String imagePath;
  final bool isFavorite;
  final String userEmail;
  final String userId;

// Product Constructor
  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.location,
      @required this.image,
      @required this.userEmail,
      @required this.userId,
      @required this.imagePath,
      this.isFavorite = false,
      });
}
