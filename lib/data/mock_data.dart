import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';

// 🛠️ [도구] 게시물 생성기 (사진 개수 지정 가능)
// username: 폴더명 (예: kid_go)
// postNum: 게시물 번호 (예: 13)
// photoCount: 그 게시물의 사진 장수 (예: 4)
PostModel _makePost(
    String username, String profilePic, int postNum, int photoCount) {
  return PostModel(
    username: username == 'my_posts' ? 'ph.brown' : username, // 내 폴더명만 예외 처리
    userProfilePicAsset: profilePic,
    // ⭐️ 사진 파일명 자동 생성: assets/images/posts/{유저}/post{번호}_{순서}.jpg
    images: List.generate(photoCount, (index) {
      return 'assets/images/posts/$username/post${postNum}_${index + 1}.jpg';
    }),
    caption: 'Post #$postNum by $username 📸',
    comments: [],
    likes: 50 + (postNum * 10),
    date: DateTime.now().subtract(Duration(days: postNum)),
  );
}

// ⭐️ 1. 모든 유저 및 게시물 데이터 정의
final Map<String, UserModel> MOCK_USERS = {
  // 1. 브라운 박사님 (내 계정 - 폴더명: my_posts)
  'brown': UserModel(
    username: 'ph.brown',
    name: 'Dr. Agasa',
    bio: 'Genius Inventor 💡 | Camping ⛺️',
    profilePicAsset: 'assets/images/profiles/my_profile.png',
    followerCount: 1024,
    followingUsernames: [
      'kid_go',
      'ran',
      'shinichi',
      'conan',
      'rose',
      'famous'
    ],
    posts: [
      _makePost('my_posts', 'assets/images/profiles/my_profile.png', 1,
          4), // 1번글 사진 4장
      _makePost('my_posts', 'assets/images/profiles/my_profile.png', 2,
          3), // 2번글 사진 3장
    ],
  ),

  // 2. 괴도 키드 (Kid Go)
  'kid_go': UserModel(
    username: 'kid_go',
    name: 'Kaito Kid',
    bio: 'It\'s Showtime! 🕊️',
    profilePicAsset: 'assets/images/profiles/kid_go.png',
    followerCount: 1412,
    followingUsernames: ['conan'],
    posts: [
      // 필요한 게시물만 쏙쏙 뽑아서 생성 (13번, 12번...)
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 13, 4),
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 12, 3),
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 11, 4),
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 10, 4),
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 1, 2),
    ],
  ),

  // 3. 유미란 (Ran)
  'ran': UserModel(
    username: 'ran',
    name: 'Ran Mouri',
    bio: 'Karate Champion 🥋',
    profilePicAsset: 'assets/images/profiles/ran.png',
    followerCount: 8000,
    followingUsernames: ['shinichi', 'sonoko'],
    posts: [
      _makePost('ran', 'assets/images/profiles/ran.png', 13, 4),
      _makePost('ran', 'assets/images/profiles/ran.png', 12, 4),
      _makePost('ran', 'assets/images/profiles/ran.png', 11, 4),
      _makePost('ran', 'assets/images/profiles/ran.png', 10, 4),
      _makePost('ran', 'assets/images/profiles/ran.png', 1, 2),
    ],
  ),

  // 4. 남도일 (Shinichi)
  'shinichi': UserModel(
    username: 'shinichi',
    name: 'Shinichi Kudo',
    bio: 'Detective of the East 🕵️‍♂️',
    profilePicAsset: 'assets/images/profiles/shinichi.png',
    followerCount: 10000,
    followingUsernames: ['ran'],
    posts: [
      _makePost('shinichi', 'assets/images/profiles/shinichi.png', 13,
          12), // 사진 12장짜리?
      _makePost('shinichi', 'assets/images/profiles/shinichi.png', 12, 4),
      _makePost('shinichi', 'assets/images/profiles/shinichi.png', 10, 4),
    ],
  ),

  // 5. 코난 (Conan)
  'conan': UserModel(
    username: 'conan',
    name: 'Conan Edogawa',
    bio: 'Truth is Always One! ☝️',
    profilePicAsset: 'assets/images/profiles/conan.png',
    followerCount: 4869,
    followingUsernames: ['ran', 'brown'],
    posts: [
      _makePost('conan', 'assets/images/profiles/conan.png', 13, 4),
      _makePost('conan', 'assets/images/profiles/conan.png', 12, 3),
      _makePost('conan', 'assets/images/profiles/conan.png', 10, 2),
    ],
  ),

  // 6. 홍장미 (Rose)
  'rose': UserModel(
    username: 'rose',
    name: 'Haibara Ai',
    bio: 'Scientist 💊',
    profilePicAsset: 'assets/images/profiles/rose.png',
    followerCount: 5000,
    followingUsernames: ['conan', 'brown'],
    posts: [
      _makePost('rose', 'assets/images/profiles/rose.png', 3, 3),
      _makePost('rose', 'assets/images/profiles/rose.png', 2, 2),
      _makePost('rose', 'assets/images/profiles/rose.png', 1, 2),
    ],
  ),

  // 7. 유명한 (Famous)
  'famous': UserModel(
    username: 'famous',
    name: 'Kogoro Mouri',
    bio: 'Sleeping Kogoro 💤',
    profilePicAsset: 'assets/images/profiles/famous.png',
    followerCount: 3000,
    followingUsernames: ['yoko'],
    posts: [
      _makePost('famous', 'assets/images/profiles/famous.png', 14, 4),
      _makePost('famous', 'assets/images/profiles/famous.png', 13, 4),
      _makePost('famous', 'assets/images/profiles/famous.png', 10, 4),
    ],
  ),

  // 8. 아름이 (Areum)
  'areum': UserModel(
    username: 'areum',
    name: 'Ayumi',
    bio: 'Detective Boys 🎀',
    profilePicAsset: 'assets/images/profiles/areum.png',
    followerCount: 500,
    followingUsernames: ['conan'],
    posts: [
      _makePost('areum', 'assets/images/profiles/areum.png', 3, 3),
      _makePost('areum', 'assets/images/profiles/areum.png', 2, 3),
      _makePost('areum', 'assets/images/profiles/areum.png', 1, 3),
    ],
  ),

  // 9. 뭉치 (Mungchi)
  'mungchi': UserModel(
    username: 'mungchi',
    name: 'Genta',
    bio: 'Eel Rice 🍱',
    profilePicAsset: 'assets/images/profiles/mungchi.png',
    followerCount: 400,
    followingUsernames: [],
    posts: [
      _makePost('mungchi', 'assets/images/profiles/mungchi.png', 3, 2),
      _makePost('mungchi', 'assets/images/profiles/mungchi.png', 2, 3),
      _makePost('mungchi', 'assets/images/profiles/mungchi.png', 1, 3),
    ],
  ),

  // 10. 세모 (Se-mo / Triangle)
  'triangle': UserModel(
    username: 'triangle',
    name: 'Mitsuhiko',
    bio: 'Science & Logic 📚',
    profilePicAsset: 'assets/images/profiles/triangle.png',
    followerCount: 450,
    followingUsernames: [],
    posts: [
      _makePost('triangle', 'assets/images/profiles/triangle.png', 2, 2),
      _makePost('triangle', 'assets/images/profiles/triangle.png', 1, 3),
    ],
  ),

  // 11. 인성 (Inseong)
  'inseong': UserModel(
    username: 'inseong',
    name: 'Heiji Hattori',
    bio: 'Detective of the West 🏍️',
    profilePicAsset: 'assets/images/profiles/inseong.png',
    followerCount: 9000,
    followingUsernames: ['shinichi'],
    posts: [
      _makePost('inseong', 'assets/images/profiles/inseong.png', 2, 2),
      _makePost('inseong', 'assets/images/profiles/inseong.png', 1, 4),
    ],
  ),

  // 12. 신형사 (Sin Police)
  'sin_police': UserModel(
    username: 'sin_police',
    name: 'Detective Takagi',
    bio: 'Police Officer 🚓',
    profilePicAsset: 'assets/images/profiles/sin_police.png',
    followerCount: 2000,
    followingUsernames: ['satou'],
    posts: [
      _makePost('sin_police', 'assets/images/profiles/sin_police.png', 2, 4),
      _makePost('sin_police', 'assets/images/profiles/sin_police.png', 1, 2),
    ],
  ),

  // 13. 보라 (Pupple)
  'pupple': UserModel(
    username: 'pupple',
    name: 'Sonoko Suzuki',
    bio: 'Suzuki Group 💎',
    profilePicAsset: 'assets/images/profiles/pupple.png',
    followerCount: 6000,
    followingUsernames: ['ran', 'kid_go'],
    posts: [
      _makePost('pupple', 'assets/images/profiles/pupple.png', 2, 2),
      _makePost('pupple', 'assets/images/profiles/pupple.png', 1, 2),
    ],
  ),
};

