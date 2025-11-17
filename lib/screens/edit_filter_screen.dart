// 📍 lib/screens/edit_filter_screen.dart (성능 문제 해결 + Processing 팝업)

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:instagram/utils/colors.dart';
// ⭐️ 1. 로딩 유틸리티 import (오류 해결!)
import 'package:instagram/utils/loading_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart';
import 'package:photofilters/filters/filters.dart';

class EditFilterScreen extends StatefulWidget {
  final File imageFile;
  const EditFilterScreen({super.key, required this.imageFile});
  @override
  State<EditFilterScreen> createState() => _EditFilterScreenState();
}

class _EditFilterScreenState extends State<EditFilterScreen> {
  late Uint8List _imageBytes;
  late File _filteredImageFile;
  late List<Filter> _filters;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _filteredImageFile = widget.imageFile;
    _filters = [
      NoFilter(),
      AddictiveBlueFilter(),
      AddictiveRedFilter(),
      AdenFilter(),
      AmaroFilter(),
      AshbyFilter(),
      BrannanFilter(),
      BrooklynFilter(),
      CharmesFilter(),
      CremaFilter(),
      DogpatchFilter(),
    ];
    _loadImage();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    _imageBytes = bytes;
    setState(() {
      _isInitialized = true;
    });
  }

  // ⭐️ 2. (성능 개선) 필터 적용 로직을 비동기로 수정
  Future<void> _applyFilter(Filter filter) async {
    // ⭐️ 3. 로딩 팝업 띄우기 (영상 3:41)
    showLoadingDialog(context, 'Processing');

    try {
      // ⭐️ (성능 개선) heavy-lifting 작업을 Future로 감싸서 비동기 처리
      await Future(() {
        img.Image image = img.decodeImage(_imageBytes)!;
        Uint8List rawBytes = image.getBytes(format: img.Format.rgba);
        filter.apply(rawBytes, image.width, image.height);
        img.Image filteredImage = img.Image.fromBytes(
          image.width,
          image.height,
          rawBytes,
          format: img.Format.rgba,
        );
        final filteredBytes = img.encodeJpg(filteredImage);
        return filteredBytes;
      }).then((filteredBytes) async {
        final tempDir = await getTemporaryDirectory();
        final tempPath =
            '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg';
        _filteredImageFile = File(tempPath);
        await _filteredImageFile.writeAsBytes(filteredBytes);
      });

      setState(() {
        // 상태 업데이트
      });
    } catch (e) {
      print("Filter error: $e");
    } finally {
      // ⭐️ 4. 로딩 팝업 닫기
      hideLoadingDialog(context);
    }
  }

  // ⭐️ 5. (성능 개선) 썸네일 생성도 비동기로 처리 (FutureBuilder의 future)
  Future<List<int>> _generateThumbnail(Filter filter) async {
    return await Future(() {
      final img.Image? image = img.decodeImage(_imageBytes);
      if (image == null) return _imageBytes.toList();

      // 썸네일용으로 이미지 크기 줄이기 (성능 향상)
      final img.Image thumbnail = img.copyResize(image, width: 100);

      final bytes = thumbnail.getBytes(format: img.Format.rgba);
      filter.apply(bytes, thumbnail.width, thumbnail.height);

      final img.Image filteredImage = img.Image.fromBytes(
        thumbnail.width,
        thumbnail.height,
        bytes,
        format: img.Format.rgba,
      );
      return img.encodeJpg(filteredImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(_filteredImageFile),
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
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  height: 350,
                  color: Colors.grey[900],
                  child: Image.file(_filteredImageFile, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GestureDetector(
                          onTap: () => _applyFilter(filter),
                          child: Column(
                            children: [
                              Text(
                                filter.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: 100,
                                height: 100,
                                // ⭐️ 6. (성능 개선) 썸네일 생성 함수 연결
                                child: FutureBuilder<List<int>>(
                                  future: _generateThumbnail(filter),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.0,
                                          color: primaryColor,
                                        ),
                                      );
                                    }
                                    return Image.memory(
                                      Uint8List.fromList(snapshot.data!),
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
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
