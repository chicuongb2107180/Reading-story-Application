import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/novel.dart';
import 'novel_description.dart';
import '../util/helper.dart';
import '../read_novel/read_novel.dart';
import '../profile/profile_screen.dart';

import '../../manager/chapter_manager.dart';
import '../../manager/storage_manager.dart';
import '../../manager/database_manager.dart';
import '../../manager/novels_manager.dart';

class NovelDetailScreen extends StatefulWidget {
  final Novel novel;

  const NovelDetailScreen({required this.novel, super.key});

  @override
  State<NovelDetailScreen> createState() => _NovelDetailScreenState();
}

class _NovelDetailScreenState extends State<NovelDetailScreen> {
  late Future<void> _fetchChapters;
  bool? isStorage;

  @override
  void initState() {
    super.initState();
    _fetchChapters =
        context.read<ChapterManager>().fetchChapters(widget.novel.id!);
    isStorage = widget.novel.isStorage;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.novel.imageAuthAvatar);

    return FutureBuilder<void>(
      future: _fetchChapters,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(widget.novel.novelName),
              actions: <Widget>[
                // IconButton(
                //   icon: const Icon(Icons.share),
                //   onPressed: () {},
                // ),
                // IconButton(
                //   icon: const Icon(Icons.more_vert),
                //   onPressed: () {},
                // )
              ],
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        } else {
          return SafeArea(
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Text(widget.novel.novelName),
                actions: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {},
                  ),
                  PopupMenuButton(
                    color: Colors.white,
                    icon: const Icon(Icons.more_vert_sharp),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          child: const Text('Tải về'),
                          onTap: () async {
                            await context
                                .read<DatabaseManager>()
                                .saveNovel(widget.novel.id!);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã tải về'),
                              ),
                            );
                          },
                        ),
                      ];
                    },
                  ),
                ],
              ),
              body: SingleChildScrollView(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 50),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.novel.urlImageCover,
                                width: 200,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    userId: widget.novel.author?.id!,
                                  ),
                                )),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundImage: NetworkImage(
                                        widget.novel.author!.url_avatar!),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.novel.author!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (isStorage!) {
                                        context
                                            .read<StorageManager>()
                                            .removeStorage(widget.novel.id!);
                                      } else {
                                        context
                                            .read<StorageManager>()
                                            .addStorage(widget.novel.id!);
                                      }
                                      setState(() {
                                        isStorage = !isStorage!;
                                      });
                                    },
                                    icon: Icon(
                                      Icons.bookmark,
                                      color: isStorage!
                                          ? Colors.blue
                                          : Colors.grey,
                                      size: 30,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Đánh giá',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      Text(
                                        widget.novel.valuevotes.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Lượt xem',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Helper.formatNumber(
                                        widget.novel.totalViews!),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Chương',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.novel.totalChaptersPublished
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Thể loại',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: [
                                  for (var category in widget.novel.categories!)
                                    Chip(
                                      label: Text(
                                        category.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                          NovelDescription(
                              description: widget.novel.description),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadNovel(
                                        id: context
                                            .read<ChapterManager>()
                                            .chapters
                                            .last
                                            .id!,
                                        novel: widget.novel,
                                      ),
                                    ),
                                  );
                                  await context
                                      .read<ChapterManager>()
                                      .fetchChapters(widget.novel.id!);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Đọc mới nhất',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadNovel(
                                        id: context
                                            .read<ChapterManager>()
                                            .chapters[0]
                                            .id!,
                                        novel: widget.novel,
                                      ),
                                    ),
                                  );
                                  await context
                                      .read<ChapterManager>()
                                      .fetchChapters(widget.novel.id!);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Đọc từ đầu',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Danh sách chương',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 200,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        for (var i = 0;
                                            i <
                                                widget.novel
                                                    .totalChaptersPublished!;
                                            i++)
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(
                                              'Chương ${i + 1}: ${context.watch<ChapterManager>().chapters[i].title}',
                                              style: context
                                                      .watch<ChapterManager>()
                                                      .chapters[i]
                                                      .isRead
                                                  ? const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey,
                                                    )
                                                  : const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black,
                                                    ),
                                            ),
                                            trailing: const Icon(
                                                Icons.arrow_forward_ios),
                                            onTap: () async {
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ReadNovel(
                                                    id: context
                                                        .read<ChapterManager>()
                                                        .chapters[i]
                                                        .id!,
                                                    novel: widget.novel,
                                                  ),
                                                ),
                                              );
                                              await context
                                                  .read<ChapterManager>()
                                                  .fetchChapters(
                                                      widget.novel.id!);
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
