// 📍 lib/models/user_model.dart (신규 파일)
import 'package:instagram/models/post_model.dart';

class UserModel {
  final String username;
  String name;
  String bio;
  String profilePicAsset;
  final List<PostModel> posts;
  final List<String> followingUsernames; // ⭐️ 팔로우하는 유저 이름 목록
  int followerCount;

  UserModel({
    required this.username,
    required this.name,
    required this.bio,
    required this.profilePicAsset,
    required this.posts,
    required this.followingUsernames,
    required this.followerCount,
  });
}
