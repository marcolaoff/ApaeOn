import 'package:flutter/material.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  const PerfilUsuarioScreen({super.key});

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  String nome = "Fulaninho";
  String email = "fulano@a.com";

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil de Usuario',
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
      body: SingleChildScrollView(
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
              onPressed: () {
                // implementar troca de foto futuramente
              },
              child: const Text("Alterar Foto"),
            ),
            const SizedBox(height: 30),

            // Campo Nome
            TextField(
              controller: TextEditingController(text: nome),
              decoration: InputDecoration(
                labelText: "Nome do Usuario",
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // implementar edição de nome
                  },
                  color: isDark ? Colors.white : Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              enabled: false, // Apenas visualização, para editar remova o enabled!
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 22),

            // Campo Email
            TextField(
              controller: TextEditingController(text: email),
              decoration: InputDecoration(
                labelText: "Email",
                labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // implementar edição de email
                  },
                  color: isDark ? Colors.white : Colors.black,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                isDense: true,
              ),
              enabled: false, // Apenas visualização, para editar remova o enabled!
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),

            const SizedBox(height: 40),

            // Botão apagar conta
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
          ],
        ),
      ),
    );
  }
}
