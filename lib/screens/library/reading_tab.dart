import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../novels/novel_detail_screen.dart';
import '../../models/novel.dart';
import '../../manager/novels_manager.dart';

class ReadingTab extends StatefulWidget {
  const ReadingTab({super.key});

  @override
  State<ReadingTab> createState() => _ReadingTabState();
}

class _ReadingTabState extends State<ReadingTab> {
  late Future<void> _fetchReadingNovel;

  @override
  void initState() {
    super.initState();
    _fetchReadingNovel = context.read<NovelsManager>().fetchReadingNovel();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchReadingNovel,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List<Novel> novels = context.watch<NovelsManager>().getReadingNovels();

        if (novels.isEmpty) {
          return const Center(
            child: Text("Bạn chưa có truyện nào đang đọc!"),
          );
        }
        return _buildReadingTab(novels: novels);
      },
    );
  }

  Widget _buildReadingTab({required List<Novel> novels}) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: SizedBox(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.41,
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 10,
          ),
          itemCount: novels.length,
          itemBuilder: (context, index) {
            return _buildNovelCard(context: context, novel: novels[index]);
          },
        ),
      ),
    );
  }

  Widget _buildNovelCard({
    required BuildContext context,
    required Novel novel,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NovelDetailScreen(novel: novel),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                novel.urlImageCover,
                fit: BoxFit.cover,
                height: 200,
                width: 140,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    'assets/avatardefault.jpg',
                    fit: BoxFit.cover,
                    height: 200,
                    width: 140,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: LinearProgressIndicator(
                value: novel.progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              novel.novelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      novel.valuevotes.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      novel.totalChaptersPublished.toString(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
