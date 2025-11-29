import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram/screens/add_post_screen.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/data/dummy_data.dart'; // 음악 데이터
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

  // ⭐️ [Next 버튼] 로딩 -> 작성화면 -> 결과 반환
  Future<void> _onNextPressed() async {
    // 1. "Processing..." 로딩 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Container(
          width: 140,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: const [
              SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.grey)),
              SizedBox(width: 20),
              Text("Processing...",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );

    // 2. 0.5초 대기 (연출)
    await Future.delayed(const Duration(milliseconds: 500));

    // 3. 로딩 닫기
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    // 4. AddPostScreen으로 이동 (결과 대기)
    final String? result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
          builder: (context) => AddPostScreen(imageFile: widget.imageFile)),
    );

    print('🔍 EditFilterScreen received result: $result');

    // 5. ⭐️ 결과(caption)가 있으면 Main으로 전달하며 닫기 (빈 문자열도 허용)
    if (result != null && mounted) {
      print('✅ Popping EditFilterScreen with result: "$result"');
      Navigator.of(context).pop<String>(result);
    } else {
      print(
          '❌ Result is null or context not mounted. result: $result, mounted: $mounted');
    }
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
          icon: const Icon(Icons.arrow_back, color: primaryColor),
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
            child: SvgPicture.asset('assets/icons/Picture.svg',
                width: 24,
                height: 24,
                colorFilter:
                    const ColorFilter.mode(primaryColor, BlendMode.srcIn)),
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
                              color: const Color(0xFF424242),
                              borderRadius: BorderRadius.circular(30)),
                          child: const Text("Edit",
                              style: TextStyle(
                                  color: Colors.white,
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