// ⭐️ 2. 홈 피드 시나리오
// (영상 순서대로 배치: 릴스 -> 광고 -> 키드(넘기기) -> 광고 -> 란(넘기기) -> 추천릴스)
final List<FeedItem> HOME_FEED_SCENARIO = [
  // 1. 릴스
  FeedItem(
    type: FeedItemType.reel,
    videoPath: 'assets/videos/mop_video_1.mp4',
  ),

  // 2. 광고
  FeedItem(type: FeedItemType.ad),

  // 3. 키드 게시물 (13번째 글, 사진 4장)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['kid_go']!.posts[0], // posts[0]이 위에서 만든 post13
  ),

  // 4. 광고
  FeedItem(type: FeedItemType.ad),

  // 5. 란 게시물 (13번째 글, 사진 4장)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['ran']!.posts[0],
  ),

  // 6. 추천 릴스
  FeedItem(
    type: FeedItemType.suggestedReels,
    multiVideoPaths: [
      'assets/videos/mop_video_1.mp4',
      'assets/videos/mop_video_1.mp4', // 영상이 하나뿐이라 반복 사용
      'assets/videos/mop_video_1.mp4',
      'assets/videos/mop_video_1.mp4',
    ],
  ),

  // 7. 내 게시물 (브라운 박사 1번글)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['brown']!.posts[0],
  ),
];
