import 'dart:io';

import 'user.dart';

class Follow {
  User follower;
  User following;
  Follow({
    required this.follower,
    required this.following,
  });
  Follow copyWith({
    User? follower,
    User? following,
  }) {
    return Follow(
      follower: follower ?? this.follower,
      following: following ?? this.following,
    );
  }

}
