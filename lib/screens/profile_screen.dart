import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';

class ProfileScreen extends StatelessWidget {
  final List<Map<String, dynamic>> allPosts;
  final void Function() onAddPostPressed; // AppBar의 '+' 버튼용 함수

  const ProfileScreen({
    super.key,
    required this.allPosts,
    required this.onAddPostPressed,
  });

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

  // ⭐️ 1. 게시물 격자(Grid)를 만드는 위젯 (수정됨)
  Widget _buildPostGrid(List<Map<String, dynamic>> myPosts) {
    // ⭐️ 2. (영상 03:48) "No posts yet" 문구 (기존 로직)
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
      // ⭐️ 3. itemCount: 게시물 갯수 + 1 (마지막 '+' 버튼)
      itemCount: myPosts.length + 1,
      itemBuilder: (context, index) {
        // ⭐️ 4. (영상 02:25) 마지막 index일 경우 '+' 버튼 반환
        if (index == myPosts.length) {
          return GestureDetector(
            onTap: onAddPostPressed, // ⭐️ 5. AppBar와 동일한 포스팅 함수 연결
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

        // ⭐️ 6. 마지막이 아니면, 기존 썸네일 표시
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
    // ⭐️ 7. "중앙 리스트"에서 "내 게시물"만 필터링
    final List<Map<String, dynamic>> myPosts =
        allPosts.where((post) => post['username'] == 'ta_junhyuk').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ta_junhyuk',
          style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
        ),
        actions: [
          // ⭐️ 8. AppBar의 '+' 버튼 (이것도 그대로 둠)
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: onAddPostPressed,
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
              // ⭐️ 9. 프로필 정보 헤더 (기존과 동일)
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
                          const Text(
                            'ta_junhyuk',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "I'm gonna be the God of Flutter!",
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {},
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
              // ⭐️ 10. 탭바 (기존과 동일)
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
          // ⭐️ 11. 탭바 내용 (수정된 _buildPostGrid 사용)
          body: TabBarView(
            children: [
              _buildPostGrid(myPosts), // ⭐️ (수정된 함수)
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
