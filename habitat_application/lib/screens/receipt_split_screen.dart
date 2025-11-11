// screens/receipt_split_screen.dart

import 'package:flutter/material.dart';
import 'dart:io';  
import 'package:image_picker/image_picker.dart';
import '../models/receipt_model.dart';
import '../widgets/receipt_preview.dart';
import '../widgets/item_allocation_screen.dart';
import '../widgets/split_summary_screen.dart';

class ReceiptSplitScreen extends StatefulWidget {
  const ReceiptSplitScreen({Key? key}) : super(key: key);

  @override
  State<ReceiptSplitScreen> createState() => _ReceiptSplitScreenState();
}

class _ReceiptSplitScreenState extends State<ReceiptSplitScreen> {
  File? _imageFile;
  Receipt? _receipt;
  bool _isProcessing = false;
  int _currentStep = 0; // 0: capture, 1: review, 2: allocate, 3: summary

  final ImagePicker _picker = ImagePicker();

  Future<void> _captureReceipt() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _imageFile = File(photo.path);
          _currentStep = 1;
        });
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
          _currentStep = 1;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _processReceipt() async {
    if (_imageFile == null) return;

    setState(() => _isProcessing = true);

    try {
      // TODO: Implement actual OCR here
      // For now, create dummy data
      await Future.delayed(const Duration(seconds: 2));

      final receiptData = ReceiptData(
        merchantName: 'Mega Bigbox',
        date: DateTime.now(),
        items: [
          ReceiptItem(
            id: '1',
            name: 'LG Flatscreen 65',
            price: 899.99,
            quantity: 1,
          ),
          ReceiptItem(
            id: '2',
            name: 'Sony VIAO I7 6938',
            price: 689.99,
            quantity: 1,
          ),
          ReceiptItem(
            id: '3',
            name: '6FT HDMI Cable',
            price: 19.99,
            quantity: 1,
          ),
          ReceiptItem(
            id: '4',
            name: 'Apple TV V4',
            price: 89.99,
            quantity: 1,
          )
        ],
        subtotal: 1699.96,
        tax: 110.50,
        tip: 6.00,
      );

      setState(() {
        _receipt = Receipt(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imageUrl: _imageFile!.path,
          data: receiptData,
          participants: [],
        );
        _currentStep = 2;
      });
    } catch (e) {
      _showError('Failed to process receipt: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _retakePhoto() {
    setState(() {
      _imageFile = null;
      _receipt = null;
      _currentStep = 0;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFB4C9B4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _getStepTitle(),
          style: const TextStyle(color: Colors.white),
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    if (_currentStep > 0) _currentStep--;
                    if (_currentStep == 0) {
                      _imageFile = null;
                      _receipt = null;
                    }
                  });
                },
              )
            : null,
      ),
      body: _buildCurrentStep(),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Scan Receipt';
      case 1:
        return 'Review Photo';
      case 2:
        return 'Allocate Items';
      case 3:
        return 'Split Summary';
      default:
        return 'Split Bill';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCaptureStep();
      case 1:
        return _buildReviewStep();
      case 2:
        return _buildAllocationStep();
      case 3:
        return _buildSummaryStep();
      default:
        return _buildCaptureStep();
    }
  }

  Widget _buildCaptureStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(48),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long,
                size: 80,
                color: Color(0xFF6B8E6B),
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Snap a photo of your receipt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ll scan it and help you split the bill',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            _buildButton(
              icon: Icons.camera_alt,
              label: 'Take Photo',
              onPressed: _captureReceipt,
            ),
            const SizedBox(height: 16),
            _buildButton(
              icon: Icons.photo_library,
              label: 'Choose from Gallery',
              onPressed: _pickFromGallery,
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      children: [
        Expanded(
          child: _imageFile != null
              ? ReceiptPreview(imageFile: _imageFile!)
              : const Center(child: Text('No image')),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Does the receipt look clear?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Make sure all items and prices are visible',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _retakePhoto,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _processReceipt,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isProcessing ? 'Processing...' : 'Looks Good'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B8E6B),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllocationStep() {
    if (_receipt == null) return const SizedBox();

    return ItemAllocationScreen(
      receipt: _receipt!,
      onComplete: (updatedReceipt) {
        setState(() {
          _receipt = updatedReceipt;
          _currentStep = 3;
        });
      },
    );
  }

  Widget _buildSummaryStep() {
    if (_receipt == null) return const SizedBox();

    return SplitSummaryScreen(
      receipt: _receipt!,
      onDone: () {
        // Navigate back or to home
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? Colors.white : Colors.white.withOpacity(0.9),
          foregroundColor: const Color(0xFF6B8E6B),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}