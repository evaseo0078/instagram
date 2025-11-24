// 📍 lib/screens/profile_screen.dart (전체 덮어쓰기)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart';
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/data/mock_data.dart'; // ⭐️ 데이터 접근

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
    // 팔로우 상태 확인
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
    // ⭐️ 타입 명시 (List<PostModel>)
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
                onPressed: () {}),
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
                        // 프로필 사진 및 팔로잉 정보
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: widget.user.profilePicAsset
                                      .startsWith('assets/')
                                  ? AssetImage(widget.user.profilePicAsset)
                                      as ImageProvider
                                  : FileImage(
                                      File(widget.user.profilePicAsset)),
                            ),
                            // 팔로워/팔로잉 스탯 (간략화)
                            Row(
                              children: [
                                _buildStatColumn('${myPosts.length}', 'Posts'),
                                const SizedBox(width: 20),
                                _buildStatColumn('${widget.user.followerCount}',
                                    'Followers'),
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
                                        'Following')),
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

                        // ⭐️ 팔로우 / 편집 버튼
                        SizedBox(
                          width: double.infinity,
                          child: widget.isMyProfile
                              ? OutlinedButton(
                                  onPressed: _navigateToEditProfile,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey[400]!),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Edit profile',
                                      style: TextStyle(color: primaryColor)),
                                )
                              : _isFollowing
                                  ? OutlinedButton(
                                      onPressed: _toggleFollow,
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: Colors.grey[200],
                                        side: BorderSide.none,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Following',
                                          style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold)),
                                    )
                                  : ElevatedButton(
                                      onPressed: _toggleFollow,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Follow',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                    ),
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
                      Tab(icon: Icon(Icons.movie_creation_outlined)),
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
              const Center(child: Text("No Reels yet")),
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
    if (posts.isEmpty) return const Center(child: Text("No posts yet"));
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final imagePath = post.images.isNotEmpty ? post.images[0] : '';

        if (imagePath.isEmpty) return Container(color: Colors.grey);
        if (imagePath.startsWith('assets/')) {
          return Image.asset(imagePath, fit: BoxFit.cover);
        }
        return Image.file(File(imagePath), fit: BoxFit.cover);
      },
    );
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
