// 📍 lib/screens/gallery_picker_screen.dart (영상 UI 수정본)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:instagram/utils/colors.dart';

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => _GalleryPickerScreenState();
}

class _GalleryPickerScreenState extends State<GalleryPickerScreen> {
  List<AssetEntity> _images = [];
  AssetEntity? _selectedImage;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      print("Photo permission denied");
      return;
    }

    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
    );

    if (albums.isEmpty) return;

    final List<AssetEntity> photos = await albums[0].getAssetListRange(
      start: 0,
      end: 80,
    );

    if (photos.isNotEmpty) {
      _selectedImage = photos[0];
      _selectedImageFile = await _selectedImage!.file;
    }

    setState(() {
      _images = photos;
    });
  }

  // ⭐️ 1. "Next" -> "Done" (영상 3:40)
  void _onDonePressed() {
    if (_selectedImageFile != null) {
      Navigator.of(context).pop(_selectedImageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // ⭐️ 2. "Recents" 텍스트를 드롭다운 모양으로 변경
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text('Recents', style: TextStyle(fontWeight: FontWeight.bold)),
            Icon(Icons.arrow_drop_down),
          ],
        ),
        centerTitle: false, // ⭐️ 3. 타이틀 왼쪽 정렬
        actions: [
          // ⭐️ 4. "Next" -> "Done" 버튼으로 변경
          TextButton(
            onPressed: _onDonePressed,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 350,
            color: Colors.grey[900],
            child: _selectedImageFile == null
                ? const Center(child: CircularProgressIndicator())
                : Image.file(_selectedImageFile!, fit: BoxFit.contain),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final asset = _images[index];

                return GestureDetector(
                  onTap: () async {
                    _selectedImageFile = await asset.file;
                    setState(() {
                      _selectedImage = asset;
                    });
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AssetEntityImage(
                        asset,
                        isOriginal: false,
                        fit: BoxFit.cover,
                      ),
                      if (_selectedImage != asset)
                        Container(color: Colors.white.withOpacity(0.5)),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
