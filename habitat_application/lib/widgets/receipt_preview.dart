// widgets/receipt_preview.dart

import 'package:flutter/material.dart';
import 'dart:io';

class ReceiptPreview extends StatelessWidget {
  final File imageFile;

  const ReceiptPreview({
    Key? key,
    required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            imageFile,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}