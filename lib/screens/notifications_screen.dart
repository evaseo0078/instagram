// 📍 lib/screens/notifications_screen.dart (신규 파일)

import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';

class NotificationsScreen extends StatelessWidget {
  final bool hasConanComment;
  final bool conanIsNew;
  final String conanTime;
  final String? conanThumbnail;
  final VoidCallback? onConanTap;

  const NotificationsScreen({
    super.key,
    this.hasConanComment = false,
    this.conanIsNew = false,
    this.conanTime = '1m',
    this.conanThumbnail,
    this.onConanTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
      ),
      body: ListView(
        children: [
          // 1. Today 섹션
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Today',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          if (hasConanComment)
            _buildNotificationItem(
              profilePic: 'assets/images/profiles/conan.png',
              text: 'conan commented on your post.',
              time: conanTime,
              trailingType: 'image',
              trailingImage: conanThumbnail ?? 'assets/images/profiles/my_profile.png',
              isNew: conanIsNew,
              onTap: onConanTap,
            ),
          _buildNotificationItem(
            profilePic:
                'assets/images/profiles/ran.png', // haetbaaan (임시: ran 사진)
            text: 'haetbaaan commented: so cute!!',
            time: '6s',
            trailingType: 'image', // 오른쪽에 내 사진
            trailingImage: 'assets/images/profiles/my_profile.png', // 내 게시물 썸네일
          ),

          const Divider(),

          // 2. Last 30 days 섹션
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text('Last 30 days',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          _buildNotificationItem(
            profilePic: 'assets/images/profiles/ran.png',
            text: 'haetbaaan liked your photo.',
            time: '2w',
            trailingType: 'image',
            trailingImage:
                'assets/images/profiles/my_profile.png', // 다른 사진 (임시)
          ),
          _buildNotificationItem(
            profilePic: 'assets/images/profiles/ran.png',
            text: 'haetbaaan started following you.',
            time: '2w',
            trailingType: 'button', // 팔로잉 버튼
            isFollowing: true,
          ),
          _buildNotificationItem(
            profilePic: 'assets/images/profiles/kid_go.png',
            text: 'yonghyeon5670 started following you.',
            time: '2w',
            trailingType: 'button',
            isFollowing: true,
          ),
          _buildNotificationItem(
            profilePic: 'assets/images/profiles/conan.png',
            text: 'junehxuk started following you.',
            time: '2w',
            trailingType: 'button',
            isFollowing: true,
          ),

          const SizedBox(height: 8),
          // 하단 안내 문구
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: secondaryColor),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                      'You have 2 new accounts in your Accounts Center. 2w',
                      style: TextStyle(color: secondaryColor, fontSize: 12)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String profilePic,
    required String text,
    required String time,
    required String trailingType, // 'image' or 'button'
    String? trailingImage,
    bool isFollowing = false,
    bool isNew = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 22,
        backgroundImage: AssetImage(profilePic),
      ),
      title: RichText(
        text: TextSpan(
          style: TextStyle(
              color: isNew ? Colors.blue : primaryColor, fontSize: 14),
          children: [
            TextSpan(
                text: text.split(' ')[0],
                style:
                    const TextStyle(fontWeight: FontWeight.bold)), // 아이디 Bold
            TextSpan(text: text.substring(text.indexOf(' '))), // 나머지 내용
            TextSpan(
                text: ' $time', style: const TextStyle(color: secondaryColor)),
          ],
        ),
      ),
      trailing: trailingType == 'image'
          ? Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(trailingImage!), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(4), // 약간 둥근 사각형
              ),
            )
          : SizedBox(
              width: 90,
              height: 32,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.zero,
                ),
                child: const Text('Following',
                    style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
    );
  }
}
