import 'package:flutter/material.dart';

// Type Difinition Object

class User {
  final String id;
  final String email;
  final String token;
  User({
      @required this.id,
      @required this.email,
      @required this.token,
    });
}
