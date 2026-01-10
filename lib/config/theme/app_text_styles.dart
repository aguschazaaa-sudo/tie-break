import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static bool useGoogleFonts = true;

  static TextStyle get displayLarge =>
      useGoogleFonts
          ? GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold)
          : const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpaceGrotesk',
          );

  static TextStyle get displayMedium =>
      useGoogleFonts
          ? GoogleFonts.spaceGrotesk(fontSize: 28, fontWeight: FontWeight.w600)
          : const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            fontFamily: 'SpaceGrotesk',
          );

  static TextStyle get bodyLarge =>
      useGoogleFonts
          ? GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.normal)
          : const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            fontFamily: 'Roboto',
          );

  static TextStyle get bodyMedium =>
      useGoogleFonts
          ? GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.normal)
          : const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            fontFamily: 'Roboto',
          );

  static TextStyle get button =>
      useGoogleFonts
          ? GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600)
          : const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          );
}
