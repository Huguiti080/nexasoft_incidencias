import 'package:flutter/material.dart';
import 'ui/pantalla_principal.dart';
//
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexaSoftApp());
}

class NexaSoftApp extends StatelessWidget {
  const NexaSoftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexaSoft | Mesa de ayuda',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF174C83)),
        scaffoldBackgroundColor: const Color.fromARGB(255, 202, 219, 244),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 8, 0, 128),
          foregroundColor: Color.fromARGB(255, 248, 219, 219),
          centerTitle: false,
        ),
      ),
      home: const PantallaPrincipal(),
    );
  }
}
