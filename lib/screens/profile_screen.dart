// 📍 lib/screens/profile_screen.dart

import 'dart:async';
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
    // ⭐️ 데이터 초기화: 내 프로필인 경우 mock_data의 값을 확인
    // (mock_data.dart에서 이미 username='ph.brown', name='Agasa'로 설정되어 있다고 가정)
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

  // ⭐️ 사진 업로드 프로세스
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
            final newPost = PostModel(
              username: widget.user.username,
              userProfilePicAsset: widget.user.profilePicAsset,
              images: [filteredFile.path],
              caption: caption,
              comments: [],
              likes: 0,
              date: DateTime.now(),
            );

            widget.user.posts.insert(0, newPost);
            HOME_FEED_SCENARIO.insert(
                0, FeedItem(type: FeedItemType.post, post: newPost));

            Timer(const Duration(seconds: 30), () {
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

  // ⭐️ 프로필 수정 화면 이동
  Future<void> _navigateToEditProfile() async {
    if (!widget.isMyProfile) return;

    File? currentProfilePicFile;
    if (!widget.user.profilePicAsset.startsWith('assets/')) {
      currentProfilePicFile = File(widget.user.profilePicAsset);
    }

    // EditProfileScreen으로 현재 데이터 전달
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

    // ⭐️ 수정된 데이터 받아와서 업데이트 (연동)
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

    // ⭐️ 1. 하드코딩 제거하고 실제 widget.user 데이터 사용
    // (mock_data에서 ph.brown, Agasa 등으로 설정되어 있어야 함)
    final String displayUsername = widget.user.username;
    final String displayName = widget.user.name;
    final String displayBio = widget.user.bio;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: widget.isMyProfile
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayUsername, // "ph.brown"
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: primaryColor),
            ),
            if (widget.isMyProfile) ...[
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: primaryColor),
            ]
          ],
        ),
        centerTitle: false,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      // ⭐️ 2. 전체 내용을 왼쪽 정렬
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 아바타 + 말풍선 Stack
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // 아바타
                                Container(
                                  margin: const EdgeInsets.only(top: 12),
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 42,
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
                                      if (widget.isMyProfile)
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: backgroundColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add_circle,
                                            color: Colors.black,
                                            size: 24,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // ⭐️ 3. 말풍선 꼬리 위치 조정 (왼쪽으로 이동)
                                if (widget.isMyProfile)
                                  Positioned(
                                    top: -10,
                                    left: -10,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              )
                                            ],
                                          ),
                                          child: const Text(
                                            "Share a\nnote",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                height: 1.1),
                                          ),
                                        ),
                                        // ⭐️ 꼬리 여백을 12.0으로 줄여서 왼쪽으로 이동시킴
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 12.0),
                                          child: CustomPaint(
                                            size: const Size(10, 8),
                                            painter: NoteTrianglePainter(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),

                            // ⭐️ 4. 스탯 (Posts, Followers, Following) - 실제 데이터 연동
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildStatColumn(
                                      '${myPosts.length}', 'posts'),
                                  _buildStatColumn(
                                      '${widget.user.followerCount}',
                                      'followers'),
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
                                        'following'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        // ⭐️ 5. 이름 (Agasa) - 왼쪽 정렬됨
                        Text(displayName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        // 소개글
                        Text(displayBio),
                        const SizedBox(height: 16),

                        // 버튼들
                        Row(
                          children: [
                            Expanded(
                              child: _buildProfileButton(
                                text: widget.isMyProfile
                                    ? 'Edit profile'
                                    : (_isFollowing ? 'Following' : 'Follow'),
                                isBlue: !widget.isMyProfile && !_isFollowing,
                                onTap: widget.isMyProfile
                                    ? _navigateToEditProfile
                                    : _toggleFollow,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildProfileButton(
                                text: 'Share profile',
                                isBlue: false,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              height: 32,
                              width: 34,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.person_add_outlined,
                                  size: 18, color: Colors.black),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ]),
              ),

              // 탭바
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: primaryColor,
                    indicatorWeight: 1.5,
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)),
                      Tab(icon: Icon(Icons.person_pin_outlined)),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildPostGrid(myPosts),
              const Center(
                  child: Text("Photos and videos of you",
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileButton({
    required String text,
    required bool isBlue,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 32,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isBlue ? Colors.blue : Colors.grey[200],
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBlue ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ⭐️ 6. 숫자와 라벨을 왼쪽 정렬 (CrossAxisAlignment.start)
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
      children: [
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
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
        if (widget.isMyProfile) {
          // 사진 업로드 버튼을 마지막에 배치 (혹은 요구사항에 따라 위치 변경 가능)
          // 여기서는 인덱스 0을 'Newest Post'로 취급하므로, 업로드 버튼을 인덱스 마지막에 둠
          if (index == posts.length) {
            return GestureDetector(
              onTap: _startUploadProcess,
              child: Container(
                color: Colors.grey[50],
                child: const Icon(Icons.add, size: 36, color: Colors.black54),
              ),
            );
          }
          final post = posts[index];
          final imagePath = post.images.isNotEmpty ? post.images[0] : '';
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileFeedScreen(
                    posts: posts,
                    initialIndex: index,
                    username: widget.user.username,
                  ),
                ),
              );
              if (mounted) setState(() {});
            },
            child: _buildGridImage(imagePath),
          );
        }

        // 남의 프로필
        final post = posts[index];
        final imagePath = post.images.isNotEmpty ? post.images[0] : '';
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileFeedScreen(
                  posts: posts,
                  initialIndex: index,
                  username: widget.user.username,
                ),
              ),
            );
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

class NoteTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    return Container(
      color: backgroundColor,
      child: Column(
        children: [
          Expanded(child: _tabBar),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
