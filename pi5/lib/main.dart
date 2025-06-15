import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          titleMedium: TextStyle(color: Colors.black87),
          labelLarge: TextStyle(color: Colors.deepPurple),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          labelStyle: const TextStyle(color: Colors.black87),
        ),
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF18181B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF232323),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.deepPurpleAccent),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF232323),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        cardColor: const Color(0xFF22212D),
        dialogBackgroundColor: const Color(0xFF22212D),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurpleAccent,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.all(Colors.deepPurpleAccent),
          trackColor: MaterialStateProperty.all(Colors.deepPurple),
        ),
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: LoginScreen(
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}
