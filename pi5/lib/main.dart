import 'package:flutter/material.dart';
import 'login_screen.dart'; // Importe o arquivo da sua tela de login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gerenciador de Eventos',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const LoginScreen(), // Chama sua tela de login aqui
      debugShowCheckedModeBanner: false,
    );
  }
}
