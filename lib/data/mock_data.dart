import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';

// ⭐️ 1. 유저 데이터 (계정 만들기)
// 팔로잉 목록을 위해 다양한 캐릭터를 미리 정의합니다.
final Map<String, UserModel> MOCK_USERS = {
  // --- 내 계정 (Conan) ---
  'conan': UserModel(
    username: 'conan',
    name: 'Conan Edogawa',
    bio: 'Detective 🕵️‍♂️ | Soccer ⚽️',
    profilePic: 'assets/images/profiles/conan.png',
    followers: 4869,
    // ⭐️ 내가 팔로우하는 사람들 (영상 4분: 팔로잉 목록에 뜰 계정들)
    following: ['kid_go', 'ran', 'rose', 'brown', 'keroro', 'tooniverse'],
    posts: [],
  ),

  // --- 괴도 키드 (Kid Go) ---
  'kid_go': UserModel(
    username: 'kid_go',
    name: 'Kaito Kid',
    bio: 'The Phantom Thief 🎩🕊️',
    profilePic: 'assets/images/profiles/kid_go.png',
    followers: 1412,
    following: ['conan'],
    posts: [
      // 13번째 게시물 (사진 여러 장)
      PostModel(
        username: 'kid_go',
        userProfilePic: 'assets/images/profiles/kid_go.png',
        images: [
          'assets/images/posts/kid_go/post13_1.jpg', // ⭐️ 보내주신 파일명
          'assets/images/posts/kid_go/post13_2.jpg',
        ],
        caption: 'Ladies and Gentlemen! It\'s Showtime! 🕊️',
        comments: [],
        likes: 10000,
        date: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ],
  ),

  // --- 유미란 (Ran) ---
  'ran': UserModel(
    username: 'ran',
    name: 'Ran Mouri',
    bio: 'Karate Champion 🥋',
    profilePic: 'assets/images/profiles/ran.png',
    followers: 8000,
    following: ['shinichi'],
    posts: [
      // 13번째 게시물 (윈터 느낌)
      PostModel(
        username: 'ran',
        userProfilePic: 'assets/images/profiles/ran.png',
        images: ['assets/images/posts/ran/post13_1.jpg'],
        caption: 'Winter vibe ❄️',
        comments: ['sonoko: So pretty!'],
        likes: 500,
        date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ],
  ),

  // --- 홍장미 (Rose) ---
  'rose': UserModel(
    username: 'rose',
    name: 'Haibara Ai',
    bio: 'Scientist 💊',
    profilePic: 'assets/images/profiles/rose.png',
    followers: 50000,
    following: [],
    posts: [],
  ),

  // --- 브라운 박사 (Brown) ---
  'brown': UserModel(
    username: 'brown',
    name: 'Dr. Agasa',
    bio: 'Inventor 💡',
    profilePic: 'assets/images/profiles/brown.png',
    followers: 300,
    following: [],
    posts: [],
  ),

  // --- 케로로 ---
  'keroro': UserModel(
    username: 'keroro',
    name: 'Keroro Gunso',
    bio: 'Kero Kero ⭐',
    profilePic: 'assets/images/profiles/keroro.png',
    followers: 55,
    following: [],
    posts: [],
  ),

  // --- 투니버스 ---
  'tooniverse': UserModel(
    username: 'tooniverse',
    name: 'Tooniverse',
    bio: 'Animation Channel 📺',
    profilePic: 'assets/images/profiles/tooniverse.png',
    followers: 1000000,
    following: [],
    posts: [],
  ),
};

// ⭐️ 2. 홈 피드 시나리오 (영상 2번 시나리오)
// 영상 순서: 릴스 -> 광고 -> 키드 게시물(넘기기) -> 광고 -> 란 게시물 -> 추천 릴스
final List<FeedItem> HOME_FEED_SCENARIO = [
  // 1. 릴스 (kig_go_video)
  FeedItem(
    type: FeedItemType.reel,
    videoPath: 'assets/videos/kig_go_video.mp4', // ⭐️ 파일명 확인!
  ),

  // 2. 광고
  FeedItem(type: FeedItemType.ad),

  // 3. 키드 게시물 (넘기기 가능)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['kid_go']!.posts[0], // 위에서 만든 게시물 가져오기
  ),

  // 4. 광고
  FeedItem(type: FeedItemType.ad),

  // 5. 란 게시물 (윈터)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['ran']!.posts[0], // 위에서 만든 게시물 가져오기
  ),

  // 6. 추천 릴스 (나머지 비디오 4개)
  FeedItem(
    type: FeedItemType.suggestedReels,
    multiVideoPaths: [
      'assets/videos/video1.mp4', // ⭐️ 실제 파일명으로 바꾸세요
      'assets/videos/video2.mp4',
      'assets/videos/video3.mp4',
      'assets/videos/video4.mp4',
    ],
  ),
];
