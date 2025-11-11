import 'package:flutter/material.dart';

class ThemeController {
  // Singleton
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  // Global dark mode state
  final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  void toggle() {
    isDarkMode.value = !isDarkMode.value;
  }
}
