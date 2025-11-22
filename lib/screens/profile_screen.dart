import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/models/post_model.dart'; // ⭐️ PostModel import 필수
import 'package:instagram/models/user_model.dart';
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/screens/following_list_screen.dart';
import 'package:instagram/utils/colors.dart';

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
  Future<void> _navigateToEditProfile() async {
    if (!widget.isMyProfile) return;

    // ⭐️ 1. 현재 프로필 사진이 File 경로인지 확인하여 File 객체 또는 null 전달
    File? currentProfilePicFile;
    if (!widget.user.profilePicAsset.startsWith('assets/')) {
      // Asset 경로가 아니면 File 경로로 간주
      currentProfilePicFile = File(widget.user.profilePicAsset);
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: widget.user.name,
          currentBio: widget.user.bio,
          currentProfilePic: currentProfilePicFile, // ⭐️ File 객체 전달
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        widget.user.name = result['name'];
        widget.user.bio = result['bio'];

        // ⭐️ 2. 프로필 이미지 경로 업데이트
        final newImageFile = result['image'] as File?;
        if (newImageFile != null) {
          widget.user.profilePicAsset =
              newImageFile.path; // File 경로 (String) 저장
        } else if (result.containsKey('image')) {
          // 사진이 null로 돌아온 경우 (삭제됨)
          widget.user.profilePicAsset = 'assets/images/profiles/my_profile.png';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myPosts = widget.user.posts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.username,
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        actions: [
          if (widget.isMyProfile) ...[
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () {},
            ),
            IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
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
                                  : FileImage(File(widget.user.profilePicAsset))
                                      as ImageProvider,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FollowingListScreen(
                                      followingUsernames:
                                          widget.user.followingUsernames,
                                    ),
                                  ),
                                );
                              },
                              child: _buildStatColumn(
                                  widget.user.followingUsernames.length
                                      .toString(),
                                  'Following'),
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
                              : ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Text('Follow',
                                      style: TextStyle(color: Colors.white)),
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
              _buildReelsGrid(myPosts), // 릴스는 없는 경우 빈 화면 처리됨
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

  // ⭐️ 수정됨: List<dynamic> -> List<PostModel>
  Widget _buildPostGrid(List<PostModel> posts) {
    if (posts.isEmpty) return const Center(child: Text("No posts yet"));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        // ⭐️ 수정됨: post.images[0] (리스트의 첫 번째 사진) 사용
        return _buildGridImage(post.images.isNotEmpty ? post.images[0] : '');
      },
    );
  }

  // ⭐️ 릴스 그리드 (구색만 갖춤)
  Widget _buildReelsGrid(List<PostModel> posts) {
    // 실제로는 videoUrl이 있는 것만 필터링해야 하지만, 일단 비워둡니다.
    return const Center(child: Text("No Reels yet"));
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
