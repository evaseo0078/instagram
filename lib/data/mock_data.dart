// 📍 lib/data/mock_data.dart (신규 파일)
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';

// ⭐️ 모든 유저 정보를 담고 있는 중앙 데이터베이스 역할
final Map<String, UserModel> MOCK_USERS = {
  // 1. 내 계정
  'ta_junhyuk': UserModel(
    username: 'ta_junhyuk',
    name: 'puang',
    bio: "I'm gonna be the God of Flutter!",
    profilePicAsset: 'assets/images/my_profile.png', // ⭐️ 1단계에서 준비한 내 프사
    followerCount: 3,
    followingUsernames: ['imwinter', 'aespa_official'], // ⭐️ 내가 팔로우하는 계정
    posts: [
      PostModel(
        username: 'ta_junhyuk',
        userProfilePicAsset: 'assets/images/my_profile.png',
        image:
            'https://placehold.co/600x600/D3E8D3/000000?text=Puang', // ⭐️ 기존 샘플
        caption: 'I love puang',
        comments: ['I love puang'],
        likes: 1,
      ),
    ],
  ),

  // 2. 다른 유저 (영상 4:51)
  'kirby_log': UserModel(
    username: 'kirby_log',
    name: 'kirby',
    bio: 'aespa WINTER',
    profilePicAsset: 'assets/images/kirby_profile.png', // ⭐️ 1단계에서 준비한 프사
    followerCount: 13000000,
    followingUsernames: ['kirby_official'],
    posts: [
      PostModel(
        username: 'kirby_log',
        userProfilePicAsset: 'assets/images/kirby_profile.png',
        image: 'assets/images/kirby_post_1.png', // ⭐️ 1단계에서 준비한 게시물
        caption: '🥰',
        comments: ['so cute!!'],
        likes: 986981,
      ),
      PostModel(
        username: 'kirby_log',
        userProfilePicAsset: 'assets/images/kirby_profile.png',
        image: 'assets/images/kirby_post_2.png', // ⭐️ 1단계에서 준비한 게시물
        caption: 'Polo~',
        comments: [],
        likes: 1234567,
      ),
    ],
  ),

  // 3. 또 다른 유저
  'waddle_dee': UserModel(
    username: 'waddle_dee',
    name: 'Waddle Dee',
    bio: 'Waddle dee official',
    profilePicAsset: 'assets/images/waddle_dee_profile.png', // ⭐️ 1단계에서 준비한 프사
    followerCount: 10000000,
    followingUsernames: [],
    posts: [
      PostModel(
        username: 'waddle_dee',
        userProfilePicAsset: 'assets/images/waddle_dee_profile.png',
        image: 'assets/images/waddle_dee_post_1.png', // ⭐️ 기존 샘플
        caption: 'Hungry! 🔥',
        comments: [],
        likes: 918471,
      ),
    ],
  ),

  // ... (다른 계정들도 이런 식으로 추가)
};
