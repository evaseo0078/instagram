// 📍 lib/screens/profile_screen.dart (업데이트된 최종본)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/screens/edit_profile_screen.dart'; // ⭐️ 1. 새로 만든 파일 import

// ⭐️ 2. StatelessWidget -> StatefulWidget로 변경
class ProfileScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allPosts;
  final void Function() onAddPostPressed;

  const ProfileScreen({
    super.key,
    required this.allPosts,
    required this.onAddPostPressed,
  });

  @override
  // ⭐️ 3. State 객체 생성
  State<ProfileScreen> createState() => _ProfileScreenState();
}

// ⭐️ 4. State 클래스 (모든 로직이 여기로 이동)
class _ProfileScreenState extends State<ProfileScreen> {
  // ⭐️ 5. 닉네임과 바이오를 "기억"할 변수 (초기값 설정)
  String _name = 'ta_junhyuk';
  String _bio = "I'm gonna be the God of Flutter!";

  // ⭐️ 6. EditProfileScreen으로 이동하는 함수 (새로 추가)
  Future<void> _navigateToEditProfile() async {
    // 7. "Edit profile" 화면을 띄우고, "현재" 닉네임/바이오를 전달
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: _name,
          currentBio: _bio,
        ),
      ),
    );

    // 8. "Done"을 눌러 돌아왔다면 (result가 Map 형태일 경우)
    if (result != null && result is Map<String, String>) {
      setState(() {
        _name = result['name']!; // ⭐️ 9. 변수 업데이트 (화면 새로고침)
        _bio = result['bio']!; // ⭐️ 10. 변수 업데이트 (화면 새로고침)
      });
    }
  }

  // ( ... 기존 _buildStatColumn, _buildPostGrid 함수는 동일 ... )
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
            // ⭐️ 부모(widget)로부터 함수 접근
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
    // ⭐️ 부모(widget)로부터 포스트 리스트 접근
    final List<Map<String, dynamic>> myPosts = widget.allPosts
        .where((post) => post['username'] == 'ta_junhyuk')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _name, // ⭐️ 11. 하드코딩된 텍스트 대신 _name 변수 사용
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: widget.onAddPostPressed, // ⭐️ 부모(widget) 함수 사용
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
                              const CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey,
                              ),
                              _buildStatColumn(
                                  myPosts.length.toString(), 'Posts'),
                              _buildStatColumn('0', 'Followers'),
                              _buildStatColumn('0', 'Following'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _name, // ⭐️ 12. 하드코딩된 텍스트 대신 _name 변수 사용
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _bio, // ⭐️ 13. 하드코딩된 텍스트 대신 _bio 변수 사용
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              // ⭐️ 14. _navigateToEditProfile 함수 연결
                              onPressed: _navigateToEditProfile,
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
              // ( ... 탭바는 동일 ... )
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

// ( ... SliverAppBarDelegate Helper 클래스는 동일 ... )
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
