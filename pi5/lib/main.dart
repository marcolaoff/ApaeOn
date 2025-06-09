import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'firebase_options.dart'; // <-- IMPORTANTE!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // <-- Usando as opções certas
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme(bool darkMode) {
    setState(() {
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Eventos',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF232323),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF232323)),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(
        onToggleTheme: _toggleTheme,
        darkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}
