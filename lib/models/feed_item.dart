import 'package:instagram/models/post_model.dart';

// 피드에 들어갈 수 있는 아이템의 종류 4가지
enum FeedItemType { post, ad, reel, suggestedReels }

class FeedItem {
  final FeedItemType type;
  final PostModel? post; // 게시물일 때 사용
  final String? videoPath; // 릴스(비디오)일 때 사용
  final List<String>? multiVideoPaths; // 추천 릴스(여러 개)일 때 사용

  FeedItem({
    required this.type,
    this.post,
    this.videoPath,
    this.multiVideoPaths,
  });
}
