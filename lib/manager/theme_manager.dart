import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FontThemeManager with ChangeNotifier {
  ThemeData _currentTheme = Themes.lightTheme;
  double _fontSize = 16;
  String _fontFamily = 'Serif';


  ThemeData get currentTheme => _currentTheme;
  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;

  FontThemeManager() {
    _loadPreferences();
  }


  void changeTheme(ThemeData newTheme) {
    _currentTheme = newTheme;
    _saveTheme(newTheme);
    notifyListeners();
  }


  void changeFontSize(double newSize) {
    _fontSize = newSize.clamp(10, 30);
    _saveFontSize(newSize);
    notifyListeners();
  }

  // Thay đổi kiểu font
  void changeFontFamily(String newFontFamily) {
    _fontFamily = newFontFamily;
    _saveFontFamily(newFontFamily);
    notifyListeners();
  }


  Future<void> _saveTheme(ThemeData theme) async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = theme == Themes.darkTheme
        ? 'dark'
        : (theme == Themes.lightYellowTheme ? 'yellow' : 'light');
    await prefs.setString('theme', themeName);
  }

  // Lưu cỡ chữ vào SharedPreferences
  Future<void> _saveFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', fontSize);
  }

  // Lưu kiểu font vào SharedPreferences
  Future<void> _saveFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', fontFamily);
  }

  // Tải cài đặt từ SharedPreferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy chủ đề
    final themeName = prefs.getString('theme') ?? 'light';
    _currentTheme = themeName == 'dark'
        ? Themes.darkTheme
        : (themeName == 'yellow' ? Themes.lightYellowTheme : Themes.lightTheme);

    // Lấy cỡ chữ
    _fontSize = prefs.getDouble('fontSize') ?? 16;

    // Lấy kiểu font
    _fontFamily = prefs.getString('fontFamily') ?? 'Serif';

    notifyListeners();
  }
}

class Themes {
  static final ThemeData lightYellowTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFFFF8E1),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
    ),
  );

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
    ),
  );
}
