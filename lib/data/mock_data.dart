import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';

// ⭐️ [핵심] 게시물 자동 생성기 (틀)
// username: 폴더명 (예: kid_go)
// count: 게시물 개수 (예: 13)
List<PostModel> _generatePosts(String username, String profilePic, int count) {
  return List.generate(count, (index) {
    int postNum = index + 1; // 1번부터 시작 (post1, post2...)

    // ⭐️ 각 게시물의 사진 파일 경로 (기본적으로 1장, 필요하면 리스트에 추가)
    // 형식: assets/images/posts/{username}/post{번호}_1.jpg
    List<String> postImages = [
      'assets/images/posts/$username/post${postNum}_1.jpg',
    ];

    // (만약 특정 게시물에 사진이 더 있다면, 여기서 수동으로 추가하는 로직을 넣을 수도 있습니다.
    //  일단은 기본 1장씩으로 생성하고, 영상에 나온 중요한 '여러 장' 게시물만 아래에서 따로 정의합니다.)

    return PostModel(
      username: username,
      userProfilePicAsset: profilePic,
      images: postImages,
      caption: '$username\'s post #$postNum 📸', // 캡션 자동 생성
      comments: [],
      likes: 100 + (index * 5), // 좋아요 수도 랜덤하게
      date: DateTime.now().subtract(Duration(days: index)), // 날짜도 하루씩 다르게
    );
  });
}

// ⭐️ 1. 유저 데이터 (계정 정의)
final Map<String, UserModel> MOCK_USERS = {
  // --- 괴도 키드 (Kid Go) : 게시물 13개 ---
  'kid_go': UserModel(
    username: 'kid_go',
    name: 'Kid Go',
    bio: 'Phantom Thief 🎩',
    profilePicAsset: 'assets/images/profiles/kid_go.png', // png 확인
    followerCount: 1412,
    followingUsernames: ['conan'],
    // ⭐️ 자동 생성기로 13개 게시물 생성!
    posts: _generatePosts('kid_go', 'assets/images/profiles/kid_go.png', 13),
  ),

  // --- 유미란 (Ran) : 게시물 13개 ---
  'ran': UserModel(
    username: 'ran',
    name: 'Ran Mouri',
    bio: 'Karate 🥋',
    profilePicAsset: 'assets/images/profiles/ran.png',
    followerCount: 8000,
    followingUsernames: ['shinichi', 'sonoko'],
    // ⭐️ 자동 생성기로 13개 게시물 생성!
    posts: _generatePosts('ran', 'assets/images/profiles/ran.png', 13),
  ),

  // --- 코난 (내 계정) ---
  'conan': UserModel(
    username: 'conan',
    name: 'Conan',
    bio: 'Detective 🕵️‍♂️',
    profilePicAsset: 'assets/images/profiles/conan.png',
    followerCount: 4869,
    // ⭐️ 내가 팔로우하는 사람들 (이게 있어야 프로필 'Following' 목록에 뜸)
    followingUsernames: ['kid_go', 'ran', 'rose', 'brown'],
    posts: [],
  ),

  // --- 홍장미 (Rose) ---
  'rose': UserModel(
    username: 'rose',
    name: 'Haibara',
    bio: 'Scientist 💊',
    profilePicAsset: 'assets/images/profiles/rose.png',
    followerCount: 50000,
    followingUsernames: [],
    posts:
        _generatePosts('rose', 'assets/images/profiles/rose.png', 5), // 5개 예시
  ),

  // --- 브라운 박사 (Brown) ---
  'brown': UserModel(
    username: 'brown',
    name: 'Dr. Agasa',
    bio: 'Inventor 💡',
    profilePicAsset: 'assets/images/profiles/brown.png',
    followerCount: 300,
    followingUsernames: [],
    posts:
        _generatePosts('brown', 'assets/images/profiles/brown.png', 3), // 3개 예시
  ),
};

// ⭐️ 2. 홈 피드 시나리오 (영상 순서대로 하드코딩)
// 여기서 '특정 게시물'만 사진을 여러 장으로 바꿔줍니다.
final List<FeedItem> HOME_FEED_SCENARIO = [
  // 1. 릴스
  FeedItem(
    type: FeedItemType.reel,
    videoPath: 'assets/videos/kig_go_video.mp4',
  ),

  // 2. 광고
  FeedItem(type: FeedItemType.ad),

  // 3. 키드 게시물 (13번째 게시물 - 사진 여러장)
  FeedItem(
    type: FeedItemType.post,
    // ⭐️ 키드의 13번째 게시물(인덱스 0이 최신이므로 0번 가져옴)을 가져와서 사진만 수정
    post: MOCK_USERS['kid_go']!.posts[0]
      ..images = [
        'assets/images/posts/kid_go/post13_1.jpg', // 파일명 확인!
        'assets/images/posts/kid_go/post13_2.jpg',
      ],
  ),

  // 4. 광고
  FeedItem(type: FeedItemType.ad),

  // 5. 란 게시물 (13번째)
  FeedItem(
    type: FeedItemType.post,
    post: MOCK_USERS['ran']!.posts[0], // 자동 생성된 13번째(인덱스 0) 사용
  ),

  // 6. 추천 릴스
  FeedItem(
    type: FeedItemType.suggestedReels,
    multiVideoPaths: [
      'assets/videos/video1.mp4',
      'assets/videos/video2.mp4',
      'assets/videos/video3.mp4',
      'assets/videos/video4.mp4',
    ],
  ),
];
