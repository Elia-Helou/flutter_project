import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../core/constants/colors.dart';
import '../services/food_recognition_service.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({Key? key}) : super(key: key);

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  final ImagePicker _picker = ImagePicker();
  final FoodRecognitionService _foodService = FoodRecognitionService();
  File? _selectedImage;
  String? _geminiResult;
  bool _isLoading = false;
  String? _error;

  Future<void> _processImage(File imageFile) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _geminiResult = null;
    });

    try {
      final result = await _foodService.recognizeFood(imageFile);
      setState(() {
        _geminiResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _processImage(_selectedImage!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
        await _processImage(_selectedImage!);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error taking photo: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Scan Food',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_selectedImage != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _geminiResult = null;
                        });
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _selectedImage != null
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  Image.file(
                                    _selectedImage!,
                                    height: 300,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  if (_geminiResult != null)
                                    Card(
                                      margin: const EdgeInsets.all(16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(
                                          _geminiResult!,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Stack(
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.black,
                                  child: const Center(
                                    child: Text(
                                      'Camera Preview Placeholder',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Container(
                                    width: 250,
                                    height: 250,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(color: Colors.white, width: 6),
                                    ),
                                  ),
                                ),
                              ],
                            ),
            ),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).toInt()),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.photo_library, size: 32, color: AppColors.textSecondary),
                    onPressed: _pickFromGallery,
                  ),
                  GestureDetector(
                    onTap: _takePhoto,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.pink[100],
                      ),
                      child: Center(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.pink[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.cameraswitch, size: 32, color: AppColors.textSecondary),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 