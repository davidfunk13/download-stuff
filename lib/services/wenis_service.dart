import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WenisService manages the Go Engine subprocess.
/// It spawns the binary, sends JSON commands via STDIN,
/// and streams JSON responses from STDOUT.
class WenisService {
  Process? _process;
  final _responseController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of responses from the Go Engine.
  Stream<Map<String, dynamic>> get responses => _responseController.stream;

  /// Whether the engine is currently running.
  bool get isRunning => _process != null;

  /// Starts the Go Engine subprocess.
  Future<void> start() async {
    if (_process != null) {
      return; // Already running
    }

    // TODO: Update this path based on build output location
    // For development, we assume the binary is compiled to assets/bin/
    final executablePath = _getExecutablePath();

    _process = await Process.start(executablePath, []);

    // Listen to STDOUT for JSON responses
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (line.trim().isEmpty) return;
          try {
            final json = jsonDecode(line) as Map<String, dynamic>;
            _responseController.add(json);
          } catch (e) {
            // If it's not valid JSON, it might be a log message - ignore or log
            stderr.writeln('[WenisService] Non-JSON output: $line');
          }
        });

    // Listen to STDERR for debug logs
    _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          // These are debug logs from the Go engine
          stderr.writeln('[Go Engine] $line');
        });

    // Handle process exit
    _process!.exitCode.then((code) {
      stderr.writeln('[WenisService] Engine exited with code: $code');
      _process = null;
    });
  }

  /// Sends a command to the Go Engine.
  void sendCommand(String cmd, {String? url, String? quality}) {
    if (_process == null) {
      throw StateError('Engine not running. Call start() first.');
    }

    final command = <String, dynamic>{
      'cmd': cmd,
      if (url != null) 'url': url,
      if (quality != null) 'quality': quality,
    };

    final jsonString = jsonEncode(command);
    _process!.stdin.writeln(jsonString);
  }

  /// Stops the Go Engine subprocess.
  Future<void> stop() async {
    _process?.kill();
    _process = null;
  }

  /// Determines the correct executable path based on the platform.
  String _getExecutablePath() {
    // In development, assume we're running from the project root
    // and the binary is built at engine/cmd/engine/engine (or .exe on Windows)
    if (Platform.isWindows) {
      return 'engine/cmd/engine/engine.exe';
    } else {
      return 'engine/cmd/engine/engine';
    }
  }

  void dispose() {
    _process?.kill();
    _responseController.close();
  }
}

/// Provider for the WenisService singleton.
final wenisServiceProvider = Provider<WenisService>((ref) {
  final service = WenisService();
  ref.onDispose(service.dispose);
  return service;
});
