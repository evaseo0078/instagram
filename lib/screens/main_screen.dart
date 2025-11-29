import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/screens/comments_screen.dart';
import 'package:instagram/screens/home_screen.dart';
import 'package:instagram/screens/notifications_screen.dart';
import 'package:instagram/screens/profile_screen.dart';
import 'package:instagram/screens/reels_screen.dart';
import 'package:instagram/screens/search_screen.dart';
import 'package:instagram/utils/colors.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final myUser = MOCK_USERS['brown']!;
  bool _showPostedNotification = false;
  File? _lastPostedImage;
  PostModel? _latestPostedPost;
  bool _hasNewNotificationDot = false;
  bool _showNotificationBalloon = false;
  bool _conanNotificationSeen = false;
  String? _conanNotificationThumbnail;
  DateTime? _conanCommentCreatedAt;
  Timer? _postedBannerTimer;
  Timer? _conanCommentTimer;
  Timer? _balloonTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _postedBannerTimer?.cancel();
    _conanCommentTimer?.cancel();
    _balloonTimer?.cancel();
    super.dispose();
  }

  void _goToHomeWithNotification() {
    setState(() {
      _selectedIndex = 0;
      _showPostedNotification = true;
    });

    _postedBannerTimer?.cancel();
    _postedBannerTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) setState(() => _showPostedNotification = false);
    });
  }

  void _handleUploadComplete(String imagePath, String caption) {
    final uploadedFile = File(imagePath);

    final newPost = PostModel(
      username: myUser.username,
      userProfilePicAsset: myUser.profilePicAsset,
      images: [imagePath],
      caption: caption,
      comments: [],
      likes: 0,
      isLiked: false,
      date: DateTime.now(),
    );

    setState(() {
      _lastPostedImage = uploadedFile;
      _latestPostedPost = newPost;
      _hasNewNotificationDot = false;
      _showNotificationBalloon = false;
      _conanNotificationSeen = false;
      _conanNotificationThumbnail = imagePath;
      _conanCommentCreatedAt = null;
      myUser.posts.insert(0, newPost);
      HOME_FEED_SCENARIO.insert(
        0,
        FeedItem(
          type: FeedItemType.post,
          post: newPost,
        ),
      );
    });

    _scheduleConanComment(newPost);
    _goToHomeWithNotification();
  }

  void _scheduleConanComment(PostModel post) {
    _conanCommentTimer?.cancel();
    _conanCommentTimer = Timer(const Duration(minutes: 1), () {
      if (!mounted) return;
      setState(() {
        post.comments.add({
          "username": "conan",
          "comment": "Wow! Awesome photo! ??",
          "createdAt": DateTime.now(),
          "isLiked": false,
        });
        _hasNewNotificationDot = true;
        _showNotificationBalloon = true;
        _conanNotificationSeen = false;
        _conanCommentCreatedAt = DateTime.now();
      });

      _balloonTimer?.cancel();
      _balloonTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _showNotificationBalloon = false);
      });
    });
  }

  String _formatRelativeTime(DateTime? time) {
    if (time == null) return '1m';
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  void _openCommentsForPost(PostModel post, {double heightFactor = 0.9}) {
    double sheetHeightFactor = heightFactor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * sheetHeightFactor,
            decoration: const BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: CommentsScreen(
              commentsList: post.comments,
              postOwnerName: post.username,
              onExpandHeight: () {
                if (sheetHeightFactor < 0.9) {
                  setModalState(() => sheetHeightFactor = 0.9);
                }
              },
            ),
          );
        });
      },
    );
  }

  void _openNotifications() {
    final bool wasNew = _hasNewNotificationDot && !_conanNotificationSeen;
    setState(() {
      _hasNewNotificationDot = false;
      _showNotificationBalloon = false;
      if (wasNew) _conanNotificationSeen = true;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsScreen(
          hasConanComment: _latestPostedPost != null,
          conanIsNew: wasNew,
          conanTime: _formatRelativeTime(_conanCommentCreatedAt),
          conanThumbnail: _conanNotificationThumbnail,
          onConanTap: () {
            Navigator.pop(context);
            if (_latestPostedPost != null) {
              _openCommentsForPost(_latestPostedPost!, heightFactor: 0.9);
            }
          },
        ),
      ),
    );
  }

  void _onTabTapped(int index) async {
    if (index != 0) {
      setState(() {
        _showNotificationBalloon = false;
      });
    }

    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            user: myUser,
            isMyProfile: true,
            onUploadComplete: _handleUploadComplete,
          ),
        ),
      );
      return;
    }

    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(
            showPostedNotification: _showPostedNotification,
            postedImage: _lastPostedImage,
            hasNotificationDot: _hasNewNotificationDot,
            showNotificationBalloon: _showNotificationBalloon,
            onNotificationsTap: _openNotifications,
          ),
          const SearchScreen(),
          Container(),
          const ReelsScreen(),
          ProfileScreen(
              user: myUser,
              isMyProfile: true,
              onUploadComplete: _handleUploadComplete),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              activeIcon: Icon(Icons.add_box),
              label: 'Add'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie_creation_outlined),
              activeIcon: Icon(Icons.movie_creation),
              label: 'Reels'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        unselectedItemColor: secondaryColor,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
