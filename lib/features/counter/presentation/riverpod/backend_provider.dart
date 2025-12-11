import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/process_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Global provider for the process service
final processServiceProvider = Provider((ref) => ProcessService());

// Provider to check backend health
final backendHealthProvider = FutureProvider.autoDispose<String>((ref) async {
  // Wait a bit for startup
  await Future.delayed(const Duration(seconds: 1));

  try {
    final response = await http.get(Uri.parse('http://localhost:12345/health'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] as String;
    }
    return 'Error: ${response.statusCode}';
  } catch (e) {
    return 'Connection Failed: $e';
  }
});
