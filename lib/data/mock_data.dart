// 📍 lib/data/mock_data.dart (최종 수정본)
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';

// 🛠️ [도구] 게시물 생성기
PostModel _makePost(
    String username, String profilePic, int postNum, int photoCount) {
  // 'my_posts' 폴더를 쓰는 'brown' 유저만 이름 예외 처리
  String displayUsername = (username == 'my_posts') ? 'ph.brown' : username;

  return PostModel(
    username: displayUsername,
    userProfilePicAsset: profilePic,
    // ⭐️ 파일명 규칙: assets/images/posts/{폴더명}/post{번호}_{순서}.jpg
    // (보내주신 캡처본에 따르면 확장자가 .jpg가 아닌 파일이 있을 수 있으니 확인 필요하나,
    // 통상적으로 jpg라고 가정합니다. 만약 안 뜨면 png로 바꿔야 합니다.)
    images: List.generate(photoCount, (index) {
      return 'assets/images/posts/$username/post${postNum}_${index + 1}.jpg'; // ⭐️ jpg 확인
    }),
    caption: 'Post #$postNum by $displayUsername 📸',
    comments: [],
    likes: 50 + (postNum * 10),
    date: DateTime.now().subtract(Duration(days: postNum)),
  );
}

// ⭐️ 1. 모든 유저 데이터 정의 (8개 + 5개 = 총 13명)
final Map<String, UserModel> MOCK_USERS = {
  // 1. 브라운 박사님 (폴더명: my_posts)
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
      'famous',
      'areum',
      'mungchi',
      'triangle',
      'inseong',
      'sin_police',
      'pupple'
    ],
    posts: [
      _makePost('my_posts', 'assets/images/profiles/my_profile.png', 2, 3),
      _makePost('my_posts', 'assets/images/profiles/my_profile.png', 1, 4),
    ],
  ),

  // 2. 괴도 키드 (kid_go)
  'kid_go': UserModel(
    username: 'kid_go',
    name: 'Kaito Kid',
    bio: 'It\'s Showtime! 🕊️',
    profilePicAsset: 'assets/images/profiles/kid_go.png',
    followerCount: 1412,
    followingUsernames: ['conan'],
    posts: [
      // 캡처해주신 폴더에 13번까지 있는 것 확인됨
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 13, 4),
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 12, 3),
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 11, 4),
      _makePost('kid_go', 'assets/images/profiles/kid_go.png', 10, 4),
    ],
  ),

  // 3. 유미란 (ran)
  'ran': UserModel(
    username: 'ran',
    name: 'Ran Mouri',
    bio: 'Karate Champion 🥋',
    profilePicAsset: 'assets/images/profiles/ran.png',
    followerCount: 8000,
    followingUsernames: ['shinichi', 'pupple'], // sonoko -> pupple
    posts: [
      // ⭐️ 13번 게시물(첫번째)에 댓글 데이터를 실제로 넣어줍니다.
      PostModel(
        username: 'kid_go',
        userProfilePicAsset: 'assets/images/profiles/kid_go.png',
        images: List.generate(
            4,
            (index) =>
                'assets/images/posts/kid_go/post13_${index + 1}.jpg'), // jpg 확인
        caption: 'Post #13 by kid_go 📸',
        likes: 180,
        date: DateTime.now().subtract(const Duration(days: 1)),
        comments: [
          // ⭐️ 이 데이터가 있어야 댓글 창에 뜹니다!
          {
            "username": "un.k1o",
            "comment": "얼굴을 저렇게 가까이 들이대는데 전혀 위화감이 없음 ㅋㅋㅋㅋㅋㅋ 미녀의맛tv🥰🥰",
            "time": "12s",
            "isLiked": true,
          }
        ],
      ),
      _makePost('ran', 'assets/images/profiles/ran.png', 12, 4),
      _makePost('ran', 'assets/images/profiles/ran.png', 11, 4),
    ],
  ),

  // 4. 남도일 (shinichi)
  'shinichi': UserModel(
    username: 'shinichi',
    name: 'Shinichi Kudo',
    bio: 'Detective of the East 🕵️‍♂️',
    profilePicAsset: 'assets/images/profiles/shinichi.png',
    followerCount: 10000,
    followingUsernames: ['ran'],
    posts: [
      _makePost('shinichi', 'assets/images/profiles/shinichi.png', 13, 12),
      _makePost('shinichi', 'assets/images/profiles/shinichi.png', 12, 4),
    ],
  ),

  // 5. 코난 (conan)
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
    ],
  ),

  // 6. 홍장미 (rose)
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
    ],
  ),

  // 7. 유명한 (famous)
  'famous': UserModel(
    username: 'famous',
    name: 'Kogoro Mouri',
    bio: 'Sleeping Kogoro 💤',
    profilePicAsset: 'assets/images/profiles/famous.png',
    followerCount: 3000,
    followingUsernames: [],
    posts: [
      _makePost('famous', 'assets/images/profiles/famous.png', 14, 4),
      _makePost('famous', 'assets/images/profiles/famous.png', 13, 4),
    ],
  ),

  // 8. 아름이 (areum)
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
    ],
  ),

  // 9. 뭉치 (mungchi)
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
    ],
  ),

  // 10. 세모 (triangle)
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

  // 11. 인성 (inseong)
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

  // 12. 신형사 (sin_police)
  'sin_police': UserModel(
    username: 'sin_police',
    name: 'Detective Takagi',
    bio: 'Police Officer 🚓',
    profilePicAsset: 'assets/images/profiles/sin_police.png',
    followerCount: 2000,
    followingUsernames: [],
    posts: [
      _makePost('sin_police', 'assets/images/profiles/sin_police.png', 2, 4),
      _makePost('sin_police', 'assets/images/profiles/sin_police.png', 1, 2),
    ],
  ),

  // 13. 보라 (pupple)
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

// ⭐️ 2. 홈 피드 시나리오 (영상 시나리오 반영)
// 릴스(kid_go) -> 광고 -> 키드(13번) -> 광고 -> 란(13번) -> 추천릴스(4개)
// 📍 lib/data/mock_data.dart 의 맨 아래 부분

// ⭐️ 2. 홈 피드 시나리오
final List<FeedItem> HOME_FEED_SCENARIO = [
  // 1. 릴스 (일단 주석 처리! 비디오 문제 원천 차단)
  // FeedItem(
  //   type: FeedItemType.reel,
  //   videoPath: 'assets/video/kid_go_video.mp4',
  // ),

  // 2. 광고 (주석 처리)
  // FeedItem(type: FeedItemType.ad),

  // ⭐️ 3. 키드 게시물 (사진) -> 이게 맨 위로 오게 됩니다.
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['kid_go']!.posts[0],
  ),

  // 4. 광고 (주석 처리)
  // FeedItem(type: FeedItemType.ad),

  // 5. 란 게시물 (사진)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['ran']!.posts[0],
  ),

  // 6. 추천 릴스 (⭐️ 여기도 중요! 이것도 비디오를 로딩하므로 주석 처리하세요)
  // FeedItem(
  //   type: FeedItemType.suggestedReels,
  //   multiVideoPaths: [
  //     'assets/video/suggested_reels_1.mp4',
  //     'assets/video/suggested_reels_2.mp4',
  //     'assets/video/suggested_reels_3.mp4',
  //     'assets/video/suggested_reels_4.mp4',
  //   ],
  // ),

  // 7. 내 게시물 (사진)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['brown']!.posts[0],
  ),
];
