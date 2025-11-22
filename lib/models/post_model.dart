import 'dart:io';

class PostModel {
  final String username;
  final String userProfilePicAsset;
  final List<String> images;
  final String caption;
  // ⭐️ 댓글 데이터 모델 변경: Map 리스트
  final List<Map<String, dynamic>> comments;
  int likes;
  bool isLiked;
  final DateTime date;

  PostModel({
    required this.username,
    required this.userProfilePicAsset,
    required this.images,
    required this.caption,
    required this.comments, // ⭐️ 변경된 타입 반영
    this.likes = 0,
    this.isLiked = false,
    required this.date,
  });
}
