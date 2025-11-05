import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadPrescription(String userId, File file) async {
    try {
      final ext = path.extension(file.path);
      final ref = _storage.ref().child(
          'prescriptions/$userId/${DateTime.now().millisecondsSinceEpoch}$ext');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error uploading prescription: $e');
      }
      return null;
    }
  }

  /// Constructs the storage path that matches Firebase rules
  /// Rules expect: profile_images/{imageFilename} where filename starts with userId
  String _constructImagePath(String userId) {
    // Using timestamp ensures unique filenames if user uploads multiple times
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'profile_images/${userId}_profile_$timestamp.jpg';
  }

  Future<String?> uploadProfileImage(String userId, File imageFile) async {
    try {
      if (kDebugMode) {
        debugPrint('--- CHECK 2 (Storage Service) ---');
      }
      if (kDebugMode) {
        debugPrint('User ID: $userId');
      }
      if (kDebugMode) {
        debugPrint('Image file path: ${imageFile.path}');
      }
      if (kDebugMode) {
        debugPrint('File exists: ${await imageFile.exists()}');
      }

      // Verify file exists
      if (!await imageFile.exists()) {
        if (kDebugMode) {
          debugPrint('❌ ERROR: File does not exist at path: ${imageFile.path}');
        }
        return null;
      }

      // Construct path that matches Firebase Storage rules
      final imagePath = _constructImagePath(userId);
      if (kDebugMode) {
        debugPrint('Constructed storage path: $imagePath');
      }

      // Create a reference using the full path
      final ref = _storage.ref(imagePath);
      if (kDebugMode) {
        debugPrint('Storage reference path: ${ref.fullPath}');
      }

      if (kDebugMode) {
        debugPrint('🚀 Starting upload...');
      }

      // Upload the file with metadata
      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes * 100;
        if (kDebugMode) {
          debugPrint('📤 Upload progress: ${progress.toStringAsFixed(2)}%');
        }
      });

      // Wait for the upload to complete
      final snapshot = await uploadTask.whenComplete(() => {});
      if (kDebugMode) {
        debugPrint('✅ Upload completed successfully!');
      }

      // Get the permanent download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      if (kDebugMode) {
        debugPrint('🔗 Download URL: $downloadUrl');
      }

      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase Storage Error:');
      }
      if (kDebugMode) {
        debugPrint('   Code: ${e.code}');
      }
      if (kDebugMode) {
        debugPrint('   Message: ${e.message}');
      }
      if (kDebugMode) {
        debugPrint('   Details: ${e.toString()}');
      }

      // Common error explanations
      if (e.code == 'unauthorized') {
        if (kDebugMode) {
          debugPrint(
              '   → This usually means Storage Rules are blocking the upload');
        }
        if (kDebugMode) {
          debugPrint('   → Check Firebase Console → Storage → Rules');
        }
      } else if (e.code == 'unauthenticated') {
        if (kDebugMode) {
          debugPrint('   → User is not authenticated');
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected error uploading image:');
      }
      if (kDebugMode) {
        debugPrint('   ${e.toString()}');
      }
      return null;
    }
  }
}
