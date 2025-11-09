import 'dart:io';
import 'dart:typed_data'; // 1. 이미지 바이트(Uint8List)를 다루기 위해 import
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img; // 2. 'image' 패키지 import
import 'package:instagram/utils/colors.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/photofilters.dart'; // 3. 'photofilters' 패키지 import
import 'package:photofilters/filters/filters.dart';

class EditFilterScreen extends StatefulWidget {
  final File imageFile;
  const EditFilterScreen({super.key, required this.imageFile});
  @override
  State<EditFilterScreen> createState() => _EditFilterScreenState();
}

class _EditFilterScreenState extends State<EditFilterScreen> {
  late Uint8List _imageBytes; // 원본 (인코딩된) 바이트
  late File _filteredImageFile; // 화면에 표시될 최종 파일
  late List<Filter> _filters;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filteredImageFile = widget.imageFile; // 처음엔 원본으로 시작
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
    _imageBytes = bytes; // 썸네일용 원본 바이트 저장
    setState(() {
      _isLoading = false;
    });
  }

  // ⭐️ 4. [버그 수정] 필터를 적용하는 올바른 로직
  Future<void> _applyFilter(Filter filter) async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    // 1. 원본 이미지를 디코딩
    img.Image image = img.decodeImage(_imageBytes)!;

    // 2. 이미지의 원시(Raw) RGBA 바이트를 가져옴
    Uint8List rawBytes = image.getBytes(format: img.Format.rgba);

    // 3. 필터 적용 (이 함수는 rawBytes 리스트 자체를 수정함)
    filter.apply(rawBytes, image.width, image.height);

    // 4. 수정된 rawBytes로부터 새 img.Image 객체 생성
    img.Image filteredImage = img.Image.fromBytes(
      image.width,
      image.height,
      rawBytes,
      format: img.Format.rgba, // RGBA 형식으로 다시 조립
    );

    // 5. 새 이미지를 JPG로 다시 인코딩
    final filteredBytes = img.encodeJpg(filteredImage);

    // 6. 임시 파일로 저장 (기존 로직 동일)
    final tempDir = await getTemporaryDirectory();
    final tempPath =
        '${tempDir.path}/filtered_${DateTime.now().millisecondsSinceEpoch}.jpg';
    _filteredImageFile = File(tempPath);
    await _filteredImageFile.writeAsBytes(filteredBytes);

    setState(() {
      _isLoading = false; // 로딩 끝
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
            onPressed: _isLoading
                ? null // 로딩 중에는 Next 버튼 비활성화
                : () => Navigator.of(context).pop(_filteredImageFile),
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
      // ⭐️ 5. 로딩 중일 땐 화면 전체에 로딩 표시
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 6. 메인 이미지 (정상 표시)
                Container(
                  height: 350,
                  color: Colors.grey[900],
                  child: Image.file(_filteredImageFile, fit: BoxFit.contain),
                ),
                const SizedBox(height: 16),
                // 7. 필터 썸네일 리스트 (정상 표시)
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
                                child: FutureBuilder<List<int>>(
                                  future: Future(() {
                                    final img.Image? image =
                                        img.decodeImage(_imageBytes);
                                    if (image == null) return _imageBytes;

                                    final bytes = image.getBytes();
                                    filter.apply(
                                        bytes, image.width, image.height);

                                    final filteredImage = img.Image.fromBytes(
                                      image.width,
                                      image.height,
                                      bytes,
                                    );

                                    return img.encodeJpg(filteredImage);
                                  }),
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
