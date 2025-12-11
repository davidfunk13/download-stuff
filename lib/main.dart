import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ignore: depend_on_referenced_packages
import '../core/services/process_service.dart';
import 'features/counter/presentation/riverpod/backend_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final processService = ProcessService();
  await processService.spawnBackend();

  runApp(
    ProviderScope(
      overrides: [processServiceProvider.overrideWithValue(processService)],
      child: const App(),
    ),
  );
}
