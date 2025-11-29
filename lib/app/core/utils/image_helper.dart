import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery or camera
  static Future<File?> pickImage({bool fromCamera = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Save image to app directory
  static Future<String?> saveImageToLocal(
      File imageFile, String productSku) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String productImagesDir = '${appDir.path}/product_images';

      // Create directory if not exists
      final Directory directory = Directory(productImagesDir);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Generate filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(imageFile.path);
      final String fileName = '${productSku}_$timestamp$extension';
      final String savedPath = '$productImagesDir/$fileName';

      // Copy file to app directory
      final File savedFile = await imageFile.copy(savedPath);

      return savedFile.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Delete image from local storage
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Check if image exists
  static Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;
    try {
      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get image file from path
  static File? getImageFile(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return null;
    final file = File(imagePath);
    return file;
  }
}
