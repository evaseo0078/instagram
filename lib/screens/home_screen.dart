import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:video_player/video_player.dart'; // 비디오용

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.asset('assets/images/ic_instagram_logo.png', height: 32),
        actions: [
          IconButton(icon: const Icon(CupertinoIcons.heart), onPressed: () {}),
          IconButton(
              icon: const Icon(CupertinoIcons.paperplane),
              onPressed: () {
                // ⭐️ DM 화면으로 이동
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DMListScreen()),
                );
              }),
        ],
      ),
      // ⭐️ 시나리오 리스트를 순서대로 보여줌
      body: ListView.builder(
        itemCount: HOME_FEED_SCENARIO.length,
        itemBuilder: (context, index) {
          final item = HOME_FEED_SCENARIO[index];

          switch (item.type) {
            case FeedItemType.post:
              return PostWidget(post: item.post!);

            case FeedItemType.ad:
              return const AdWidget();

            case FeedItemType.reel:
              return SingleReelWidget(videoPath: item.videoPath!);

            case FeedItemType.suggestedReels:
              return SuggestedReelsWidget(videoPaths: item.multiVideoPaths!);

            default:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

// ---------------------------------------------
// 👇 아래 위젯들을 같은 파일 하단이나 별도 파일에 두세요
// ---------------------------------------------

class AdWidget extends StatelessWidget {
  const AdWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      color: Colors.grey[200],
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: const Text('Sponsored Ad', style: TextStyle(color: Colors.black)),
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
    // ⭐️ 에셋 비디오 재생
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) => setState(() {}));
    _controller.setLooping(true);
    _controller.setVolume(0.0); // 피드에서는 소리 끔
    _controller.play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class SuggestedReelsWidget extends StatelessWidget {
  final List<String> videoPaths;
  const SuggestedReelsWidget({super.key, required this.videoPaths});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: videoPaths.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.all(4),
            color: Colors.black,
            child: const Center(
                child: Icon(Icons.play_circle, color: Colors.white)),
          );
        },
      ),
    );
  }
}
