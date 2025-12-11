import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/counter/presentation/riverpod/counter_provider.dart';
import '../riverpod/backend_provider.dart';

class CounterPage extends ConsumerStatefulWidget {
  const CounterPage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends ConsumerState<CounterPage> {
  @override
  void reassemble() {
    super.reassemble();
    // Invalidate the provider on Hot Reload to re-fetch backend status
    ref.invalidate(backendHealthProvider);
  }

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(counterProvider);
    final healthAsync = ref.watch(backendHealthProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh W.E.N.I.S. Connection',
            onPressed: () => ref.invalidate(backendHealthProvider),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {}, // Placeholder for future settings
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Backend Status Card
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
                          textAlign: TextAlign.center,
                        ),
                        error: (err, _) => Text(
                          'Error: $err',
                          style: const TextStyle(color: Colors.red),
                        ),
                        loading: () =>
                            const CircularProgressIndicator.adaptive(),
                      ),
                    ],
                  ),
                ),
              ),

              // Interaction PoC Card
              Consumer(
                builder: (context, ref, child) {
                  final randomAsync = ref.watch(randomMessageProvider);
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Interaction PoC:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          randomAsync.when(
                            data: (msg) =>
                                Text(msg, textAlign: TextAlign.center),
                            error: (err, _) => Text(
                              'Error: $err',
                              style: const TextStyle(color: Colors.red),
                            ),
                            loading: () => const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => ref.refresh(randomMessageProvider),
                            icon: const Icon(Icons.casino),
                            label: const Text('Fetch Random Message'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),
              const Text('You have pushed the button this many times:'),
              Text('$count', style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
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
