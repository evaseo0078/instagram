import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // ⭐️ 데이터 import
import 'package:instagram/models/feed_item.dart'; // ⭐️ FeedItem import
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/widgets/post_widget.dart'; // ⭐️ PostWidget import
import 'package:video_player/video_player.dart';

class HomeScreen extends StatelessWidget {
  // 생성자에서 데이터를 받지 않고 직접 import한 데이터를 씁니다.
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DmListScreen()),
              );
            },
          ),
        ],
      ),
      // ⭐️ HOME_FEED_SCENARIO 시나리오 사용
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

// --- 아래 위젯들도 같은 파일에 포함시켜주세요 ---

class AdWidget extends StatelessWidget {
  const AdWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 300,
          color: Colors.grey[850],
          alignment: Alignment.center,
          child:
              const Text('Sponsored Ad', style: TextStyle(color: Colors.white)),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          color: Colors.blue,
          width: double.infinity,
          child: const Text('Learn More',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)),
        )
      ],
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
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) => setState(() {}));
    _controller.setLooping(true);
    _controller.setVolume(0.0);
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
      height: 500,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller))
          : const Center(child: CircularProgressIndicator()),
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
                    child: Icon(Icons.play_circle, color: Colors.white)),
              );
            },
          ),
        ),
      ],
    );
  }
}
