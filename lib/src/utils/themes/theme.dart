import 'package:flutter/material.dart';
import 'package:fyp_two/src/utils/themes/widget_themes/text_theme.dart';

class TApptheme {
  TApptheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: TTextTheme.lightTextTheme,
    // elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom())
  );
  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.light, textTheme: TTextTheme.darkTextTheme);
}
