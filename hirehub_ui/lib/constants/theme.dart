import 'package:flutter/material.dart';
import 'colors.dart';

// ─────────────────────────────────────────────
//  HireHub Light Theme
// ─────────────────────────────────────────────

ThemeData lightTheme = ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: NeutralColor.c50, // rgb(252, 252, 253) near-white

  colorScheme: const ColorScheme.light(
    // ── Backgrounds ───────────────────────────────────────────
    background:       NeutralColor.c50,       // rgb(252, 252, 253) near-white
    surface:          NeutralColor.c100,      // rgb(247, 248, 250) soft off-white

    // ── Brand / Primary ───────────────────────────────────────
    primary:          BrandColor.c500,        // rgb(71, 133, 249) brand blue
    primaryContainer: BrandColor.c50,         // rgb(235, 244, 255) ultra-light blue

    // ── Secondary / Accent ────────────────────────────────────
    secondary:          IndigoColor.c400,     // rgb(115, 135, 230) soft indigo
    secondaryContainer: IndigoColor.c50,      // rgb(232, 237, 255) ultra-light indigo

    // ── On-Colors (text / icons) ──────────────────────────────
    onBackground:     NeutralColor.c900,      // rgb(25, 28, 40)  near-black text
    onSurface:        NeutralColor.c800,      // rgb(50, 55, 70)  default text
    onPrimary:        NeutralColor.c50,       // white text on primary buttons
    onSecondary:      NeutralColor.c50,       // white text on secondary buttons
    onSurfaceVariant: NeutralColor.c700,      // rgb(80, 86, 104) icons / borders

    // ── Error ─────────────────────────────────────────────────
    error:            DangerColor.c500,       // rgb(235, 56, 59)
    errorContainer:   DangerColor.c50,        // rgb(255, 240, 240) light red bg

    // ── Outline ───────────────────────────────────────────────
    outline:          NeutralColor.c300,      // rgb(220, 223, 230) light border
  ),

  // ── AppBar ────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    backgroundColor:  NeutralColor.c50,
    foregroundColor:  NeutralColor.c900,
    elevation:        0,
    centerTitle:      false,
    titleTextStyle: TextStyle(
      fontFamily:     'Inter',
      fontSize:       18,
      fontWeight:     FontWeight.w600,
      color:          NeutralColor.c900,
    ),
  ),

  // ── Card ──────────────────────────────────────────────────
  cardTheme: const CardThemeData(
    color:            NeutralColor.c100,
    elevation:        0,
    shape: RoundedRectangleBorder(
      borderRadius:   BorderRadius.all(Radius.circular(16)),
      side:           BorderSide(color: NeutralColor.c200),
    ),
  ),

  // ── Input / TextField ─────────────────────────────────────
  inputDecorationTheme: const InputDecorationTheme(
    filled:           true,
    fillColor:        NeutralColor.c100,
    contentPadding:   EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius:   BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: NeutralColor.c300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius:   BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: NeutralColor.c300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius:   BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: BrandColor.c500, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius:   BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: DangerColor.c500),
    ),
    hintStyle: TextStyle(color: NeutralColor.c500, fontSize: 14),
    labelStyle: TextStyle(color: NeutralColor.c600, fontSize: 14),
  ),

  // ── Elevated Button ───────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:  BrandColor.c500,
      foregroundColor:  NeutralColor.c50,
      elevation:        0,
      padding:          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: const RoundedRectangleBorder(
        borderRadius:   BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(
        fontFamily:     'Inter',
        fontSize:       15,
        fontWeight:     FontWeight.w600,
      ),
    ),
  ),

  // ── Outlined Button ───────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor:  BrandColor.c500,
      side:             const BorderSide(color: BrandColor.c500),
      padding:          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: const RoundedRectangleBorder(
        borderRadius:   BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(
        fontFamily:     'Inter',
        fontSize:       15,
        fontWeight:     FontWeight.w600,
      ),
    ),
  ),

  // ── Text Button ───────────────────────────────────────────
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: BrandColor.c500,
      textStyle: const TextStyle(
        fontFamily:    'Inter',
        fontSize:      14,
        fontWeight:    FontWeight.w600,
      ),
    ),
  ),

  // ── Divider ───────────────────────────────────────────────
  dividerTheme: const DividerThemeData(
    color:     NeutralColor.c200,
    thickness: 1,
    space:     1,
  ),

  // ── Chip ──────────────────────────────────────────────────
  chipTheme: const ChipThemeData(
    backgroundColor:  BrandColor.c50,
    labelStyle:       TextStyle(color: BrandColor.c500, fontSize: 13),
    side:             BorderSide(color: BrandColor.c200),
    shape:            RoundedRectangleBorder(
      borderRadius:   BorderRadius.all(Radius.circular(8)),
    ),
  ),
);

