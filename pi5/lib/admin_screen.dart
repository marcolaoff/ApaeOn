import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_lerqrcode.dart'; // tela de validação

class AdminScreen extends StatelessWidget {
  final String nome;
  final String email;

  const AdminScreen({super.key, required this.nome, required this.email});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      // ou navegue para sua tela de login
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Painel do Administrador', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo, $nome!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
            const SizedBox(height: 8),
            Text(email, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 38),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text('Validar Ingressos', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaQRCode()),
                  );
                },
              ),
            ),
            const Spacer(),
            Center(
              child: SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  onPressed: () => _logout(context),
                  child: const Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
