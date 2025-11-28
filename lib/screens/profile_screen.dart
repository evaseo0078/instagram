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

  // ⭐️ 사진 업로드 시작 프로세스
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

    // ⭐️ 요청사항 반영: 이름과 아이디 강제 변경 (화면 표시용)
    // 실제 데이터가 변경되려면 mock_data.dart를 수정해야 하지만,
    // 일단 화면상에서 요구사항대로 보이도록 처리합니다.
    final String displayUsername =
        widget.isMyProfile ? "ph.brown" : widget.user.username;
    final String displayName = widget.isMyProfile ? "Agasa" : widget.user.name;
    final String displayBio = widget.isMyProfile
        ? "I'm gonna be the God of Flutter!"
        : widget.user.bio;

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
        // ⭐️ AppBar 타이틀: 아이디 + 아래 화살표
        title: Row(
          mainAxisSize: MainAxisSize.min, // 텍스트 길이만큼만 차지하게
          children: [
            // ⭐️ 자물쇠 아이콘이 필요한 경우 여기에 추가 (사진엔 없어서 제외)
            Text(
              displayUsername,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22, // 글씨 크기 약간 키움
                  color: primaryColor),
            ),
            if (widget.isMyProfile) ...[
              const SizedBox(width: 4),
              // ⭐️ 아래 화살표 추가 (약간 작게)
              const Icon(Icons.keyboard_arrow_down,
                  size: 18, color: primaryColor),
              // ⭐️ 붉은 점(알림)이 필요하다면 여기에 Positioned Stack 추가 가능
            ]
          ],
        ),
        centerTitle: false, // 왼쪽 정렬
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        // ⭐️ 프로필 상단 정보 (사진 + 스탯)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // ⭐️ 아바타 + 말풍선 Stack
                            Stack(
                              clipBehavior: Clip.none, // 말풍선이 밖으로 나가도 잘리지 않게
                              children: [
                                // 1. 아바타
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 12), // 말풍선 공간 확보
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      CircleAvatar(
                                        radius: 42, // 크기 살짝 키움
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
                                      // ⭐️ 아바타 우측 하단 (+) 버튼
                                      if (widget.isMyProfile)
                                        Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: backgroundColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.add_circle,
                                            color: Colors.black, // 검정색 (+)
                                            size: 24,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // ⭐️ 2. 말풍선 ("Share a note") - 위치 조정
                                if (widget.isMyProfile)
                                  Positioned(
                                    top: -10, // 아바타보다 더 위로
                                    left: -10, // 약간 왼쪽으로
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start, // 꼬리 왼쪽 정렬
                                      children: [
                                        // 말풍선 본체
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
                                        // 말풍선 꼬리 (삼각형)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 30.0),
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

                            // 스탯 (게시물, 팔로워, 팔로잉)
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
                        // ⭐️ 이름 (Agasa)
                        Text(displayName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        // ⭐️ 소개글 (God of Flutter)
                        Text(displayBio),
                        const SizedBox(height: 16),

                        // ⭐️ 버튼들 (Edit profile, Share profile)
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
                            // ⭐️ 사람 추가 아이콘 버튼 (작은 네모)
                            Container(
                              height: 32, // 다른 버튼 높이와 맞춤
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

              // ⭐️ 탭바 섹션 (Sticky)
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    // ⭐️ 중요: 탭바 밑줄이 꽉 차게 나오도록 설정
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: primaryColor, // 검정색
                    indicatorWeight: 1.5, // 두께
                    labelColor: primaryColor,
                    unselectedLabelColor: Colors.grey, // 선택 안된건 회색
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on)), // 그리드 아이콘
                      Tab(icon: Icon(Icons.person_pin_outlined)), // 태그 아이콘
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

  // ⭐️ 공통 버튼 스타일 빌더
  Widget _buildProfileButton({
    required String text,
    required bool isBlue,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 32, // 버튼 높이 고정
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isBlue ? Colors.blue : Colors.grey[200],
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero, // 내부 패딩 제거
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

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
      ],
    );
  }

  Widget _buildPostGrid(List<PostModel> posts) {
    // ⭐️ 내 프로필이면 1개(플러스버튼) + 게시글 2개(mock_data 기준)
    // mock_data.dart의 brown 계정 게시글 개수를 확인해야 함.
    // 사진상으로는 게시글 2개 + 플러스 버튼이 보임.
    final int itemCount = widget.isMyProfile ? posts.length + 1 : posts.length;

    return GridView.builder(
      padding: EdgeInsets.zero, // 패딩 제거해서 딱 붙게
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // ⭐️ 마지막 아이템(혹은 원하는 위치)을 '+' 버튼으로 배치
        // 사진상 순서는: [사진1] [사진2] [+] (빈공간)
        // 하지만 인스타는 최신순이므로 [사진New] ... 그리고 보통 '+'는 별도 영역이거나 맨 앞일 수 있음.
        // 여기서는 "사진과 똑같이" 구현하기 위해 맨 뒤나 맨 앞에 배치를 조정해야 함.
        // 일반적인 인스타 로직 대신 사진의 배치를 따르자면:
        // 현재 코드 로직: index 0을 [+]로 만듦. -> [+][사진1][사진2] 순서가 됨.
        // 사진상: [사진1][사진2][+] 순서임.

        if (widget.isMyProfile) {
          // 게시물이 2개라고 가정하면:
          // index 0 -> post 0
          // index 1 -> post 1
          // index 2 -> Plus button
          if (index == posts.length) {
            return GestureDetector(
              onTap: _startUploadProcess,
              child: Container(
                color: Colors.grey[50], // 아주 연한 회색
                child: const Icon(Icons.add, size: 36, color: Colors.black54),
              ),
            );
          }
          // 게시물 렌더링
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

        // 남의 프로필일 때
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

// ⭐️ 말풍선 꼬리 그리기 (삼각형)
class NoteTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 그림자 효과 (선택사항)
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path();
    // 역삼각형 모양
    path.moveTo(0, 0); // 왼쪽 위
    path.lineTo(size.width, 0); // 오른쪽 위
    path.lineTo(size.width / 2, size.height); // 중간 아래
    path.close();

    canvas.drawPath(path, shadowPaint); // 그림자 먼저
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ⭐️ 탭바 배경 및 고정 처리
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
      color: backgroundColor, // 배경 흰색
      child: Column(
        children: [
          // ⭐️ 탭바 위쪽 구분선 (사진처럼 보이게)
          // Divider(height: 1, color: Colors.grey[300]),
          Expanded(child: _tabBar),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
