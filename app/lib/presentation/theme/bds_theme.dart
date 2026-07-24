import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand colours taken from bds.org.uk's own logo and site CSS (the two
/// greens in the stag-head wordmark, cross-checked against the site's own
/// button colour) rather than a generic Material seed.
class BdsColors {
  const BdsColors._();

  static const primary = Color(0xFF006F51);
  static const accent = Color(0xFF7AC143);
}

ThemeData buildBdsTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: BdsColors.primary,
    brightness: Brightness.light,
  ).copyWith(secondary: BdsColors.accent);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    textTheme: GoogleFonts.latoTextTheme(),
  );
}
