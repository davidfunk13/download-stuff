import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/process_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Global provider for the process service
final processServiceProvider = Provider((ref) => ProcessService());

// Provider to check backend health
// Provider to check backend health (Refreshes on Hot Reload)
final backendHealthProvider = FutureProvider.autoDispose<String>((ref) async {
  // Wait a bit to ensure backend is ready if just spawned
  await Future.delayed(const Duration(milliseconds: 500));

  try {
    final response = await http.get(Uri.parse('http://localhost:3001/health'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] as String;
    }
    return 'Error: ${response.statusCode}';
  } catch (e) {
    return 'Connection Failed: W.E.N.I.S. Offline';
  }
});

// Provider for random message (on-demand)
final randomMessageProvider = FutureProvider.autoDispose<String>((ref) async {
  try {
    final response = await http.get(Uri.parse('http://localhost:3001/random'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['message'] as String;
    }
    return 'Error: ${response.statusCode}';
  } catch (e) {
    return 'Failed to fetch random message';
  }
});
