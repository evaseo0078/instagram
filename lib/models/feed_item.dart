import 'package:instagram/models/post_model.dart';

// 피드 아이템의 종류 (게시물, 광고, 릴스, 추천)
enum FeedItemType { post, ad, reel, suggestedReels }

class FeedItem {
  final FeedItemType type;
  final PostModel? post;
  final String? videoPath;
  final List<String>? multiVideoPaths;

  FeedItem({
    required this.type,
    this.post,
    this.videoPath,
    this.multiVideoPaths,
  });
}
