import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;

  const RegisterScreen({
    super.key,
    this.onToggleTheme,
    this.darkMode = false,
  });

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

  /// Traduz erros do Firebase de cadastro para mensagens em PT-BR
  String _traduzErroCadastro(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso. Tente fazer login ou use outro e-mail.';
      case 'invalid-email':
        return 'E-mail inválido. Verifique o formato (ex: usuario@dominio.com).';
      case 'weak-password':
        return 'A senha é muito fraca. Use pelo menos 6 caracteres.';
      case 'operation-not-allowed':
        return 'Cadastro com e-mail/senha não está habilitado no momento.';
      case 'network-request-failed':
        return 'Falha de conexão. Verifique sua internet e tente novamente.';
      default:
        return 'Erro ao registrar. Tente novamente em instantes.';
    }
  }

  @override
  void dispose() {
    cpfController.dispose();
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    super.dispose();
  }

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

                    // CPF
                    TextField(
                      controller: cpfController,
                      decoration: InputDecoration(
                        labelText: 'Digite seu CPF',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[900] : Colors.white,
                        isDense: true,
                        counterText: '',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 18),

                    // Nome
                    TextField(
                      controller: nomeController,
                      decoration: InputDecoration(
                        labelText: 'Digite seu Nome',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
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

                    // Email
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Digite seu Email',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
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

                    // Senha
                    TextField(
                      controller: senhaController,
                      decoration: InputDecoration(
                        labelText: 'Digite sua Senha',
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
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
                        child: Text(
                          errorMsg!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    SizedBox(
                      width: 120,
                      height: 36,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor:
                              isDark ? Colors.white : Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: loading ? null : register,
                        child: loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
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
  final cpf = cpfController.text.trim();
  final nome = nomeController.text.trim();
  final email = emailController.text.trim();
  final senha = senhaController.text;

  // ===== VALIDAÇÕES LOCAIS =====
  if (cpf.isEmpty || nome.isEmpty || email.isEmpty || senha.isEmpty) {
    if (!mounted) return;
    setState(() {
      errorMsg = "Preencha todos os campos.";
    });
    return;
  }

  if (cpf.length != 11) {
    if (!mounted) return;
    setState(() {
      errorMsg = "CPF inválido. Digite os 11 números do CPF (somente dígitos).";
    });
    return;
  }

  if (!email.contains('@') || !email.contains('.')) {
    if (!mounted) return;
    setState(() {
      errorMsg = "Digite um e-mail válido.";
    });
    return;
  }

  if (senha.length < 6) {
    if (!mounted) return;
    setState(() {
      errorMsg = "A senha deve ter pelo menos 6 caracteres.";
    });
    return;
  }

  if (!mounted) return;
  setState(() {
    loading = true;
    errorMsg = null;
  });

  try {
    // ========== 1) CRIAR USUÁRIO NO AUTH ==========
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final user = credential.user;
    final uid = user?.uid;

    if (uid == null) {
      if (!mounted) return;
      setState(() {
        errorMsg = "Erro desconhecido ao registrar usuário (UID nulo).";
        loading = false;
      });
      return;
    }

    // Tenta atualizar o displayName (não é obrigatório para funcionar)
    try {
      await user!.updateDisplayName(nome);
      await user.reload();
    } catch (e) {
      // Aqui só fazemos log, não quebramos o fluxo
      // print('Erro ao atualizar displayName: $e');
    }

    // ========== 2) SALVAR DADOS NO FIRESTORE ==========
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'cpf': cpf,
        'nome': nome,
        'email': email,
        'isAdmin': false,
        'darkMode': widget.darkMode, // mantém alinhado com o tema atual
      });
    } catch (e) {
      // Se der erro aqui, o usuário foi criado no Auth, mas não no Firestore
      if (!mounted) return;
      setState(() {
        errorMsg =
            "Usuário criado, mas houve erro ao salvar os dados no banco. Verifique as regras do Firestore.";
        loading = false;
      });
      return;
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    // Fecha a tela e volta para o login
    Navigator.of(context).pop();
  } on FirebaseAuthException catch (e) {
    if (!mounted) return;
    setState(() {
      errorMsg = _traduzErroCadastro(e);
      loading = false;
    });
  } catch (e) {
    if (!mounted) return;
    setState(() {
      errorMsg = "Erro inesperado. Tente novamente.\n\nDetalhe: $e";
      loading = false;
    });
  }
}
}
