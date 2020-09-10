import 'package:flutter/material.dart';

// Adapte the Theme Data to the given Platform

final ThemeData _androidTheme = ThemeData(
    // Theme Settings
    brightness: Brightness.light,
    primarySwatch: Colors.deepOrange,
    accentColor: Colors.orangeAccent);

final ThemeData _iOSTheme = ThemeData(
    // Theme Settings
    brightness: Brightness.light,
    primarySwatch: Colors.grey,
    accentColor: Colors.blueGrey);

ThemeData getAdaptiveThemeData(context) {
  return Theme.of(context).platform == TargetPlatform.android
      ? _androidTheme
      : _iOSTheme;
}
