import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/data/dummy_data.dart'; // 음악 데이터
import 'package:instagram/data/mock_data.dart'; // 유저 데이터
import 'package:instagram/widgets/triangle_painter.dart'; // 말풍선 꼬리

class EditFilterScreen extends StatefulWidget {
  final File imageFile;
  const EditFilterScreen({super.key, required this.imageFile});
  @override
  State<EditFilterScreen> createState() => _EditFilterScreenState();
}

class _EditFilterScreenState extends State<EditFilterScreen>
    with TickerProviderStateMixin {
  late AnimationController _audioTooltipController;
  late Animation<double> _audioTooltipScale;
  late AnimationController _filterTooltipController;
  late Animation<double> _filterTooltipScale;

  @override
  void initState() {
    super.initState();
    // 애니메이션 컨트롤러 초기화
    _audioTooltipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _audioTooltipScale = CurvedAnimation(
        parent: _audioTooltipController, curve: Curves.elasticOut);

    _filterTooltipController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _filterTooltipScale = CurvedAnimation(
        parent: _filterTooltipController, curve: Curves.elasticOut);

    // 0.5초 뒤 오디오 툴팁 등장
    Timer(const Duration(milliseconds: 500), () {
      if (mounted) _audioTooltipController.forward();
    });
    // 2초 뒤 필터 툴팁 등장
    Timer(const Duration(seconds: 2), () {
      if (mounted) _filterTooltipController.forward();
    });
  }

  @override
  void dispose() {
    _audioTooltipController.dispose();
    _filterTooltipController.dispose();
    super.dispose();
  }

  // Facebook 공유 안내 시트
  void _showFacebookShareSheet() {
    final myUser = MOCK_USERS['brown']!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 0, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 32),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text("Always share posts to Facebook?",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildInfoItem(
                        icon: Icons.facebook,
                        text:
                            "Let your friends see your posts, no matter which app they're on."),
                    const SizedBox(height: 20),
                    _buildInfoItem(
                        icon: Icons.lock_outline,
                        text:
                            "You will share as ${myUser.name}. Your audience for posts on Facebook is Only\nme."),
                    const SizedBox(height: 20),
                    _buildInfoItem(
                        icon: Icons.settings_outlined,
                        text:
                            "You can change your sharing settings in Accounts Center and each time\nyou share."),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1, thickness: 0.5, color: Colors.grey),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _continueToAddPost();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4))),
                    child: const Text("Share posts",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _continueToAddPost();
                },
                child: const Center(
                    child: Text("Not now",
                        style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 14))),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28, color: Colors.black),
        const SizedBox(width: 16),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: Colors.black87, height: 1.4))),
      ],
    );
  }

  // ⭐️ [Next 버튼] - Processing -> Sharing Posts -> 캡션 작성 -> Facebook 캡션 확인
  Future<void> _onNextPressed() async {
    // 1. Processing 로딩
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: 160,
          height: 70,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.grey)),
                SizedBox(width: 16),
                Text("Processing...",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context);
    if (!mounted) return;

    // 2. Sharing Posts 안내
    final bool? sharingOk = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sharing Posts'),
        content: const Text(
            'You can review your caption before sharing this post.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('OK'))
        ],
      ),
    );
    if (sharingOk != true) return;

    // 3. 캡션 작성 화면
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (context) => AddPostScreen(imageFile: widget.imageFile)),
    );

    // 4. Facebook 캡션/공유 확인
    if (result != null && mounted) {
      final bool? shareFacebook = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Facebook'),
          content:
              const Text('Share this post to Facebook as well before posting.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Share Posts')),
          ],
        ),
      );

      if (shareFacebook == true && mounted) {
        Navigator.of(context).pop<String>(result);
      }
    }
  }

  // 기존 Facebook 시트 흐름에서 호출될 수 있는 헬퍼 (시트 닫고 동일 플로우 재사용)
  void _continueToAddPost() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    _onNextPressed();
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? mainImageProvider;
    if (widget.imageFile.path.isNotEmpty) {
      mainImageProvider = FileImage(widget.imageFile);
    } else {
      mainImageProvider = const AssetImage('assets/images/profiles/kid_go.png');
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
              icon:
                  const Icon(Icons.auto_fix_high_outlined, color: primaryColor),
              onPressed: () {}),
          IconButton(
              icon: const Icon(CupertinoIcons.color_filter,
                  color: primaryColor, size: 26),
              onPressed: () {}),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SvgPicture.asset('assets/icons/Arrow.svg',
                width: 24,
                height: 24,
                colorFilter:
                    ColorFilter.mode(Colors.grey.shade600, BlendMode.srcIn)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0, left: 8.0),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6.0),
                  child: Text("Aa",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Positioned(
                  top: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text("New",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(color: Colors.white),
                    if (mainImageProvider != null)
                      Positioned.fill(
                        child: Image(
                            image: mainImageProvider, fit: BoxFit.contain),
                      ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.6),
                        radius: 18,
                        child: SvgPicture.asset('assets/icons/Arrow.svg',
                            width: 18,
                            height: 18,
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn)),
                      ),
                    ),
                  ],
                ),
              ),
              // 하단 컨트롤 영역
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 오디오 툴팁
                  Transform.translate(
                    offset: const Offset(10, -10),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100),
                      child: ScaleTransition(
                        scale: _audioTooltipScale,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2))
                                ],
                              ),
                              child: const Text("Add audio to your post",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                            ),
                            CustomPaint(
                                size: const Size(12, 8),
                                painter: TrianglePainter(
                                    isDown: true, color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 음악 리스트 (Dummy Data 사용)
                  Container(
                    height: 170,
                    color: backgroundColor,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildBottomItem(
                            isIcon: true, title: "Browse", imagePath: null),
                        ...DUMMY_CONTENT.map((item) => _buildBottomItem(
                              isIcon: false,
                              title: item['title']!,
                              artist: item['artist'],
                              imagePath: item['image']!,
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30)),
                          child: const Text("Edit",
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                        // ⭐️ Next 버튼
                        GestureDetector(
                          onTap: _onNextPressed,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              children: const [
                                Text("Next",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward,
                                    color: Colors.white, size: 16)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 필터 툴팁
          Positioned(
            top: -10,
            right: 25,
            child: ScaleTransition(
              scale: _filterTooltipScale,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomPaint(
                      size: const Size(12, 8),
                      painter:
                          TrianglePainter(isDown: false, color: Colors.white)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: const Text("Add a filter to your post",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomItem(
      {required bool isIcon,
      required String title,
      String? artist,
      required String? imagePath}) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!, width: 1),
              image: (!isIcon && imagePath != null)
                  ? DecorationImage(
                      image: AssetImage(imagePath), fit: BoxFit.cover)
                  : null,
            ),
            child: isIcon
                ? const Center(
                    child: Icon(Icons.library_music,
                        color: Colors.black, size: 32))
                : null,
          ),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          if (artist != null)
            Text(artist,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
        ],
      ),
    );
  }
}
