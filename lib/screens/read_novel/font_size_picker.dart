import 'package:flutter/material.dart';

class FontSizePicker extends StatelessWidget {
  final double currentFontSize;
  final ValueChanged<double> onFontSizeChanged;

  const FontSizePicker({
    super.key,
    required this.currentFontSize,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              onFontSizeChanged((currentFontSize - 1).clamp(10, 30));
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'A-',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () {
              onFontSizeChanged((currentFontSize + 1).clamp(10, 30));
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'A+',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
