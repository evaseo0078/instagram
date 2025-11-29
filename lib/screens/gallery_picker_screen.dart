// 📍 lib/screens/gallery_picker_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:instagram/utils/colors.dart';

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  List<AssetEntity> _mediaList = [];
  AssetEntity? _selectedAsset;
  File? _selectedImageFile;
  bool _isLoading = true;
  int _selectedTabIndex = 0; // 0: GALLERY, 1: PHOTO, 2: VIDEO

  @override
  void initState() {
    super.initState();
    _loadGalleryImages();
  }

  // 갤러리 이미지 불러오기
  Future<void> _loadGalleryImages() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      if (mounted) Navigator.pop(context);
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      onlyAll: true,
    );

    if (albums.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    final List<AssetEntity> media = await albums[0].getAssetListPaged(
      page: 0,
      size: 100,
    );

    setState(() {
      _mediaList = media;
      if (media.isNotEmpty) {
        _selectedAsset = media[0];
        _convertAssetToFile(media[0]);
      }
      _isLoading = false;
    });
  }

  // AssetEntity를 File로 변환
  Future<void> _convertAssetToFile(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null && mounted) {
      setState(() {
        _selectedImageFile = file;
      });
    }
  }

  void _onDoneOrNextPressed() async {
    if (_selectedImageFile != null) {
      Navigator.of(context).pop(_selectedImageFile);
    }
  }

  void _onImageTapped(AssetEntity asset) {
    setState(() {
      _selectedAsset = asset;
    });
    _convertAssetToFile(asset);
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.black : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final gridHeight = 200.0; // 하단 그리드 높이

    // 이미지 미리보기 높이
    final imagePreviewHeight =
        (screenHeight - appBarHeight - statusBarHeight - gridHeight) * 0.7;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Recents'),
            Icon(Icons.expand_more),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _onDoneOrNextPressed,
            child: const Text(
              'Next',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 선택된 이미지 큰 미리보기
                Stack(
                  children: [
                    Container(
                      height: imagePreviewHeight,
                      width: double.infinity,
                      color: Colors.white,
                      child: _selectedImageFile != null
                          ? Image.file(
                              _selectedImageFile!,
                              fit: BoxFit.contain,
                            )
                          : const Center(child: Text('No image selected')),
                    ),
                    // 좌측 하단 Picture 아이콘
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // 우측 하단 SELECT MULTIPLE
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.library_add_check,
                                color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'SELECT MULTIPLE',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // 하단 갤러리 가로 스크롤
                Container(
                  height: gridHeight - 60,
                  color: backgroundColor,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    itemCount: _mediaList.length,
                    itemBuilder: (context, index) {
                      final asset = _mediaList[index];
                      final isSelected = _selectedAsset?.id == asset.id;

                      return GestureDetector(
                        onTap: () => _onImageTapped(asset),
                        child: Container(
                          width: 110,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
                          ),
                          child: AssetEntityImage(
                            asset,
                            isOriginal: false,
                            thumbnailSize: const ThumbnailSize.square(200),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // 탭 바 (GALLERY / PHOTO / VIDEO) - 맨 밑
                Container(
                  color: backgroundColor,
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildTab('GALLERY', 0),
                      ),
                      Expanded(
                        child: _buildTab('PHOTO', 1),
                      ),
                      Expanded(
                        child: _buildTab('VIDEO', 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
