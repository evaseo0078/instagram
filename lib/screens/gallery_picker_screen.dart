import 'dart:io';
import 'package:flutter/material.dart';
// ⭐️ 1. 방금 설치한 패키지 import (필수!)
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

  void _onNextPressed() {
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
        title: const Text('Recents'),
        actions: [
          TextButton(
            onPressed: _onNextPressed,
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
                      // ⭐️ 2. AssetEntityImage 위젯 (이제 정상 작동)
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
