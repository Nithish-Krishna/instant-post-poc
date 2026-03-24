import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MagicPostRepository {
  Future<Map<String, dynamic>> generatePost({
    required String prompt,
    required String tone,
    required List<Uint8List> images,
  }) async {
    // Determine Base URL depending on environment
    final String baseUrl = kDebugMode
        ? 'http://localhost:3000'
        : ''; // In production web, relative paths work

    final Uri uri = Uri.parse('$baseUrl/api/generate');

    // Convert Uint8List images to Base64 strings
    final List<String> base64Images = images
        .map((imageData) => base64Encode(imageData))
        .toList();

    // Prepare JSON body
    final Map<String, dynamic> requestBody = {
      'prompt': prompt,
      'tone': tone,
      'images': base64Images,
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-app-secret': 'Nieit@123',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to generate post: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Network or parsing error: $e');
    }
  }
}
