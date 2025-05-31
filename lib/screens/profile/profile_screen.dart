import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../manager/follow_manager.dart';
import '../../manager/user_manager.dart';
import '/manager/auth_manager.dart';
import 'profile_header.dart';
import 'profile_info.dart';
import 'profile_introduction.dart';
import 'profile_followers.dart';
import '../../models/user.dart';
import 'settings_drawer.dart';
import '../../models/novel.dart';
import '../../manager/novels_manager.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  bool _isSettingsOpen = false;
  bool isLoading = true;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late String userId;
  late bool isCurrentUser;
  User? user;
  List<User> followers = [];
  List<Novel> novels = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(_controller);

    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final currentUser = context.read<AuthManager>().user;
    final userManager = context.read<UserManager>();
    final followManager = context.read<FollowManager>();
    userId = widget.userId ?? currentUser?.id ?? '';
    isCurrentUser = (widget.userId == null || widget.userId == currentUser?.id);
    user = isCurrentUser ? currentUser : await userManager.addUser(userId);

    if (user != null) {
      
      final novelsManager = context.read<NovelsManager>();
      await followManager.fetchFollowers(user!);
      followers = followManager.getFollowers(user!.id!);
      await novelsManager.fetchNovelByUser(user!.id!);

      novels = novelsManager.getNovels();
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleSettings() {
    setState(() {
      _isSettingsOpen = !_isSettingsOpen;
      if (_isSettingsOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ?  const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          )
        : SafeArea(
            child: Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: isCurrentUser && !_isSettingsOpen
                    ? [
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          onPressed: _toggleSettings,
                        ),
                      ]
                    : null,
              ),
              body: Stack(
                children: [
                  ProfileHeader(user: user!),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        if (user != null) ...[
                          ProfileInfo(
                              user: user!, followCount: followers.length, novelCount: novels.length),
                          ProfileIntroduction(user: user!, novels: novels),
                          ProfileFollowers(user: user!, followers: followers),
                        ],
                      ],
                    ),
                  ),
                  if (_isSettingsOpen)
                    GestureDetector(
                      onTap: _toggleSettings,
                      child: Container(
                        color: Colors.black.withOpacity(0.5), // Hiệu ứng mờ
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SlideTransition(
                            position: _offsetAnimation,
                            child: SettingsDrawer(onClose: _toggleSettings),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}
