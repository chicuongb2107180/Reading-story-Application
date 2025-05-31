import 'package:flutter/material.dart';
import '../../models/novel.dart';
import '../../models/chapter.dart';

class ReadOnlyNovelScreen extends StatelessWidget {
  final Novel novel;
  final Chapter chapter;

  const ReadOnlyNovelScreen({
    super.key,
    required this.novel,
    required this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(novel.novelName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                chapter.title ?? 'Chương không tên',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                chapter.content ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
