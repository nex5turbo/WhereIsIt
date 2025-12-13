import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Helper class for managing image paths across app restarts.
/// 
/// On iOS/Android, the app's document directory path can change between
/// app launches. This helper ensures images are stored with just the filename
/// and the full path is reconstructed when needed.
class ImageHelper {
  /// Save an image to the app's documents directory and return ONLY the filename.
  /// 
  /// This filename can be stored in the database and will remain valid across
  /// app restarts, as long as we reconstruct the full path when loading.
  static Future<String?> saveImage(File image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${p.basename(image.path)}';
      await image.copy(p.join(appDir.path, fileName));
      
      // Return ONLY the filename, not the full path
      return fileName;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Reconstruct the full file path from a filename.
  /// 
  /// This should be called when loading an image to display.
  /// If the filename is null or the file doesn't exist, returns null.
  static Future<File?> getImageFile(String? fileName) async {
    if (fileName == null || fileName.isEmpty) return null;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File(p.join(appDir.path, fileName));
      
      // Check if file exists
      if (await file.exists()) {
        return file;
      } else {
        print('Image file not found: $fileName');
        return null;
      }
    } catch (e) {
      print('Error getting image file: $e');
      return null;
    }
  }

  /// Get the full path from a filename (synchronous version requires async initialization).
  /// 
  /// For use in FutureBuilder or when you need just the path string.
  static Future<String?> getImagePath(String? fileName) async {
    final file = await getImageFile(fileName);
    return file?.path;
  }
}
