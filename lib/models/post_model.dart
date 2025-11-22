import 'dart:io';

class PostModel {
  final String username;
  final String userProfilePicAsset;
  final List<String> images; // ⭐️ 여기를 List<String>으로 변경
  final String caption;
  final List<String> comments;
  int likes;
  bool isLiked;
  final DateTime date;

  PostModel({
    required this.username,
    required this.userProfilePicAsset,
    required this.images,
    required this.caption,
    required this.comments,
    this.likes = 0,
    this.isLiked = false,
    required this.date,
  });
}
