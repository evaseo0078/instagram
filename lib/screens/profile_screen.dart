import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/data/mock_data.dart'; // 데이터 접근
import 'package:instagram/models/user_model.dart'; // 모델
import 'package:instagram/screens/edit_profile_screen.dart';
import 'package:instagram/utils/colors.dart';

class ProfileScreen extends StatefulWidget {
  // ⭐️ 이제 특정 유저의 정보를 받아서 그 사람의 프로필을 보여줍니다.
  final UserModel user;

  // ⭐️ 메인 탭에서 넘어온 경우인지 확인 (내 프로필인지)
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
  // "Edit profile" 이동
  Future<void> _navigateToEditProfile() async {
    // 내 프로필이 아니면 수정 불가
    if (!widget.isMyProfile) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: widget.user.name,
          currentBio: widget.user.bio,
          // 파일 이미지는 관리 복잡하므로 생략하거나 asset만 사용한다고 가정
          currentProfilePic: null,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        // ⭐️ 데이터 원본(MOCK_USERS)을 직접 수정해야 전역 반영됨
        widget.user.name = result['name'];
        widget.user.bio = result['bio'];
        // 이미지는 로직상 복잡하여 생략 (영상 기능 위주)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ⭐️ 유저의 게시물 가져오기
    final myPosts = widget.user.posts;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user.username, // ⭐️ 유저네임 표시
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        actions: [
          // 내 프로필일 때만 '추가' 버튼 등 표시
          if (widget.isMyProfile) ...[
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () {
                // MainScreen에서 처리하므로 여기선 빈 동작 혹은 콜백 필요
                // (간단하게 스낵바)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Go to "Add" tab to create post')),
                );
              },
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
                        // 프사 및 통계
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
                                  : null, // File 이미지 등은 생략
                              child: !widget.user.profilePicAsset
                                      .startsWith('assets/')
                                  ? const Icon(Icons.person,
                                      size: 40, color: Colors.white)
                                  : null,
                            ),
                            _buildStatColumn(
                                myPosts.length.toString(), 'Posts'),
                            _buildStatColumn(
                                widget.user.followerCount.toString(),
                                'Followers'),
                            _buildStatColumn(
                                widget.user.followingUsernames.length
                                    .toString(),
                                'Following'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(widget.user.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(widget.user.bio),
                        const SizedBox(height: 16),

                        // ⭐️ 버튼 (내 프로필이면 Edit, 남이면 Follow)
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
                                  // 팔로우 버튼 스타일
                                  onPressed: () {
                                    // 팔로우 로직 (생략 - 영상 UI 구현 위주)
                                  },
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
              const Center(child: Text('Tagged posts')),
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

  Widget _buildPostGrid(List<dynamic> posts) {
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
        final post = posts[index]; // PostModel
        return _buildGridImage(post.image);
      },
    );
  }

  Widget _buildGridImage(dynamic image) {
    if (image is File) return Image.file(image, fit: BoxFit.cover);
    if (image is String) {
      if (image.startsWith('http'))
        return Image.network(image, fit: BoxFit.cover);
      return Image.asset(image, fit: BoxFit.cover);
    }
    return Container(color: Colors.grey);
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
