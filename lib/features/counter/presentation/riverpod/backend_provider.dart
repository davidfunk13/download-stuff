import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/wenis_service.dart';

// Re-export the WenisService provider for convenience
export '../../../../services/wenis_service.dart' show wenisServiceProvider;

/// Provider that ensures the engine is started and returns the service.
final engineStateProvider = FutureProvider<WenisService>((ref) async {
  final service = ref.watch(wenisServiceProvider);
  if (!service.isRunning) {
    await service.start();
  }
  return service;
});

/// Provider for backend health status using the new JSON-RPC protocol.
final backendHealthProvider = StreamProvider.autoDispose<String>((ref) async* {
  final engineAsync = ref.watch(engineStateProvider);

  yield* engineAsync.when(
    data: (service) async* {
      // Send health command
      service.sendCommand('health');

      // Listen for the response
      await for (final response in service.responses) {
        if (response['status'] == 'ok') {
          yield response['data'] as String? ?? 'Unknown';
          return;
        } else if (response['status'] == 'error') {
          yield 'Error: ${response['log']}';
          return;
        }
      }
    },
    loading: () => Stream.value('Starting W.E.N.I.S. Engine...'),
    error: (e, _) => Stream.value('Engine Start Failed: $e'),
  );
});

/// Provider for random message (on-demand via refresh).
final randomMessageProvider = StreamProvider.autoDispose<String>((ref) async* {
  final engineAsync = ref.watch(engineStateProvider);

  yield* engineAsync.when(
    data: (service) async* {
      // Send random command
      service.sendCommand('random');

      // Listen for the response
      await for (final response in service.responses) {
        if (response['status'] == 'ok') {
          yield response['data'] as String? ?? 'Unknown';
          return;
        } else if (response['status'] == 'error') {
          yield 'Error: ${response['log']}';
          return;
        }
      }
    },
    loading: () => Stream.value('Waiting for engine...'),
    error: (e, _) => Stream.value('Engine Error: $e'),
  );
});
