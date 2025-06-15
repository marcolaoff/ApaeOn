import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;
  const RegisterScreen({super.key, this.onToggleTheme, this.darkMode = false});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final cpfController = TextEditingController();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  bool loading = false;
  String? errorMsg;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
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
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 36),
                    TextField(
                      controller: cpfController,
                      decoration: InputDecoration(
                        labelText: 'Digite seu CPF',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        labelText: 'Digite seu Nome',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                        isDense: true,
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Digite seu Email',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                        isDense: true,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: senhaController,
                      decoration: InputDecoration(
                        labelText: 'Digite sua Senha',
                        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                        isDense: true,
                      ),
                      obscureText: true,
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 18),
                    if (errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                      ),
                    SizedBox(
                      width: 120,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: loading ? null : register,
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Registrar'),
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

  Future<void> register() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    if (cpfController.text.trim().isEmpty ||
        nomeController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        senhaController.text.isEmpty) {
      setState(() {
        errorMsg = "Preencha todos os campos!";
        loading = false;
      });
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: senhaController.text,
      );
      final uid = credential.user?.uid;
      if (uid == null) {
        setState(() {
          errorMsg = "Erro desconhecido ao registrar usuário.";
          loading = false;
        });
        return;
      }
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'cpf': cpfController.text.trim(),
        'nome': nomeController.text.trim(),
        'email': emailController.text.trim(),
        'isAdmin': false,
      });

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = e.message;
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "Erro inesperado: $e";
        loading = false;
      });
    }
  }
}
