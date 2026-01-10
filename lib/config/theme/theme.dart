import 'package:flutter/material.dart';

class MaterialTheme {
  const MaterialTheme(this.textTheme);
  final TextTheme textTheme;

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006972),
      surfaceTint: Color(0xff006972),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9df0fb),
      onPrimaryContainer: Color(0xff004f56),
      secondary: Color(0xff3c6939),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffbcf0b4),
      onSecondaryContainer: Color(0xff245024),
      tertiary: Color(0xff735187),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfff4d9ff),
      onTertiaryContainer: Color(0xff5a396e),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xFFFAF8FF),
      onSurface: Color(0xff1a1b21),
      onSurfaceVariant: Color(0xff3f484a),
      outline: Color(0xff6f797a),
      outlineVariant: Color(0xffbec8ca),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xff81d3df),
      primaryFixed: Color(0xff9df0fb),
      onPrimaryFixed: Color(0xff001f23),
      primaryFixedDim: Color(0xff81d3df),
      onPrimaryFixedVariant: Color(0xff004f56),
      secondaryFixed: Color(0xffbcf0b4),
      onSecondaryFixed: Color(0xff002204),
      secondaryFixedDim: Color(0xffa1d39a),
      onSecondaryFixedVariant: Color(0xff245024),
      tertiaryFixed: Color(0xfff4d9ff),
      onTertiaryFixed: Color(0xff2b0b3f),
      tertiaryFixedDim: Color(0xffe0b8f6),
      onTertiaryFixedVariant: Color(0xff5a396e),
      surfaceDim: Color(0xffdad9e0),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3fa),
      surfaceContainer: Color(0xffeeedf4),
      surfaceContainerHigh: Color(0xffe9e7ef),
      surfaceContainerHighest: Color(0xffe3e1e9),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003d43),
      surfaceTint: Color(0xff006972),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff177883),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff123f14),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4a7847),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff48295c),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff825f97),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff101116),
      onSurfaceVariant: Color(0xff2f3839),
      outline: Color(0xff4b5456),
      outlineVariant: Color(0xff656f70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xff81d3df),
      primaryFixed: Color(0xff177883),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005e67),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4a7847),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff325f30),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff825f97),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff69477d),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc7c6cd),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f3fa),
      surfaceContainer: Color(0xffe9e7ef),
      surfaceContainerHigh: Color(0xffdddce3),
      surfaceContainerHighest: Color(0xffd2d1d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003237),
      surfaceTint: Color(0xff006972),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005159),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff05340b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff265326),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3d1e51),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5c3c70),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffaf8ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff252e2f),
      outlineVariant: Color(0xff414b4c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2f3036),
      inversePrimary: Color(0xff81d3df),
      primaryFixed: Color(0xff005159),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00393f),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff265326),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff0d3b11),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5c3c70),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff442558),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb9b8bf),
      surfaceBright: Color(0xfffaf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f0f7),
      surfaceContainer: Color(0xffe3e1e9),
      surfaceContainerHigh: Color(0xffd5d3db),
      surfaceContainerHighest: Color(0xffc7c6cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff81d3df),
      surfaceTint: Color(0xff81d3df),
      onPrimary: Color(0xff00363c),
      primaryContainer: Color(0xff004f56),
      onPrimaryContainer: Color(0xff9df0fb),
      secondary: Color(0xffa1d39a),
      onSecondary: Color(0xff0a390f),
      secondaryContainer: Color(0xff245024),
      onSecondaryContainer: Color(0xffbcf0b4),
      tertiary: Color(0xffe0b8f6),
      onTertiary: Color(0xff422356),
      tertiaryContainer: Color(0xff5a396e),
      onTertiaryContainer: Color(0xfff4d9ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff121318),
      onSurface: Color(0xffe3e1e9),
      onSurfaceVariant: Color(0xffbec8ca),
      outline: Color(0xff899294),
      outlineVariant: Color(0xff3f484a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1e9),
      inversePrimary: Color(0xff006972),
      primaryFixed: Color(0xff9df0fb),
      onPrimaryFixed: Color(0xff001f23),
      primaryFixedDim: Color(0xff81d3df),
      onPrimaryFixedVariant: Color(0xff004f56),
      secondaryFixed: Color(0xffbcf0b4),
      onSecondaryFixed: Color(0xff002204),
      secondaryFixedDim: Color(0xffa1d39a),
      onSecondaryFixedVariant: Color(0xff245024),
      tertiaryFixed: Color(0xfff4d9ff),
      onTertiaryFixed: Color(0xff2b0b3f),
      tertiaryFixedDim: Color(0xffe0b8f6),
      onTertiaryFixedVariant: Color(0xff5a396e),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff38393f),
      surfaceContainerLowest: Color(0xff0d0e13),
      surfaceContainerLow: Color(0xff1a1b21),
      surfaceContainer: Color(0xff1e1f25),
      surfaceContainerHigh: Color(0xff292a2f),
      surfaceContainerHighest: Color(0xff34343a),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff97e9f5),
      surfaceTint: Color(0xff81d3df),
      onPrimary: Color(0xff002a2f),
      primaryContainer: Color(0xff489da7),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffb6eaae),
      onSecondary: Color(0xff002d06),
      secondaryContainer: Color(0xff6d9c67),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfff1d1ff),
      onTertiary: Color(0xff36174a),
      tertiaryContainer: Color(0xffa883bd),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd4dee0),
      outline: Color(0xffaab4b5),
      outlineVariant: Color(0xff889293),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1e9),
      inversePrimary: Color(0xff005058),
      primaryFixed: Color(0xff9df0fb),
      onPrimaryFixed: Color(0xff001417),
      primaryFixedDim: Color(0xff81d3df),
      onPrimaryFixedVariant: Color(0xff003d43),
      secondaryFixed: Color(0xffbcf0b4),
      onSecondaryFixed: Color(0xff001602),
      secondaryFixedDim: Color(0xffa1d39a),
      onSecondaryFixedVariant: Color(0xff123f14),
      tertiaryFixed: Color(0xfff4d9ff),
      onTertiaryFixed: Color(0xff200034),
      tertiaryFixedDim: Color(0xffe0b8f6),
      onTertiaryFixedVariant: Color(0xff48295c),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff43444a),
      surfaceContainerLowest: Color(0xff06070c),
      surfaceContainerLow: Color(0xff1c1d23),
      surfaceContainer: Color(0xff27282d),
      surfaceContainerHigh: Color(0xff313238),
      surfaceContainerHighest: Color(0xff3d3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcaf8ff),
      surfaceTint: Color(0xff81d3df),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff7dcfdb),
      onPrimaryContainer: Color(0xff000e10),
      secondary: Color(0xffcafec0),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff9dcf96),
      onSecondaryContainer: Color(0xff000f01),
      tertiary: Color(0xfffbebff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffdcb4f2),
      onTertiaryContainer: Color(0xff170028),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff121318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f3),
      outlineVariant: Color(0xffbbc4c6),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe3e1e9),
      inversePrimary: Color(0xff005058),
      primaryFixed: Color(0xff9df0fb),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff81d3df),
      onPrimaryFixedVariant: Color(0xff001417),
      secondaryFixed: Color(0xffbcf0b4),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffa1d39a),
      onSecondaryFixedVariant: Color(0xff001602),
      tertiaryFixed: Color(0xfff4d9ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffe0b8f6),
      onTertiaryFixedVariant: Color(0xff200034),
      surfaceDim: Color(0xff121318),
      surfaceBright: Color(0xff4f5056),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1e1f25),
      surfaceContainer: Color(0xff2f3036),
      surfaceContainerHigh: Color(0xff3a3b41),
      surfaceContainerHighest: Color(0xff46464c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
  final Color seed;
  final Color value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
