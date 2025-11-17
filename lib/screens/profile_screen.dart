// 📍 lib/screens/profile_screen.dart (전체 코드)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/screens/edit_profile_screen.dart'; // ⭐️ Import

class ProfileScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  final void Function() onAddPostPressed;

  const ProfileScreen({
    super.key,
    required this.allPosts,
    required this.onAddPostPressed,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'ta_junhyuk';
  String _bio = "I'm gonna be the God of Flutter!";
  File? _profilePic;

  // "Edit profile" 화면으로 이동하는 함수
  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: _name,
          currentBio: _bio,
          currentProfilePic: _profilePic,
        ),
      ),
    );

    // "Done" 버튼으로 돌아왔을 때 값 업데이트
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _name = result['name']!;
        _bio = result['bio']!;
        _profilePic = result['image'];
      });
    }
  }

  // (Helper 함수들)
  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: secondaryColor),
        ),
      ],
    );
  }

  Widget _buildPostGrid(List<Map<String, dynamic>> myPosts) {
    if (myPosts.isEmpty) {
      return const Center(child: Text("No posts yet"));
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
      ),
      itemCount: myPosts.length + 1,
      itemBuilder: (context, index) {
        if (index == myPosts.length) {
          return GestureDetector(
            onTap: widget.onAddPostPressed,
            child: Container(
              color: Colors.grey[200],
              child: const Icon(
                Icons.add,
                size: 40,
                color: Colors.grey,
              ),
            ),
          );
        }
        final postData = myPosts[index];
        final imagePath = postData['imagePath'];
        if (imagePath is File) {
          return Image.file(imagePath, fit: BoxFit.cover);
        } else if (imagePath is String) {
          return Image.asset(imagePath, fit: BoxFit.cover);
        } else {
          return Container(color: Colors.grey[300]);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> myPosts = widget.allPosts
        .where((post) => post['username'] == 'ta_junhyuk')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _name, // ⭐️ 변수 사용
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: widget.onAddPostPressed,
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
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
                                backgroundImage: _profilePic != null
                                    ? FileImage(_profilePic!) // ⭐️ 변수 사용
                                    : null,
                                child: _profilePic == null
                                    ? const Icon(Icons.person,
                                        size: 40, color: Colors.white)
                                    : null,
                              ),
                              _buildStatColumn(
                                  myPosts.length.toString(), 'Posts'),
                              _buildStatColumn('0', 'Followers'),
                              _buildStatColumn('0', 'Following'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _name, // ⭐️ 변수 사용
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _bio, // ⭐️ 변수 사용
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _navigateToEditProfile, // ⭐️ 함수 연결
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey[400]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Edit profile',
                                style: TextStyle(color: primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
}

// (SliverAppBarDelegate Helper 클래스는 동일)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
