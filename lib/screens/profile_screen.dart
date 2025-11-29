import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/models/feed_item.dart';
import 'package:instagram/screens/edit_filter_screen.dart';
import 'package:instagram/screens/gallery_picker_screen.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/data/mock_data.dart';
import 'package:instagram/screens/profile_feed_screen.dart';
import 'package:instagram/widgets/triangle_painter.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;
  final bool isMyProfile;
  final void Function(String imagePath, String caption)? onUploadComplete;

  const ProfileScreen({
    super.key,
    required this.user,
    this.isMyProfile = false,
    this.onUploadComplete,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isFollowing = false;
  File? _pendingImageFile;
  String? _pendingCaption;

  @override
  void initState() {
    super.initState();
    final myUser = MOCK_USERS['brown']!;
    _isFollowing = myUser.followingUsernames.contains(widget.user.username);
  }

  // ⭐️ Pause 시트
  Future<bool?> _showPauseMessageSheet() {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.5),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text("Pause these messages?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "You'll stop seeing messages about sharing to Facebook for 90 days. You\ncan turn on crossposting when you share a story, post or reel.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, color: Colors.grey),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: null, // 비활성화
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6))),
                  child: const Text("Pause",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Colors.grey),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context, true); // 시트 닫고 true 반환
                },
                child: const Text("No thanks",
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15)),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
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

  // Create 옵션 시트 (기존 유지)
  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                  child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)))),
              const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text('Create',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16))),
              const Divider(height: 1),
              _buildCreateOptionItem(
                  iconPath: 'assets/icons/Reel.svg',
                  text: 'Reel',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  showDivider: true),
              _buildCreateOptionItem(
                  iconPath: 'assets/icons/Post.svg',
                  text: 'Post',
                  onTap: () {
                    Navigator.pop(context);
                    _onCreatePostTapped();
                  },
                  showDivider: true),
              _buildCreateOptionItem(
                  iconPath: 'assets/icons/Share_only_to_profile.svg',
                  text: 'Share only to profile',
                  isNew: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                  showDivider: true),
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onCreatePostTapped() async {
    print('🟢🟢🟢 ProfileScreen _onCreatePostTapped called');

    // 1. 갤러리에서 이미지 선택
    final File? selectedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GalleryPickerScreen()),
    );

    if (selectedImage != null && mounted) {
      print('🟢🟢🟢 Image selected, going to EditFilterScreen');

      // 2. EditFilterScreen으로 이동 (필터/오디오 선택)
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditFilterScreen(imageFile: selectedImage),
        ),
      );

      // 3. EditFilterScreen에서 결과 받음 (caption)
      if (result != null && mounted) {
        final caption = result as String;
        print('🟢🟢🟢 Received caption: $caption');

        // 이미지와 캡션을 저장하고 Pause 시트 표시 (아직 업로드 안 함)
        _pendingImageFile = selectedImage;
        _pendingCaption = caption;

        print('🟢🟢🟢 Data stored, showing Pause sheet (not uploaded yet)');

        final bool? shouldUpload = await _showPauseMessageSheet();

        if (!mounted) return;

        if (shouldUpload == true &&
            _pendingImageFile != null &&
            _pendingCaption != null) {
          final imagePath = _pendingImageFile!.path;
          final captionToReturn = _pendingCaption!;

          // 데이터 초기화 후 메인으로 전달
          _pendingImageFile = null;
          _pendingCaption = null;

          if (widget.onUploadComplete != null) {
            widget.onUploadComplete!(imagePath, captionToReturn);
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          } else {
            Navigator.pop(context, {
              'imagePath': imagePath,
              'caption': captionToReturn,
            });
          }
        } else {
          // 업로드 취소 시 데이터 정리
          _pendingImageFile = null;
          _pendingCaption = null;
        }
      }
    }
  }

  Widget _buildCreateOptionItem(
      {required String iconPath,
      required String text,
      required VoidCallback onTap,
      bool isNew = false,
      bool showDivider = false}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                SvgPicture.asset(iconPath,
                    width: 24,
                    height: 24,
                    colorFilter:
                        const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                const SizedBox(width: 16),
                Text(text, style: const TextStyle(fontSize: 16)),
                if (isNew) ...[
                  const Spacer(),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(4)),
                      child: const Text('New',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)))
                ]
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
              height: 1,
              thickness: 0.5,
              indent: 56,
              endIndent: 16,
              color: Colors.grey),
      ],
    );
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
                currentProfilePic: currentProfilePicFile)));
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
                onPressed: () => Navigator.of(context).pop()),
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(displayUsername,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: primaryColor)),
          if (widget.isMyProfile) ...[
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: primaryColor)
          ]
        ]),
        centerTitle: false,
        actions: [
          if (widget.isMyProfile) ...[
            IconButton(
                icon: const Icon(Icons.add_box_outlined, color: primaryColor),
                onPressed: _showCreateOptions),
            IconButton(
                icon: const Icon(Icons.menu, color: primaryColor),
                onPressed: () {})
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
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
                                                  ? AssetImage(widget
                                                          .user.profilePicAsset)
                                                      as ImageProvider
                                                  : FileImage(File(widget
                                                      .user.profilePicAsset))),
                                          if (widget.isMyProfile)
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(2),
                                                decoration: const BoxDecoration(
                                                    color: backgroundColor,
                                                    shape: BoxShape.circle),
                                                child: const Icon(
                                                    Icons.add_circle,
                                                    color: Colors.black,
                                                    size: 24))
                                        ])),
                                if (widget.isMyProfile)
                                  Positioned(
                                      top: -10,
                                      left: -10,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.1),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                              0, 2))
                                                    ]),
                                                child: const Text(
                                                    "Share a\nnote",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        height: 1.1))),
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12.0),
                                                child: CustomPaint(
                                                    size: const Size(10, 8),
                                                    painter:
                                                        NoteTrianglePainter()))
                                          ])),
                              ],
                            ),
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
                                          'following'))
                                ])),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(displayName,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(displayBio),
                        const SizedBox(height: 16),
                        Row(children: [
                          Expanded(
                              child: _buildProfileButton(
                                  text: widget.isMyProfile
                                      ? 'Edit profile'
                                      : (_isFollowing ? 'Following' : 'Follow'),
                                  isBlue: !widget.isMyProfile && !_isFollowing,
                                  onTap: widget.isMyProfile
                                      ? _navigateToEditProfile
                                      : _toggleFollow)),
                          const SizedBox(width: 6),
                          Expanded(
                              child: _buildProfileButton(
                                  text: 'Share profile',
                                  isBlue: false,
                                  onTap: () {})),
                          const SizedBox(width: 6),
                          Container(
                              height: 32,
                              width: 34,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.person_add_outlined,
                                  size: 18, color: Colors.black))
                        ]),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ]),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: primaryColor,
                      indicatorWeight: 1.5,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.grey,
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on)),
                        Tab(icon: Icon(Icons.person_pin_outlined))
                      ]))),
            ];
          },
          body: TabBarView(children: [
            _buildPostGrid(myPosts),
            const Center(
                child: Text("Photos and videos of you",
                    style: TextStyle(fontWeight: FontWeight.bold)))
          ]),
        ),
      ),
    );
  }

  Widget _buildProfileButton(
      {required String text,
      required bool isBlue,
      required VoidCallback onTap}) {
    return SizedBox(
        height: 32,
        child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
                backgroundColor: isBlue ? Colors.blue : Colors.grey[200],
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero),
            child: Text(text,
                style: TextStyle(
                    color: isBlue ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13))));
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(count,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.black))
        ]);
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
            childAspectRatio: 0.75),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (widget.isMyProfile) {
            if (index == posts.length) {
              return GestureDetector(
                  onTap: _showCreateOptions,
                  child: Container(
                      color: Colors.grey[50],
                      child: const Icon(Icons.add,
                          size: 36, color: Colors.black54)));
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
                              username: widget.user.username)));
                  if (mounted) setState(() {});
                },
                child: _buildGridImage(imagePath));
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
                            username: widget.user.username)));
                if (mounted) setState(() {});
              },
              child: _buildGridImage(imagePath));
        });
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
        child: Column(children: [Expanded(child: _tabBar)]));
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
