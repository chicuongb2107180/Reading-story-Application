import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/novels_manager.dart';
import 'novel_edit.dart';

class WritingNovelScreen extends StatefulWidget {
  const WritingNovelScreen({
    super.key,
  });

  @override
  State<WritingNovelScreen> createState() => _WritingNovelScreenState();
}

class _WritingNovelScreenState extends State<WritingNovelScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Viết truyện'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditNovelScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: const Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Đã đăng tải'),
                Tab(text: 'Bản thảo'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  NovePostedListView(),
                  NovelDraftListView(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NovelDraftListView extends StatelessWidget {
  const NovelDraftListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<NovelsManager>().fetchNovels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return NovelDraftGridView();
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class NovelDraftGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final novels = context.watch<NovelsManager>().getNovels();

    if (novels.isEmpty) {
      return const Center(
        child: Text('Bạn chưa có bản thảo nào!'),
      );
    }

    return ListView.builder(
      itemCount: novels.length,
      itemBuilder: (context, index) {
        final novel = novels[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditNovelScreen(novel: novel),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  novel.urlImageCover,
                  width: 80,
                  height: 120,
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
                        'Số chương đã đăng: ${novel.totalChaptersPublished}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${novel.totalChaptersDraft} bản thảo',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _confirmDelete(context, novel.id!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String novelId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa truyện này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await context.read<NovelsManager>().deleteNovel(novelId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Truyện đã được xóa thành công.')),
      );
    }
  }
}

class NovePostedListView extends StatelessWidget {
  const NovePostedListView({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<NovelsManager>().fetchNovels(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return NovelPostedGridView();
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class NovelPostedGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final novels = context.watch<NovelsManager>().getNovels();
    novels.removeWhere((novel) => novel.totalChaptersPublished == 0);

    if (novels.isEmpty) {
      return const Center(
        child: Text('Bạn chưa đăng tải truyện nào!'),
      );
    }

    return ListView.builder(
      itemCount: novels.length,
      itemBuilder: (context, index) {
        final novel = novels[index];

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditNovelScreen(novel: novel),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  novel.urlImageCover,
                  width: 80,
                  height: 120,
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
                        'Số chương đã đăng: ${novel.totalChaptersPublished}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        '${novel.totalChaptersDraft} bản thảo',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _confirmDelete(context, novel.id!);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, String novelId) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa truyện này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await context.read<NovelsManager>().deleteNovel(novelId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Truyện đã được xóa thành công.')),
      );
    }
  }
}
