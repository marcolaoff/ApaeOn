import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'eventos_screen.dart';
import 'admin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  final void Function(bool)? onToggleTheme;
  const LoginScreen({super.key, this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  bool loading = false;
  String? errorMsg;
  bool mostrarLogin = false;

  /// Traduz erros do Firebase para português
  String _traduzErroFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
        return 'Nenhuma conta encontrada.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'user-disabled':
        return 'Conta desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente mais tarde.';
      case 'network-request-failed':
        return 'Falha na internet.';
      default:
        return 'Erro ao fazer login.';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = theme.textTheme.bodyLarge?.color ??
        (isDark ? Colors.white : Colors.black);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // LOGO
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.jpg', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 48),

              // TELA INICIAL - login/registrar
              if (!mostrarLogin) ...[
                Text(
                  "O que deseja fazer?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 28),

                // BOTÃO LOGIN
                SizedBox(
                  width: 160,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        mostrarLogin = true;
                        errorMsg = null;
                      });
                    },
                    child: const Text("Login",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 14),

                // BOTÃO REGISTRAR
                SizedBox(
                  width: 160,
                  height: 42,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RegisterScreen(onToggleTheme: widget.onToggleTheme),
                        ),
                      );
                    },
                    child: const Text("Registrar-se",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],

              // TELA DE LOGIN
              if (mostrarLogin) ...[
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: senhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 18),

                if (errorMsg != null)
                  Text(errorMsg!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),

                const SizedBox(height: 12),

                // BOTÃO LOGIN
                SizedBox(
                  width: 100,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: loading ? null : login,
                    child: loading
                        ? const CircularProgressIndicator(strokeWidth: 2)
                        : const Text("Login",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),

                const SizedBox(height: 14),

                // BOTÃO VOLTAR
                SizedBox(
                  width: 100,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        mostrarLogin = false;
                        errorMsg = null;
                      });
                    },
                    child: const Text("Voltar",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  // ================= LOGIN =================

  Future<void> login() async {
    final email = emailController.text.trim();
    final senha = senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      setState(() => errorMsg = "Preencha email e senha.");
      return;
    }

    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      // LOGIN
      final userCred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: senha);

      final user = userCred.user!;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        setState(() {
          loading = false;
          errorMsg = "Usuário não encontrado no banco.";
        });
        return;
      }

      final data = doc.data()!;
      final isAdmin = data['isAdmin'] == true;
      final savedDark = data['darkMode'] == true;

      // 🔥 Ativar tema salvo
      if (widget.onToggleTheme != null) widget.onToggleTheme!(savedDark);

      setState(() => loading = false);

      // REDIRECIONAR
      if (!mounted) return;

      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminScreen(
              nome: data['nome'],
              email: data['email'],
              onToggleTheme: widget.onToggleTheme,
              darkMode: savedDark,
            ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                EventosScreen(onToggleTheme: widget.onToggleTheme),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMsg = _traduzErroFirebase(e);
        loading = false;
      });
    } catch (e) {
      setState(() {
        errorMsg = "Erro inesperado.";
        loading = false;
      });
    }
  }
}
