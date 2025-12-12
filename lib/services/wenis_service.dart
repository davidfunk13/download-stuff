import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// WenisService manages the Go Engine connection.
/// In Production: Spawns the binary and uses Stdin/Stdout.
/// In Dev Mode: Connects to an external TCP socket via localhost.
class WenisService {
  Process? _process;
  Socket? _socket;

  // Dev Mode Flag: Set to true to connect to 'make dev' backend
  static const bool useExternalBackend = kDebugMode;
  static const int externalPort = 2024;

  final _responseController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Auto-incrementing request ID for correlation
  int _requestIdCounter = 0;

  /// Pending requests awaiting responses, keyed by request ID
  final Map<String, Completer<Map<String, dynamic>>> _pendingRequests = {};

  /// Stream of responses from the Go Engine.
  Stream<Map<String, dynamic>> get responses => _responseController.stream;

  /// Whether the engine is currently running/connected.
  bool get isRunning => _process != null || _socket != null;

  /// Starts the Engine connection.
  Future<void> start() async {
    if (isRunning) return;

    if (useExternalBackend) {
      await _connectToExternalBackend();
    } else {
      await _spawnInternalProcess();
    }
  }

  Future<void> _connectToExternalBackend() async {
    try {
      print(
        '[WenisService] Connecting to external backend at localhost:$externalPort...',
      );
      _socket = await Socket.connect('localhost', externalPort);
      print('[WenisService] Connected to external backend.');

      // Listen to Socket for JSON responses
      _socket!
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            _handleResponseLine,
            onError: (e) => stderr.writeln('[WenisService] Socket Error: $e'),
            onDone: () {
              stderr.writeln('[WenisService] External backend disconnected.');
              _socket = null;
            },
          );
    } catch (e) {
      stderr.writeln(
        '[WenisService] Failed to connect to external backend: $e',
      );
      stderr.writeln(
        '[WenisService] Make sure to run `make dev` in a separate terminal!',
      );
      rethrow;
    }
  }

  Future<void> _spawnInternalProcess() async {
    // Correct path for production build
    final executablePath = 'assets/bin/wenis_engine_linux';

    print('[WenisService] Spawning internal process: $executablePath');
    _process = await Process.start(executablePath, []);

    // Listen to STDOUT for JSON responses
    _process!.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(_handleResponseLine);

    // Listen to STDERR for debug logs
    _process!.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          stderr.writeln('[Go Engine] $line');
        });

    _process!.exitCode.then((code) {
      stderr.writeln('[WenisService] Engine exited with code: $code');
      _process = null;
    });
  }

  void _handleResponseLine(String line) {
    if (line.trim().isEmpty) return;
    try {
      final json = jsonDecode(line) as Map<String, dynamic>;

      // Check if this response has an ID that matches a pending request
      final id = json['id'] as String?;
      if (id != null && _pendingRequests.containsKey(id)) {
        _pendingRequests[id]!.complete(json);
        _pendingRequests.remove(id);
      }

      // Also broadcast to the stream for subscribers (e.g., progress updates)
      _responseController.add(json);
    } catch (e) {
      stderr.writeln('[WenisService] Non-JSON output: $line');
    }
  }

  /// Sends a command and returns a Future that completes with the response.
  /// Use this for request-response patterns (e.g., extract, health check).
  Future<Map<String, dynamic>> sendRequest(
    String cmd, {
    String? url,
    String? quality,
  }) {
    final id = (_requestIdCounter++).toString();
    final completer = Completer<Map<String, dynamic>>();
    _pendingRequests[id] = completer;

    final command = <String, dynamic>{
      'id': id,
      'cmd': cmd,
      if (url != null) 'url': url,
      if (quality != null) 'quality': quality,
    };

    _writeCommand(command);
    return completer.future;
  }

  /// Sends a command without waiting for a response (fire-and-forget).
  /// Use this for commands where you listen to the response stream instead.
  void sendCommand(String cmd, {String? url, String? quality}) {
    print('[WenisService] Sending Command: $cmd');
    if (!isRunning) {
      throw StateError('Engine not running. Call start() first.');
    }

    final command = <String, dynamic>{
      'cmd': cmd,
      if (url != null) 'url': url,
      if (quality != null) 'quality': quality,
    };

    _writeCommand(command);
  }

  void _writeCommand(Map<String, dynamic> command) {
    if (!isRunning) {
      throw StateError('Engine not running. Call start() first.');
    }

    final jsonString = '${jsonEncode(command)}\n';

    if (_socket != null) {
      _socket!.write(jsonString);
    } else if (_process != null) {
      _process!.stdin.write(jsonString);
    }
  }

  /// Requests graceful shutdown of the Go engine.
  Future<void> shutdown() async {
    if (!isRunning) return;
    try {
      await sendRequest('shutdown');
    } catch (_) {
      // Engine may exit before responding
    }
  }

  /// Stops the Go Engine connection.
  Future<void> stop() async {
    _socket?.destroy();
    _socket = null;
    _process?.kill();
    _process = null;
    // Complete any pending requests with an error
    for (final completer in _pendingRequests.values) {
      completer.completeError(StateError('Engine stopped'));
    }
    _pendingRequests.clear();
  }

  void dispose() {
    stop();
    _responseController.close();
  }
}

/// Provider for the WenisService singleton.
final wenisServiceProvider = Provider<WenisService>((ref) {
  final service = WenisService();
  ref.onDispose(service.dispose);
  return service;
});
