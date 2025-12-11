import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class ProcessService {
  Process? _process;
  final int port = 12345;

  Future<void> spawnBackend() async {
    if (_process != null) return;

    try {
      if (kDebugMode) {
        // In Debug mode, we run 'go run' directly
        // Assuming we are running from the project root
        print('Starting backend in DEBUG mode...');
        _process = await Process.start('go', [
          'run',
          'engine/cmd/engine/main.go',
        ], runInShell: true);
      } else {
        // In Release mode, we expect the binary to be bundled next to the executable
        // or in a specific assets location.
        // For simplicity in this boilerplate, we'll look for 'backend' executable
        // in the same directory or assets/bin.
        final String executableName = Platform.isWindows
            ? 'engine.exe'
            : 'engine';
        final String path = _findExecutablePath(executableName);

        print('Starting backend in RELEASE mode from: $path');
        _process = await Process.start(path, []);
      }

      _process?.stdout.listen((event) {
        print('[BACKEND]: ${String.fromCharCodes(event)}');
      });

      _process?.stderr.listen((event) {
        print('[BACKEND_ERR]: ${String.fromCharCodes(event)}');
      });
    } catch (e) {
      print('Failed to spawn backend: $e');
    }
  }

  String _findExecutablePath(String executableName) {
    // Basic logic to find the executable relative to the running app.
    // Adjust based on Fastforge/Platform conventions.
    final String base = p.dirname(Platform.resolvedExecutable);

    // Check common locations
    final List<String> pathsToCheck = [
      p.join(base, executableName),
      p.join(
        base,
        'assets',
        'bin',
        executableName,
      ), // Common flutter_distributor location
      p.join(base, 'data', 'flutter_assets', 'assets', 'bin', executableName),
    ];

    for (final path in pathsToCheck) {
      if (File(path).existsSync()) {
        return path;
      }
    }

    // Fallback/Fail
    return executableName;
  }

  void killBackend() {
    _process?.kill();
    _process = null;
  }
}
