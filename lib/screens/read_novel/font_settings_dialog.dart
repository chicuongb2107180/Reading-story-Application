import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme_picker.dart';
import 'font_size_picker.dart';
import 'font_picker.dart';
import '../../manager/theme_manager.dart';


class FontSettingsDialog extends StatelessWidget {
  const FontSettingsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var fontThemeManager = Provider.of<FontThemeManager>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Cài đặt font chữ",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),

        // Widget chọn theme
        ThemePicker(onThemeChanged: fontThemeManager.changeTheme),
        const SizedBox(height: 20),

        // Widget chọn kích thước chữ
        FontSizePicker(
          currentFontSize: fontThemeManager.fontSize,
          onFontSizeChanged: fontThemeManager.changeFontSize,
        ),
        const SizedBox(height: 20),

        // Widget chọn font chữ
        FontPicker(
          currentFont:  fontThemeManager.fontFamily,
          onFontChanged: fontThemeManager.changeFontFamily,
        ),
      ],
    );
  }
}
