import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  static const String _themeKey = "is_dark_mode";

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  ThemeData get currentTheme {
    return _isDarkMode ? darkTheme : lightTheme;
  }

  static final ThemeData lightTheme = ThemeData(
    primaryColor: const Color(0xFF1E3A8A),
    scaffoldBackgroundColor: const Color(0xFFF0F5FA),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1E3A8A),
      primary: const Color(0xFF1E3A8A),
      secondary: const Color(0xFF3B82F6),
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1E3A8A)),
      titleTextStyle: TextStyle(
          color: Color(0xFF1E3A8A), fontSize: 20, fontWeight: FontWeight.bold),
    ),
    useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    primaryColor: const Color(0xFF3B82F6),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF3B82F6),
      brightness: Brightness.dark,
      primary: const Color(0xFF3B82F6),
      secondary: const Color(0xFF60A5FA),
      surface: const Color(0xFF1E293B),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    useMaterial3: true,
  );
}
