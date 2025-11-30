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

  /// Traduz os códigos de erro do FirebaseAuth para mensagens em português
  String _traduzErroFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido. Verifique o formato.';
      case 'user-not-found':
        return 'Nenhuma conta foi encontrada com este e-mail.';
      case 'wrong-password':
        return 'Senha incorreta. Tente novamente.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas de login. Aguarde e tente novamente.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet.';
      case 'invalid-credential':
        return 'E-mail ou senha incorretos. Verifique e tente novamente.';
      default:
        return 'Erro ao fazer login. Tente novamente.';
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
    final textColor =
        theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[300],
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

              // Tela inicial (escolha login / registrar)
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
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        mostrarLogin = true;
                        errorMsg = null;
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
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(
                            onToggleTheme: widget.onToggleTheme,
                          ),
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

              // Tela de login (campos + botões)
              if (mostrarLogin) ...[
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: senhaController,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: isDark ? Colors.grey[900] : Colors.white,
                  ),
                  obscureText: true,
                  style: TextStyle(color: textColor),
                ),
                const SizedBox(height: 18),

                if (errorMsg != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      errorMsg!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
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

                SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: textColor,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
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
    final email = emailController.text.trim();
    final senha = senhaController.text;

    // ===== VALIDAÇÕES INICIAIS =====
    if (email.isEmpty && senha.isEmpty) {
      setState(() {
        errorMsg = 'Preencha e-mail e senha para continuar.';
      });
      return;
    }

    if (email.isNotEmpty && senha.isEmpty) {
      setState(() {
        errorMsg = 'Digite sua senha para continuar.';
      });
      return;
    }

    if (email.isEmpty && senha.isNotEmpty) {
      setState(() {
        errorMsg = 'Digite seu e-mail para continuar.';
      });
      return;
    }

    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      // LOGIN NO FIREBASE AUTH
      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final user = userCredential.user;
      if (user == null) {
        setState(() {
          errorMsg = "Erro inesperado. Tente novamente!";
          loading = false;
        });
        return;
      }

      // BUSCA O DOC EM users/<uid>
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        setState(() {
          errorMsg = "Usuário não cadastrado na base de dados!";
          loading = false;
        });
        return;
      }

      final data = userDoc.data() ?? {};
      final isAdmin = data['isAdmin'] == true; // garante bool
      final nome = data['nome'] ?? (user.displayName ?? '');
      final emailUser = data['email'] ?? (user.email ?? '');

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      if (isAdmin) {
        // ADMIN
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminScreen(
              nome: nome,
              email: emailUser,
              onToggleTheme: widget.onToggleTheme,
              darkMode: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        );
      } else {
        // USUÁRIO NORMAL
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EventosScreen(
              onToggleTheme: widget.onToggleTheme,
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = _traduzErroFirebase(e);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMsg = "Erro ao fazer login. Tente novamente.";
        loading = false;
      });
    }
  }
}
