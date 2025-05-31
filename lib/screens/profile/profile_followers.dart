import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'profile_screen.dart';
import '../../models/user.dart';
import '../../manager/user_manager.dart';


class ProfileFollowers extends StatefulWidget {
  final User user;
  final List<User> followers;

  const ProfileFollowers(
      {Key? key, required this.user, required this.followers})
      : super(key: key);

  @override
  State<ProfileFollowers> createState() => _ProfileFollowersState();
}

class _ProfileFollowersState extends State<ProfileFollowers> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danh sách người theo dõi',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: widget.followers.isEmpty
                ? const Center(
                    child: Text('Chưa có người theo dõi'),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.followers.length,
                    itemBuilder: (context, index) {
                      final follow = widget.followers[index];
                      return Card(
                        child: SizedBox(
                          width: 100,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(userId: follow.id),
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: follow.url_avatar != ''
                                      ? NetworkImage(follow.url_avatar!)
                                      : const AssetImage('assets/avatardefault.jpg')
                                          as ImageProvider,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  follow.name,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w300,
                                    overflow: TextOverflow.ellipsis,
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
