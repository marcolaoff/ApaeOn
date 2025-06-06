import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // Sua tela de login

class PerfilUsuarioScreen extends StatefulWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;

  const PerfilUsuarioScreen({
    super.key,
    this.onToggleTheme,
    this.darkMode = false,
  });

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  String nome = '';
  String email = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      loading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        nome = doc.data()?['nome'] ?? '';
        email = doc.data()?['email'] ?? '';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil de Usuário',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? (isDark ? const Color(0xFF232323) : Colors.white),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Avatar
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.person, size: 60, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {},
              child: const Text("Alterar Foto"),
            ),
            const SizedBox(height: 30),

            // Nome
            TextField(
              controller: TextEditingController(text: nome),
              decoration: InputDecoration(
                labelText: "Nome do Usuário",
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                  color: isDark ? Colors.white : Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              enabled: false,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 22),

            // Email
            TextField(
              controller: TextEditingController(text: email),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {},
                  color: isDark ? Colors.white : Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              enabled: false,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),

            const SizedBox(height: 40),

            // Botão Apagar Conta
            SizedBox(
              width: 160,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  foregroundColor: Colors.red,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Colors.black12),
                ),
                onPressed: () {
                  // implementar apagar conta
                },
                child: const Text(
                  'Apagar Conta',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Botão Logout
            SizedBox(
              width: 120,
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: const BorderSide(color: Colors.black12),
                ),
                onPressed: _logout,
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onToggleTheme: widget.onToggleTheme,
            darkMode: widget.darkMode,
          ),
        ),
            (route) => false,
      );
    }
  }
}
