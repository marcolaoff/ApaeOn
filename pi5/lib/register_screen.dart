import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Botão de voltar
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            // Conteúdo principal
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Crie sua Conta',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Campo CPF
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Digite seu CPF',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 18),

                    // Campo Nome
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Digite seu Nome',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 18),

                    // Campo Email
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Digite seu Email',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 18),

                    // Campo Senha
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Digite sua Senha',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      obscureText: true,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    ),
                    const SizedBox(height: 28),

                    // Botão Registrar
                    SizedBox(
                      width: 120,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: const BorderSide(color: Colors.black12),
                        ),
                        onPressed: () {},
                        child: const Text(
                          'Registrar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
