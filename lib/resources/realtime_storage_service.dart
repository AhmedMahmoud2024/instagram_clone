import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

class RealtimeStorageService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Singleton pattern
  static final RealtimeStorageService _instance =
      RealtimeStorageService._internal();

  factory RealtimeStorageService() {
    return _instance;
  }

  RealtimeStorageService._internal();
  // Compress image before converting to base64
  Future<Uint8List> _compressImage(Uint8List imageData) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageData);

      if (image == null) throw Exception('Could not decode image');

      // Resize image if it's too large
      if (image.width > 1000 || image.height > 1000) {
        image = img.copyResize(
          image,
          width: 1000,
          height: (1000 * image.height ~/ image.width),
        );
      }

      // Encode to jpg with quality
      List<int> compressedData = img.encodeJpg(image, quality: 70);

      return Uint8List.fromList(compressedData);
    } catch (e) {
      print('Compression error: $e');
      // Return original if compression fails
      return imageData;
    }
  }

  // Convert image to base64
  String _imageToBase64(Uint8List file) {
    try {
      return base64Encode(file);
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  // Main method to upload image
  Future<String> uploadImage({
    required Uint8List file,
    required String childName,
    bool isPost = false,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Compress image
      Uint8List compressedFile = await _compressImage(file);

      // Convert to base64
      String base64Image = base64Encode(compressedFile);

      String imageId = isPost ? const Uuid().v1() : 'profile';

      // Create database reference
      DatabaseReference ref = _database
          .ref()
          .child('images')
          .child(childName)
          .child(_auth.currentUser!.uid)
          .child(imageId);

      // Upload data
      await ref.set({
        'imageData': base64Image,
        'timestamp': ServerValue.timestamp,
        'userId': _auth.currentUser!.uid,
      });

      return base64Image;
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Get image from database
  Future<String?> getImage({
    required String childName,
    required String userId,
    String? imageId,
  }) async {
    try {
      DatabaseReference ref =
          _database.ref().child('images').child(childName).child(userId);
      if (imageId != null) {
        ref = ref.child(imageId);
      }
      final DatabaseEvent event = await ref.once();

      if (event.snapshot.value != null) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(event.snapshot.value as Map);
        return data['imageData'] as String;
      }

      return null;
    } catch (e) {
      print('Error getting image: $e');
      return null;
    }
  }

  // Delete image from database
  Future<bool> deleteImage({
    required String childName,
    required String imageId,
  }) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }
      await _database
          .ref()
          .child('images')
          .child(childName)
          .child(_auth.currentUser!.uid)
          .child(imageId)
          .remove();
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Widget to display base64 image
  Widget displayImage(
    String? base64Image, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (base64Image == null || base64Image.isEmpty) {
      return Image.asset(
        'assets/default_image.png',
        width: width,
        height: height,
        fit: fit,
      );
    }
    try {
      return Image.memory(
        base64Decode(base64Image),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/default_image.png',
            width: width,
            height: height,
            fit: fit,
          );
        },
      );
    } catch (e) {
      print('Error displaying image: $e');
      return Image.asset(
        'assets/default_image.png',
        width: width,
        height: height,
        fit: fit,
      );
    }
  }
}
