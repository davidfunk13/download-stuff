import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ignore: depend_on_referenced_packages
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // The WenisService will be lazily started when a provider needs it.
  // No need to pre-spawn the backend here anymore.
  runApp(const ProviderScope(child: App()));
}
