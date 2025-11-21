// 📍 lib/models/post_model.dart (신규 파일)
import 'dart:io';

class PostModel {
  final String username;
  final String userProfilePicAsset;
  final dynamic image; // ⭐️ File (새 게시물) 또는 String (Asset 경로)
  final String caption;
  final List<String> comments; // (간단하게 문자열 리스트로)
  int likes;
  bool isLiked;

  PostModel({
    required this.username,
    required this.userProfilePicAsset,
    required this.image,
    required this.caption,
    required this.comments,
    this.likes = 0,
    this.isLiked = false,
  });
}
