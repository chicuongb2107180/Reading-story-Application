import 'package:flutter/material.dart';
import 'package:tateworld/models/novel.dart';
import 'package:tateworld/screens/novels/novel_detail_screen.dart';

import '../../models/user.dart';

class ProfileIntroduction extends StatelessWidget {
  final User user;
  final List<Novel> novels;
  const ProfileIntroduction({super.key, required this.user,required this.novels});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giới thiệu',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.introduce?.isNotEmpty == true
                ? user.introduce!
                : 'Chưa có giới thiệu',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          const Text(
            'Truyện đã đăng',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          novels.isEmpty
              ? const Center(
                  child: Column(
                    children: [
                       SizedBox(height: 30),
                      Text('Chưa có truyện nào được đăng',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w200),),
                    ],
                  ),
                )
              :
          Container(
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.18,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: novels.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NovelDetailScreen(novel: novels[index]),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AspectRatio(
                              aspectRatio: 3 / 5,
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(novels[index].urlImageCover),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    novels[index].novelName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.remove_red_eye, size: 12),
                                      const SizedBox(width: 4),
                                      Text(novels[index].totalViews.toString(),
                                          style: const TextStyle(fontSize: 12)),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.star, size: 12),
                                      const SizedBox(width: 4),
                                      Text(novels[index].valuevotes.toString(), style:  TextStyle(fontSize: 12)),
                                      const SizedBox(width: 10),
                                      const Icon(Icons.list, size: 12),
                                      const SizedBox(width: 4),
                                       Text(novels[index].totalChaptersPublished.toString(),style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    novels[index].description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
