// 📍 lib/utils/loading_utils.dart (신규 파일)
// (Processing / Loading 팝업을 위한 유틸리티)

import 'package:flutter/material.dart';
import 'package:instagram/utils/colors.dart';

// ⭐️ "Processing", "Loading" 팝업을 띄우는 함수
void showLoadingDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false, // 로딩 중에는 밖을 탭해도 닫히지 않음
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
              const SizedBox(width: 20),
              Text(
                message,
                style: const TextStyle(color: primaryColor, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ⭐️ 팝업을 닫는 함수
void hideLoadingDialog(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  }
}
