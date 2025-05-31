import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manager/novels_manager.dart';
import '../models/novel.dart';
import '../screens/novels/novel_detail_screen.dart';

class SearchNovelScreen extends StatefulWidget {
  const SearchNovelScreen({super.key});

  @override
  State<SearchNovelScreen> createState() => _SearchNovelScreenState();
}

class _SearchNovelScreenState extends State<SearchNovelScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<void> _fetchNovels;

  void _performSearch() {
    final searchKeyword = _searchController.text;
    if (searchKeyword.isNotEmpty) {
      _fetchNovels = context
          .read<NovelsManager>()
          .fetchSearchNovels(keyWord: searchKeyword);
    } else {
      _fetchNovels = context.read<NovelsManager>().fetchSearchNovels();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final initialKeyword = _searchController.text;
    _fetchNovels = context.read<NovelsManager>().fetchSearchNovels(
          keyWord: initialKeyword.isNotEmpty ? initialKeyword : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm truyện...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _fetchNovels,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final novels = context.watch<NovelsManager>().getSearchNovels();
                if (novels.isEmpty) {
                  return const Center(
                    child: Text('Không tìm thấy truyện nào'),
                  );
                }
                return NovelListView(novels: novels);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NovelListView extends StatelessWidget {
  final List<Novel> novels;
  const NovelListView({super.key, required this.novels});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
        itemCount: novels.length,
        itemBuilder: (context, index) {
          final novel = novels[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NovelDetailScreen(novel: novel),
                ),
              );
            },
            child: Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      novel.urlImageCover,
                      width: 110,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            novel.novelName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Chương: ${novel.totalChaptersPublished}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Lượt xem: ${novel.totalViews}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tác giả: ${novel.author?.name ?? "Không rõ"}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              children: novel.categories
                                      ?.take(6)
                                      .map((category) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: Chip(
                                        label: Text(
                                          category.name,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black,
                                            shadows: [
                                              Shadow(
                                                offset: Offset(0.5, 0.5),
                                                blurRadius: 2.0,
                                                color: Color(0xFFFFD1DC),
                                              ),
                                            ],
                                          ),
                                        ),
                                        backgroundColor: Colors.grey[200],
                                        labelPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                        padding: const EdgeInsets.all(4),
                                      ),
                                    );
                                  }).toList() ??
                                  [],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
