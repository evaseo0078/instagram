import 'dart:io';

class PostModel {
  final String username;
  final String userProfilePicAsset;
  final List<dynamic> images; // ⭐️ 중요: 이미지 하나가 아니라 '리스트'로 변경 (여러 장 가능)
  final String caption;
  final List<String> comments;
  int likes;
  bool isLiked;
  final bool isReel; // ⭐️ 릴스인지 여부 확인
  final String? videoUrl; // ⭐️ 릴스일 경우 비디오 경로

  PostModel({
    required this.username,
    required this.userProfilePicAsset,
    required this.images, // List<dynamic>
    required this.caption,
    required this.comments,
    this.likes = 0,
    this.isLiked = false,
    this.isReel = false,
    this.videoUrl,
  });
}
