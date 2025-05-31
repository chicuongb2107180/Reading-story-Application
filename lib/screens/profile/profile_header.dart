import 'dart:ui'; // Để sử dụng hiệu ứng làm mờ
import 'package:flutter/material.dart';
import '../../models/user.dart';
class ProfileHeader extends StatelessWidget {
  final User user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration:  BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            user.url_cover ?? 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
        child: Container(
          color: Colors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}
