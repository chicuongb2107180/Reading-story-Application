import 'package:flutter/material.dart';
import 'library/store_tab.dart';
import 'library/save_tab.dart';
import 'library/reading_tab.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thư viện'),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.help),
            //   onPressed: () {
            //     // navigatorKey.currentState!.pushNamed('/help');
            //   },
            // ),
            // IconButton(
            //   icon: const Icon(Icons.more_vert),
            //   onPressed: () {
            //     // navigatorKey.currentState!.pushNamed('/more');
            //   },
            // ),
          ],
          bottom: const TabBar(
            labelColor: Colors.black, // Màu chữ tab được chọn
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Đang đọc'),
              Tab(text: 'Lưu trữ'),
              // Tab(text: 'Tải về'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: ReadingTab()),
            Center(child: StoreTab()),
            // Center(child: SaveTab()),
          ],
        ),
      ),
    );
  }
}
