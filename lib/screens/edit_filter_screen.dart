// 📍 lib/screens/edit_filter_screen.dart (가짜 필터 Mockup, 성능 문제 해결)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';
// ⭐️ 1. 로딩 유틸리티 import (오류 해결!)
import 'package:instagram/utils/loading_utils.dart';
// (photofilters, image, path_provider import 모두 삭제)

class EditFilterScreen extends StatefulWidget {
  final File imageFile;
  const EditFilterScreen({super.key, required this.imageFile});
  @override
  State<EditFilterScreen> createState() => _EditFilterScreenState();
}

class _EditFilterScreenState extends State<EditFilterScreen> {
  // ⭐️ 2. 교수님 요청대로, 가짜 필터 이름 리스트
  final List<String> _filters = [
    'Normal',
    'Clarendon',
    'Gingham',
    'Moon',
    'Lark',
    'Reyes',
    'Juno',
    'Slumber',
    'Crema',
    'Ludwig',
    'Aden',
    'Perpetua'
  ];

  String _selectedFilter = 'Normal';

  // ⭐️ 3. 실제 필터링 로직 제거! (성능 향상)
  // 클릭 시 "Processing" 팝업만 띄우고 닫습니다.
  void _applyFilter(String filterName) async {
    if (_selectedFilter == filterName) return;

    setState(() {
      _selectedFilter = filterName;
    });

    // ⭐️ 4. (영상 1:56) "Processing" 팝업을 띄웠다가
    showLoadingDialog(context, 'Processing');
    // ⭐️ 0.2초 후에 닫아서, 클릭한 '척'만 합니다.
    await Future.delayed(const Duration(milliseconds: 200));
    hideLoadingDialog(context);

    // (실제 이미지 파일은 절대 변경하지 않습니다)
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
            // ⭐️ 5. "Next" 누르면 원본 파일을 그대로 반환 (영상 2:00)
            onPressed: () => Navigator.of(context).pop(widget.imageFile),
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
          // ⭐️ 6. 메인 이미지 (항상 원본)
          Container(
            height: 350,
            color: Colors.grey[900],
            child: Image.file(widget.imageFile, fit: BoxFit.contain),
          ),
          const SizedBox(height: 16),
          // ⭐️ 7. 가짜 필터 썸네일 리스트
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filterName = _filters[index];
                final bool isSelected = _selectedFilter == filterName;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () => _applyFilter(filterName),
                    child: Column(
                      children: [
                        Text(
                          filterName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            // ⭐️ 선택된 필터 텍스트 강조
                            color: isSelected ? Colors.blue : primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ⭐️ 가짜 썸네일 (교수님 요청)
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            // ⭐️ 가짜 필터 이미지 대신 원본 + 테두리
                            image: DecorationImage(
                              image: FileImage(widget.imageFile),
                              fit: BoxFit.cover,
                            ),
                            // ⭐️ 선택된 필터 테두리 강조
                            border: isSelected
                                ? Border.all(color: Colors.blue, width: 3)
                                : null,
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
