import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'eventos_screen.dart';
import 'admin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;
  const LoginScreen({super.key, this.onToggleTheme, this.darkMode = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool loading = false;
  String? errorMsg;

  // Novo estado para controlar se o formulário de login deve ser exibido
  bool mostrarLogin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo circular
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 48),

              // Pergunta inicial
              if (!mostrarLogin) ...[
                const Text(
                  "O que deseja fazer?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: 160,
                  height: 42,
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
                    onPressed: () {
                      setState(() {
                        mostrarLogin = true;
                      });
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 160,
                  height: 42,
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
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Registrar-se',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],

              // Formulário de Login
              if (mostrarLogin) ...[
                // Campo de email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Campo de senha
                TextField(
                  controller: senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 18),

                // Erro
                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                  ),

                // Botão Login
                SizedBox(
                  width: 90,
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
                    onPressed: loading ? null : login,
                    child: loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                // Botão Voltar formatado igual aos outros
                SizedBox(
                  width: 90,
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
                    onPressed: () {
                      setState(() {
                        mostrarLogin = false;
                        errorMsg = null;
                      });
                    },
                    child: const Text(
                      "Voltar",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
  setState(() {
    loading = true;
    errorMsg = null;
  });

  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: senhaController.text,
    );
    final user = userCredential.user;
    if (user == null) {
      setState(() {
        errorMsg = "Erro inesperado. Tente novamente!";
        loading = false;
      });
      return;
    }

    // Busca o documento do usuário na coleção "users"
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      setState(() {
        errorMsg = "Usuário não cadastrado na base de dados!";
        loading = false;
      });
      return;
    }

    final data = userDoc.data()!;
    final isAdmin = data['isAdmin'] ?? false;
    final nome = data['nome'] ?? '';
    final emailUser = data['email'] ?? '';

    if (!mounted) return;

    if (isAdmin == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AdminScreen(nome: nome, email: emailUser),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EventosScreen(
            onToggleTheme: widget.onToggleTheme,
            darkMode: widget.darkMode,
          ),
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    setState(() {
      errorMsg = e.message;
      loading = false;
    });
  } catch (e) {
    setState(() {
      errorMsg = "Erro ao fazer login. Tente novamente.";
      loading = false;
    });
  }
}

}
