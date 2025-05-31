import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/novel.dart';
import '../../manager/current_chapter_manager.dart';

import '../../manager/chapter_manager.dart';
import 'read_novel.dart';

class ChapterList extends StatelessWidget {
  final Novel novel;

  const ChapterList({
    super.key,
    required this.novel,
  });

  @override
  Widget build(BuildContext context) {
    final currentChapter =
        context.watch<CurrentChapterManager>().currentChapter;

    return Align(
      alignment: Alignment.centerRight,
      child: SafeArea(
        child: Material(
          color: Colors.white,
          elevation: 16,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.68,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị ảnh truyện và tên truyện
                Row(
                  children: [
                    Image.network(
                      novel.urlImageCover,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tên truyện: ${novel.novelName}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Danh sách chương:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                // Hiển thị danh sách chương bằng ListView
                Expanded(
                  child: ListView.builder(
                    itemCount: context.watch<ChapterManager>().chapters.length,
                    itemBuilder: (BuildContext context, int index) {
                      bool isCurrentChapter = currentChapter != null &&
                          currentChapter.id ==
                              context
                                  .watch<ChapterManager>()
                                  .chapters[index]
                                  .id;

                      return Container(
                        color: isCurrentChapter
                            ? Colors.orange[100]
                            : Colors.transparent,
                        child: ListTile(
                          leading: const Icon(Icons.book, color: Colors.orange),
                          title: Text(
                            'Chương ${index + 1}: ${context.watch<ChapterManager>().chapters[index].title}',
                            style: TextStyle(
                              color: isCurrentChapter
                                  ? Colors.orange
                                  : Colors.black,
                                  fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReadNovel(
                                  id: context
                                      .watch<ChapterManager>()
                                      .chapters[index]
                                      .id!,
                                  novel: novel,
                                ),
                              ),
                              (Route<dynamic> route) => route.isFirst,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
