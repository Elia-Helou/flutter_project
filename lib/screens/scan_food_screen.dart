import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/colors.dart';

class ScanFoodScreen extends StatefulWidget {
  const ScanFoodScreen({Key? key}) : super(key: key);

  @override
  State<ScanFoodScreen> createState() => _ScanFoodScreenState();
}

class _ScanFoodScreenState extends State<ScanFoodScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // Handle the picked image here
        // debugPrint('Image picked: \\${image.path}');
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
        // Handle the captured photo here
        // debugPrint('Photo taken: \\${photo.path}');
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
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Scan Food',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
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
                  // Overlay scan frame
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
                  // Close button (top left)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withAlpha((0.4 * 255).toInt()),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  // Flash button (top right)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withAlpha((0.4 * 255).toInt()),
                      child: const Icon(Icons.flash_on, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom bar
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
                  // Gallery icon
                  IconButton(
                    icon: Icon(Icons.photo_library, size: 32, color: AppColors.textSecondary),
                    onPressed: _pickFromGallery,
                  ),
                  // Capture button
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
                  // Swap camera icon
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