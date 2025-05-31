import 'package:flutter/material.dart';

class FontPicker extends StatelessWidget {
  final String currentFont;
  final ValueChanged<String> onFontChanged;

  const FontPicker({
    super.key,
    required this.currentFont,
    required this.onFontChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFontPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: Colors.grey[300],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(currentFont),
            const Icon(Icons.arrow_drop_up),
          ],
        ),
      ),
    );
  }

  void _showFontPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        _buildFontOption(context, 'Serif'),
                        _buildFontOption(context, 'Sans-serif'),
                        _buildFontOption(context, 'Monospace'),
                        _buildFontOption(context, 'Arial'),
                        _buildFontOption(context, 'Times New Roman'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontOption(BuildContext context, String fontName) {
    return ListTile(
      title: Text(fontName),
      onTap: () {
        onFontChanged(fontName);
        Navigator.pop(context);
      },
    );
  }
}
