// 📍 lib/screens/profile_screen.dart (전체 덮어쓰기)

import 'dart:async'; // 타이머 사용
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/screens/edit_filter_screen.dart';
import 'package:instagram/screens/gallery_picker_screen.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/screens/profile_feed_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isMyProfile;

  const ProfileScreen({
    super.key,
    required this.user,
    this.isMyProfile = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    final myUser = MOCK_USERS['brown']!;
    _isFollowing = myUser.followingUsernames.contains(widget.user.username);
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
      final myUser = MOCK_USERS['brown']!;
      if (_isFollowing) {
        if (!myUser.followingUsernames.contains(widget.user.username)) {
          myUser.followingUsernames.add(widget.user.username);
        }
      } else {
        myUser.followingUsernames.remove(widget.user.username);
      }
    });
  }

  // ⭐️ 사진 업로드 시작 (프로필 화면에서 바로 추가)
  Future<void> _startUploadProcess() async {
    final File? originalFile = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GalleryPickerScreen()),
    );

    if (originalFile != null) {
      if (!mounted) return;
      final File? filteredFile = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditFilterScreen(imageFile: originalFile)),
      );

      if (filteredFile != null && mounted) {
        final String? caption = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddPostScreen(imageFile: filteredFile)),
        );

        if (caption != null && mounted) {
          setState(() {
            // 1. 새 게시물 생성
            final newPost = PostModel(
              username: widget.user.username,
              userProfilePicAsset: widget.user.profilePicAsset,
              images: [filteredFile.path],
              caption: caption,
              comments: [],
              likes: 0,
              date: DateTime.now(),
            );

            // 2. 내 게시물 리스트 맨 앞에 추가
            widget.user.posts.insert(0, newPost);

            // 3. 홈 피드 시나리오에도 추가
            HOME_FEED_SCENARIO.insert(
                0, FeedItem(type: FeedItemType.post, post: newPost));

            // ⭐️ 4. [자동 댓글] 5초 뒤 Conan 등장
            Timer(const Duration(seconds: 5), () {
              if (mounted) {
                setState(() {
                  newPost.likes++;
                  newPost.comments.add({
                    "username": "conan",
                    "comment": "Wow! Awesome photo! 🔥",
                    "time": "Just now",
                    "isLiked": false,
                  });
                });
              }
            });
          });
        }
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    if (!widget.isMyProfile) return;

    File? currentProfilePicFile;
    if (!widget.user.profilePicAsset.startsWith('assets/')) {
      currentProfilePicFile = File(widget.user.profilePicAsset);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: widget.user.name,
          currentBio: widget.user.bio,
          currentProfilePic: currentProfilePicFile,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        widget.user.name = result['name'];
        widget.user.bio = result['bio'];
        final newImageFile = result['image'] as File?;
        if (newImageFile != null) {
          widget.user.profilePicAsset = newImageFile.path;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<PostModel> myPosts = widget.user.posts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: widget.isMyProfile
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Text(
          widget.user.username,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        actions: [
          if (widget.isMyProfile) ...[
            IconButton(
                icon: const Icon(Icons.add_box_outlined, color: primaryColor),
                onPressed: _startUploadProcess),
            IconButton(
                icon: const Icon(Icons.menu, color: primaryColor),
                onPressed: () {}),
          ]
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 프로필 상단 정보
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text("Share a\nnote",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 10)),
                                ),
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: widget
                                              .user.profilePicAsset
                                              .startsWith('assets/')
                                          ? AssetImage(
                                                  widget.user.profilePicAsset)
                                              as ImageProvider
                                          : FileImage(File(
                                              widget.user.profilePicAsset)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                          color: backgroundColor,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.add_circle,
                                          color: Colors.black, size: 24),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                _buildStatColumn('${myPosts.length}', 'posts'),
                                const SizedBox(width: 20),
                                _buildStatColumn('${widget.user.followerCount}',
                                    'followers'),
                                const SizedBox(width: 20),
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FollowingListScreen(
                                                      followingUsernames: widget
                                                          .user
                                                          .followingUsernames)));
                                    },
                                    child: _buildStatColumn(
                                        '${widget.user.followingUsernames.length}',
                                        'following')),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(widget.user.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.user.bio),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.isMyProfile
                                    ? _navigateToEditProfile
                                    : _toggleFollow,
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      widget.isMyProfile || _isFollowing
                                          ? Colors.grey[200]
                                          : Colors.blue,
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                ),
                                child: Text(
                                  widget.isMyProfile
                                      ? 'Edit profile'
                                      : (_isFollowing ? 'Following' : 'Follow'),
                                  style: TextStyle(
                                      color:
                                          (widget.isMyProfile || _isFollowing)
                                              ? primaryColor
                                              : Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.grey[200],
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Share profile',
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person_add_outlined,
                                  size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.person_pin_outlined)),
                    ],
                    indicatorColor: primaryColor,
                    labelColor: primaryColor,
                    unselectedLabelColor: secondaryColor,
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildPostGrid(myPosts),
              const Center(child: Text("No tagged posts")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: secondaryColor)),
      ],
    );
  }

  Widget _buildPostGrid(List<PostModel> posts) {
    final int itemCount = widget.isMyProfile ? posts.length + 1 : posts.length;

    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // 1. 내 프로필 업로드 버튼 (+)
        if (widget.isMyProfile && index == 0) {
          return GestureDetector(
            onTap: _startUploadProcess,
            child: Container(
              color: Colors.grey[100],
              child: const Icon(Icons.add, size: 40, color: Colors.grey),
            ),
          );
        }

        // 2. 실제 게시물 인덱스 계산
        // 내 프로필이면 +버튼 때문에 index가 1 밀려있으므로 -1 해줌
        final int postIndex = widget.isMyProfile ? index - 1 : index;
        final post = posts[postIndex];
        final imagePath = post.images.isNotEmpty ? post.images[0] : '';

        // ⭐️ 3. 사진 클릭 시 피드 화면으로 이동 (연동 핵심)
        return GestureDetector(
          onTap: () async {
            // 피드 화면으로 이동
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileFeedScreen(
                  posts: posts, // 전체 리스트 공유
                  initialIndex: postIndex, // 클릭한 사진 위치
                  username: widget.user.username,
                ),
              ),
            );
            // ⭐️ 돌아왔을 때 좋아요/댓글 변경사항 반영을 위해 화면 갱신
            if (mounted) setState(() {});
          },
          child: _buildGridImage(imagePath),
        );
      },
    );
  }

  Widget _buildGridImage(String imagePath) {
    if (imagePath.isEmpty) return Container(color: Colors.grey);
    if (imagePath.startsWith('assets/')) {
      return Image.asset(imagePath, fit: BoxFit.cover);
    }
    return Image.file(File(imagePath), fit: BoxFit.cover);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: backgroundColor, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
