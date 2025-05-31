import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/novels_manager.dart';
import '../../manager/database_manager.dart';

import '../novels/novel_detail_screen.dart';
import '../../models/novel.dart';

class SaveTab extends StatefulWidget {
  const SaveTab({super.key});

  @override
  State<SaveTab> createState() => _SaveTabState();
}

class _SaveTabState extends State<SaveTab> {
  late Future<void> _fetchSavedNovels;

  @override
  void initState() {
    super.initState();
    _fetchSavedNovels = context.read<DatabaseManager>().fetchSavedNovels();
  }

  @override
  Widget build(BuildContext context) {
    final novels = NovelsManager().getNovels();
    return FutureBuilder(
      future: _fetchSavedNovels,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        List<Novel> novels = context
            .watch<DatabaseManager>()
            .getSavedNovels()
            .map((savedNovel) => savedNovel)
            .toList();
        if (novels.isEmpty) {
          return const Center(
            child: Text("Bạn chưa tải truyện nào!"),
          );
        }

        return _buildSavedNovels(novels: novels);
      },
    );
  }

  Widget _buildSavedNovels({required List<Novel> novels}) {
    print(novels);
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
              ),
            ),
            const SizedBox(height: 4),
            Text(
              novel.novelName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      color: Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${novel.totalChaptersPublished}',
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