// ─────────────────────────────────────────────
//  HireHub Dark Theme
// ─────────────────────────────────────────────

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Inter',
  scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate 900

  colorScheme: ColorScheme.dark(
    // ── Backgrounds ───────────────────────────────────────────
    background:       const Color(0xFF0F172A), // Slate 900
    surface:          const Color(0xFF1E293B), // Slate 800
    surfaceVariant:   const Color(0xFF334155), // Slate 700

    // ── Brand / Primary ───────────────────────────────────────
    primary:          BrandColor.c500,
    primaryContainer: BrandColor.c900.withOpacity(0.3),

    // ── Secondary / Accent ────────────────────────────────────
    secondary:          IndigoColor.c300,
    secondaryContainer: IndigoColor.c900.withOpacity(0.3),

    // ── On-Colors (text / icons) ──────────────────────────────
    onBackground:     NeutralColor.c50,
    onSurface:        NeutralColor.c100,
    onPrimary:        Colors.white,
    onSecondary:      Colors.white,
    onSurfaceVariant: NeutralColor.c400,

    // ── Error ─────────────────────────────────────────────────
    error:            DangerColor.c400,
    errorContainer:   DangerColor.c900.withOpacity(0.3),

    // ── Outline ───────────────────────────────────────────────
    outline:          const Color(0xFF334155), // Slate 700
  ),

  // ── AppBar ────────────────────────────────────────────────
  appBarTheme: const AppBarTheme(
    backgroundColor:  Color(0xFF0F172A),
    foregroundColor:  NeutralColor.c50,
    elevation:        0,
    centerTitle:      false,
    titleTextStyle: TextStyle(
      fontFamily:     'Inter',
      fontSize:       18,
      fontWeight:     FontWeight.w600,
      color:          NeutralColor.c50,
    ),
  ),

  // ── Card ──────────────────────────────────────────────────
  cardTheme: const CardThemeData(
    color:            Color(0xFF1E293B), // Slate 800
    elevation:        0,
    shape: RoundedRectangleBorder(
      borderRadius:   BorderRadius.all(Radius.circular(16)),
      side:           BorderSide(color: Color(0xFF334155)),
    ),
  ),

  // ── Input / TextField ─────────────────────────────────────
  inputDecorationTheme: InputDecorationTheme(
    filled:           true,
    fillColor:        const Color(0xFF1E293B),
    contentPadding:   const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius:   const BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius:   const BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: Colors.white.withOpacity(0.1)),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius:   BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: BrandColor.c500, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder(
      borderRadius:   BorderRadius.all(Radius.circular(12)),
      borderSide:     BorderSide(color: DangerColor.c500),
    ),
    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
    labelStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
  ),

  // ── Elevated Button ───────────────────────────────────────
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor:  BrandColor.c500,
      foregroundColor:  Colors.white,
      elevation:        0,
      padding:          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: const RoundedRectangleBorder(
        borderRadius:   BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(
        fontFamily:     'Inter',
        fontSize:       15,
        fontWeight:     FontWeight.w600,
      ),
    ),
  ),

  // ── Outlined Button ───────────────────────────────────────
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor:  BrandColor.c400,
      side:             const BorderSide(color: BrandColor.c400),
      padding:          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      shape: const RoundedRectangleBorder(
        borderRadius:   BorderRadius.all(Radius.circular(12)),
      ),
      textStyle: const TextStyle(
        fontFamily:     'Inter',
        fontSize:       15,
        fontWeight:     FontWeight.w600,
      ),
    ),
  ),

  // ── Divider ───────────────────────────────────────────────
  dividerTheme: DividerThemeData(
    color:     Colors.white.withOpacity(0.1),
    thickness: 1,
    space:     1,
  ),

  // ── Chip ──────────────────────────────────────────────────
  chipTheme: ChipThemeData(
    backgroundColor:  BrandColor.c900.withOpacity(0.3),
    labelStyle:       const TextStyle(color: BrandColor.c300, fontSize: 13),
    side:             BorderSide(color: BrandColor.c800.withOpacity(0.5)),
    shape:            const RoundedRectangleBorder(
      borderRadius:   BorderRadius.all(Radius.circular(8)),
    ),
  ),
);
