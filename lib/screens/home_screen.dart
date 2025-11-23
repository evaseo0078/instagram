import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // ⭐️ 데이터 import
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐️ [디버깅] 데이터가 몇 개인지 콘솔에 출력합니다.
    print("🔥 현재 시나리오 아이템 개수: ${HOME_FEED_SCENARIO.length}");

    return Scaffold(
      appBar: AppBar(
        // 로고 이미지 경로가 맞는지 확인 (안 맞으면 텍스트로 대체됨)
        title: Image.asset(
          'assets/images/ic_instagram_logo.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Instagram',
                style: TextStyle(color: Colors.white));
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.heart, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.paperplane, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DmListScreen()),
              );
            },
          ),
        ],
      ),
      // ⭐️ 리스트가 비어있어도 "No posts yet" 문구를 띄우지 않고 그냥 빈 화면을 보여줍니다.
      body: ListView.builder(
        itemCount: HOME_FEED_SCENARIO.length,
        itemBuilder: (context, index) {
          final item = HOME_FEED_SCENARIO[index];

          switch (item.type) {
            case FeedItemType.post:
              if (item.post != null) {
                return PostWidget(post: item.post!);
              }
              return const SizedBox.shrink();

            case FeedItemType.ad:
              return const AdWidget();

            case FeedItemType.reel:
              if (item.videoPath != null) {
                return SingleReelWidget(videoPath: item.videoPath!);
              }
              return const SizedBox.shrink();

            case FeedItemType.suggestedReels:
              if (item.multiVideoPaths != null) {
                return SuggestedReelsWidget(videoPaths: item.multiVideoPaths!);
              }
              return const SizedBox.shrink();

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

// --- (아래 위젯들은 그대로 둡니다) ---

class AdWidget extends StatelessWidget {
  const AdWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      color: Colors.grey[850],
      alignment: Alignment.center,
      child: const Text('Sponsored Ad', style: TextStyle(color: Colors.white)),
    );
  }
}

class SingleReelWidget extends StatefulWidget {
  final String videoPath;
  const SingleReelWidget({super.key, required this.videoPath});
  @override
  State<SingleReelWidget> createState() => _SingleReelWidgetState();
}

class _SingleReelWidgetState extends State<SingleReelWidget> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    super.initState();
    // ⭐️ 비디오 자동 재생은 막아둡니다 (오류 방지)
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.black,
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller))
          : const Center(
              child: Icon(Icons.play_circle_outline, color: Colors.white)),
    );
  }
}

class SuggestedReelsWidget extends StatelessWidget {
  final List<String> videoPaths;
  const SuggestedReelsWidget({super.key, required this.videoPaths});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Suggested Reels",
                style: TextStyle(fontWeight: FontWeight.bold))),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: videoPaths.length,
            itemBuilder: (context, index) {
              return Container(
                width: 120,
                margin: const EdgeInsets.all(4),
                color: Colors.grey[900],
                child: const Center(
                    child: Icon(Icons.video_collection, color: Colors.white)),
              );
            },
          ),
        ),
      ],
    );
  }
}
