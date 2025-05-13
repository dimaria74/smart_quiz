import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Colors.deepOrange;
  static const Color secondaryColor = Color(0xff48ffe1);
  static const Color backgroundColor = Color(0xfff5f7ff);
  static const Color cardColor = Colors.white;
  static const Color txtPrimaryColor = Color(0xff2D3748);
  static const Color txtSecondaryColor = Color(0xff718096);

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepOrange),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      // textTheme: GoogleFonts.poppinsTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: cardColor,
        foregroundColor: txtPrimaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: txtPrimaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: cardColor,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}
