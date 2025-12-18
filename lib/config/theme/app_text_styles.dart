import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get displayLarge =>
      GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold);

  static TextStyle get displayMedium =>
      GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w600);

  static TextStyle get bodyLarge =>
      GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.normal);

  static TextStyle get bodyMedium =>
      GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal);

  static TextStyle get button =>
      GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600);
}
