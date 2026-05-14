import 'package:flutter/material.dart';

class GameTheme {
  // Colors
  static const navy = Color(0xFF0A0E27);
  static const navyLight = Color(0xFF131832);
  static const navyCard = Color(0xFF1A2040);
  static const cyan = Color(0xFF00D4FF);
  static const cyanGlow = Color(0x4400D4FF);
  static const gold = Color(0xFFFFD700);
  static const goldGlow = Color(0x44FFD700);
  static const red = Color(0xFFFF4757);
  static const green = Color(0xFF2ED573);
  static const orange = Color(0xFFFF6B35);
  static const purple = Color(0xFF7C4DFF);

  static BoxDecoration cardDecoration({Color? glowColor}) => BoxDecoration(
    color: navyCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: (glowColor ?? cyan).withOpacity(0.3), width: 1),
    boxShadow: [
      BoxShadow(
        color: (glowColor ?? cyan).withOpacity(0.08),
        blurRadius: 20,
        spreadRadius: 2,
      )
    ],
  );

  static BoxDecoration glowDecoration(Color color) => BoxDecoration(
    gradient: LinearGradient(
      colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)],
  );

  static TextStyle get heading => const TextStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static TextStyle get subheading => const TextStyle(
    color: Color(0xFFB0BEC5),
    fontSize: 14,
    letterSpacing: 0.5,
  );

  static TextStyle get balanceText => const TextStyle(
    color: gold,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
  );
}