import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importe o arquivo da sua tela de login

void main() {
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
