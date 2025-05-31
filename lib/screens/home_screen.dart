import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'notification/notification_screen.dart';
import '../manager/novels_manager.dart';
import '../manager/notification_manager.dart';
import './novels/novel_card.dart';
import './novels/section_title.dart';
import '../models/novel.dart';
import '../manager/auth_manager.dart';
import '../screens/admin/mainscreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _fetchNovelLatest;
  late Future<void> _fetchCompletedNovels;
  late Future<void> _fetchHotNovels;
  late Future<void> _fetchNotifications;

  @override
  void initState() {
    super.initState();

    final novelsManager = context.read<NovelsManager>();
    _fetchNovelLatest = novelsManager.fetchNovelLates();
    _fetchCompletedNovels = novelsManager.fetchCompletedNovels();
    _fetchHotNovels = novelsManager.fetchSearchNovels();

    final userId = context.read<AuthManager>().user?.id;
    if (userId != null) {
      _fetchNotifications =
          context.read<NotificationManager>().fetchNotifications(userId);
    } else {
      _fetchNotifications = Future.value();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tate World'),
          actions: [
            Consumer<NotificationManager>(
              builder: (context, notiManager, _) {
                return Stack(
                  children: [
                    Consumer<NotificationManager>(
                      builder: (context, notiManager, _) {
                        return Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications),
                              onPressed: () async {
                                await notiManager
                                    .markAllAsRead();
                                if (context.mounted) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const NotificationScreen(),
                                    ),
                                  );
                                }
                              },
                            ),
                            if (notiManager.unreadCount > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                      minWidth: 20, minHeight: 20),
                                  child: Center(
                                    child: Text(
                                      '${notiManager.unreadCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),

                    if (notiManager.unreadCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints:
                              const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Center(
                            child: Text(
                              '${notiManager.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            if (context.read<AuthManager>().user?.role == 'admin')
              IconButton(
                icon: const Icon(Icons.settings_applications),
                tooltip: 'Chuyển sang trang quản lý',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AdminMainScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Truyện mới cập nhật'),
                FutureBuilderSection(
                  future: _fetchNovelLatest,
                  novelsProvider: (ctx) =>
                      ctx.watch<NovelsManager>().getLatestNovels(),
                ),
                const SectionTitle(title: 'Truyện đã hoàn thành'),
                FutureBuilderSection(
                  future: _fetchCompletedNovels,
                  novelsProvider: (ctx) =>
                      ctx.watch<NovelsManager>().getCompletedNovels(),
                ),
                const SectionTitle(title: 'Truyện hot'),
                FutureBuilderSection(
                  future: _fetchHotNovels,
                  novelsProvider: (ctx) =>
                      ctx.watch<NovelsManager>().getSearchNovels(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FutureBuilderSection extends StatelessWidget {
  final Future<void> future;
  final List<Novel> Function(BuildContext) novelsProvider;

  const FutureBuilderSection({
    super.key,
    required this.future,
    required this.novelsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final novels = novelsProvider(context);
        return novels.isNotEmpty
            ? SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: novels.length,
                  itemBuilder: (context, index) {
                    return NovelCard(novel: novels[index]);
                  },
                ),
              )
            : const Center(child: Text("Không có truyện nào trong mục này."));
      },
    );
  }
}
