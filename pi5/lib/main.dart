import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_screen.dart';
import 'firebase_options.dart';
import 'chatbot_screen.dart';
import 'eventos_screen.dart';
import 'admin_screen.dart';

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
  bool _darkMode = false;
  bool _carregandoTema = true;

  @override
  void initState() {
    super.initState();
    _loadInitialTheme();
  }

  /// Carrega o tema salvo no Firestore (users/{uid}.darkMode)
  Future<void> _loadInitialTheme() async {
    final user = FirebaseAuth.instance.currentUser;

    // Se ninguém estiver logado, usa tema claro por padrão
    if (user == null) {
      setState(() {
        _darkMode = false;
        _carregandoTema = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final savedDark = doc.data()?['darkMode'] == true;
      setState(() {
        _darkMode = savedDark;
        _carregandoTema = false;
      });
    } catch (_) {
      setState(() {
        _darkMode = false;
        _carregandoTema = false;
      });
    }
  }

  /// Chamado pelas telas (Eventos / Perfil / Admin) para trocar tema
  Future<void> _toggleTheme(bool darkMode) async {
    setState(() {
      _darkMode = darkMode;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'darkMode': darkMode}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Enquanto carrega o tema do Firestore, mostra uma tela simples
    if (_carregandoTema) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Gerenciador de Eventos',

      // Tema claro
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          labelStyle: const TextStyle(color: Colors.black87),
        ),
        cardColor: Colors.white,
        dialogBackgroundColor: Colors.white,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurple,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),

      // Tema escuro
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF18181B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF232323),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.deepPurpleAccent),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF232323),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          labelStyle: TextStyle(color: Colors.white70),
        ),
        cardColor: const Color(0xFF22212D),
        dialogBackgroundColor: const Color(0xFF22212D),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.deepPurpleAccent,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        switchTheme: const SwitchThemeData(
          thumbColor: MaterialStatePropertyAll(Colors.deepPurpleAccent),
          trackColor: MaterialStatePropertyAll(Colors.deepPurple),
        ),
      ),

      // Controla o tema
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,

      // Rotas extras (chatbot)
      routes: {
        '/chatbot': (context) => const ChatbotScreen(),
      },

      // Decide a tela inicial pelo estado do FirebaseAuth
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = authSnapshot.data;

          // Ninguém logado → vai para LoginScreen
          if (user == null) {
            return LoginScreen(
              onToggleTheme: _toggleTheme,
            );
          }

          // Usuário logado → busca dados no Firestore (isAdmin, nome, email, etc.)
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                // Se não tiver documento em "users", volta pro login
                return LoginScreen(
                  onToggleTheme: _toggleTheme,
                );
              }

              final data =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final isAdmin = data['isAdmin'] == true;
              final nome = data['nome'] ?? (user.displayName ?? '');
              final email = data['email'] ?? (user.email ?? '');

              if (isAdmin) {
                // Admin autenticado
                return AdminScreen(
                  nome: nome,
                  email: email,
                  onToggleTheme: _toggleTheme,
                  darkMode: _darkMode,
                );
              } else {
                // Usuário comum
                return EventosScreen(
                  onToggleTheme: _toggleTheme,
                );
              }
            },
          );
        },
      ),
    );
  }
}
