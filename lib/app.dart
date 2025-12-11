import 'package:flutter/material.dart';
import 'features/counter/presentation/pages/counter_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weenus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueGrey,
          brightness: Brightness.dark,
          surface: const Color(
            0xFF1E1E1E,
          ), // Slightly lighter than black for depth
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(
          0xFF121212,
        ), // Deep dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const CounterPage(title: 'Weenus Dashboard'),
    );
  }
}
