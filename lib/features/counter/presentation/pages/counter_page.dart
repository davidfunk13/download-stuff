import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/counter/presentation/riverpod/counter_provider.dart';
import '../riverpod/backend_provider.dart';

class CounterPage extends ConsumerWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    final healthAsync = ref.watch(backendHealthProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Backend Status:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    healthAsync.when(
                      data: (msg) => Text(
                        msg,
                        style: const TextStyle(color: Colors.green),
                      ),
                      error: (err, _) => Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                      loading: () => const CircularProgressIndicator.adaptive(),
                    ),
                  ],
                ),
              ),
            ),
            const Text('You have pushed the button this many times:'),
            Text('$count', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterProvider.notifier).increment(),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
