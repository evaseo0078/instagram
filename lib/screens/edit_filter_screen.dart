import 'dart:io';
import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';
import 'package:instagram/utils/loading_utils.dart';

class EditFilterScreen extends StatefulWidget {
  final File imageFile;
  const EditFilterScreen({super.key, required this.imageFile});
  @override
  State<EditFilterScreen> createState() => _EditFilterScreenState();
}

class _EditFilterScreenState extends State<EditFilterScreen> {
  // 가짜 필터 이름들
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

  // ⭐️ 필터를 눌러도 "Processing" 척만 하고 이미지는 안 바꿈
  void _applyFilter(String filterName) async {
    if (_selectedFilter == filterName) return;

    setState(() {
      _selectedFilter = filterName;
    });

    // 잠깐 로딩만 보여주고 끝 (이미지 변환 X)
    showLoadingDialog(context, 'Processing');
    await Future.delayed(const Duration(milliseconds: 200));
    hideLoadingDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            // ⭐️ "Next" 누르면 무조건 원본 파일(widget.imageFile) 반환
            onPressed: () => Navigator.of(context).pop(widget.imageFile),
            child: const Text(
              'Next',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // ⭐️ 메인 이미지 (4:3 비율 유지해서 보여줌)
          Container(
            width: double.infinity,
            height: 400, // 적당한 프리뷰 높이
            color: Colors.grey[100],
            child:
                Image.file(widget.imageFile, fit: BoxFit.contain), // 원본 비율 유지
          ),
          const SizedBox(height: 16),
          // 하단 필터 리스트 (UI만 존재)
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
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(widget.imageFile),
                              fit: BoxFit.cover,
                            ),
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 2)
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
