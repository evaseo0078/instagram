import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // ⭐️ 데이터 import
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/screens/dm_list_screen.dart';
import 'package:instagram/widgets/post_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:instagram/screens/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool showPostedNotification;
  final File? postedImage;
  final bool hasNotificationDot;
  final bool showNotificationBalloon;
  final VoidCallback? onNotificationsTap;

  const HomeScreen({
    super.key,
    this.showPostedNotification = false,
    this.postedImage,
    this.hasNotificationDot = false,
    this.showNotificationBalloon = false,
    this.onNotificationsTap,
  });

  @override
  Widget build(BuildContext context) {
    // ⭐️ [디버깅] 데이터가 몇 개인지 콘솔에 출력합니다.
    print("🔥 현재 시나리오 아이템 개수: ${HOME_FEED_SCENARIO.length}");

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/ic_instagram_logo.png',
          height: 32,
          errorBuilder: (context, error, stackTrace) {
            return const Text('Instagram',
                style: TextStyle(color: Colors.white));
          },
        ),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(CupertinoIcons.heart, color: Colors.black),
                onPressed: onNotificationsTap ??
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsScreen()),
                      );
                    },
              ),
              if (hasNotificationDot)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              if (showNotificationBalloon)
                Positioned(
                  right: -6,
                  top: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: const Text('New comment',
                        style:
                            TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ),
            ],
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
      body: Column(
        children: [
          if (showPostedNotification)
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: postedImage != null
                        ? FileImage(postedImage!)
                        : const AssetImage(
                                'assets/images/profiles/my_profile.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Posted! Way to go',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                  const Icon(Icons.check_circle, color: Colors.blue, size: 18),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
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
                      return SuggestedReelsWidget(
                          videoPaths: item.multiVideoPaths!);
                    }
                    return const SizedBox.shrink();

                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
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
