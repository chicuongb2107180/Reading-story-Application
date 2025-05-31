import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/auth_manager.dart';
import '../../manager/user_manager.dart';
import '../../models/user.dart';

class ProfileInfo extends StatefulWidget {
  final User user;
  final int followCount;
  final int novelCount;
  const ProfileInfo({Key? key, required this.user, required this.followCount, required this.novelCount})
      : super(key: key);

  @override
  State<ProfileInfo> createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  bool _isFollowing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  Future<void> _checkFollowStatus() async {
    final authManager = context.read<AuthManager>();
    // Kiểm tra xem có đang theo dõi người dùng này không
    if (authManager.user?.id != widget.user.id) {
      final isFollowing = await authManager.isFollowing(widget.user.id!);
      setState(() {
        _isFollowing = isFollowing;
      });
    }
  }

  Future<void> _toggleFollowStatus() async {
    final authManager = context.read<AuthManager>();
    setState(() {
      _isLoading = true;
    });
    if (_isFollowing) {
      await authManager.unfollowUser(widget.user);
    } else {
      await authManager.followUser(widget.user);
    }
    setState(() {
      _isFollowing = !_isFollowing;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authManager = context.read<AuthManager>();
    final loggedInUser = authManager.user;

    return Column(
      children: [
        Center(
          child: CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              widget.user.url_avatar!,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.user.username,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        if (loggedInUser?.id != widget.user.id)
          ElevatedButton(
            onPressed: _isLoading ? null : _toggleFollowStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isFollowing ? Icons.person_remove : Icons.person_add,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  _isFollowing ? 'Bỏ theo dõi' : 'Theo dõi',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Column(
              children: [
                Text(
                  widget.novelCount.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Tác phẩm',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const  SizedBox(width: 50),
            Column(
              children: [
                Text(
                  widget.followCount.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Người theo dõi',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
