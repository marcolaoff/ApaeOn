import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // Importe sua tela de login aqui

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
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  bool loading = true;
  bool editandoNome = false;
  bool editandoEmail = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _nomeController.text = doc.data()?['nome'] ?? '';
      _emailController.text = user.email ?? '';
    }
    setState(() => loading = false);
  }

  Future<void> _salvarNome() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'nome': _nomeController.text.trim(),
    });
    setState(() => editandoNome = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nome atualizado!")),
    );
  }

  Future<void> _salvarEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.updateEmail(_emailController.text.trim());
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'email': _emailController.text.trim(),
      });
      setState(() => editandoEmail = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atualizado!")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar email: ${e.message}")),
      );
    }
  }

  Future<void> _apagarConta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await user.delete();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              onToggleTheme: widget.onToggleTheme,
              darkMode: widget.darkMode,
            ),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao apagar conta: $e")),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
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

                  // Nome - campo editável
                  TextField(
                    controller: _nomeController,
                    decoration: InputDecoration(
                      labelText: "Nome do Usuário",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                      suffixIcon: editandoNome
                          ? IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _salvarNome,
                              color: Colors.green,
                            )
                          : IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => setState(() => editandoNome = true),
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    enabled: editandoNome,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 22),

                  // Email - campo editável
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                      suffixIcon: editandoEmail
                          ? IconButton(
                              icon: const Icon(Icons.save),
                              onPressed: _salvarEmail,
                              color: Colors.green,
                            )
                          : IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => setState(() => editandoEmail = true),
                              color: isDark ? Colors.white : Colors.black,
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                    ),
                    enabled: editandoEmail,
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
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => Theme(
                            data: Theme.of(context).copyWith(
                              dialogBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: Colors.red,
                                    surface: Theme.of(context).scaffoldBackgroundColor,
                                  ),
                            ),
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              title: Text(
                                'Confirmar Exclusão',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                'Tem certeza que deseja apagar sua conta? Esta ação não pode ser desfeita.',
                                style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Apagar'),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          ),
                        );
                        if (confirmar == true) _apagarConta();
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
