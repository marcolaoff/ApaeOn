import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'login_screen.dart';

class PerfilUsuarioScreen extends StatefulWidget {
  final void Function(bool)? onToggleTheme;

  const PerfilUsuarioScreen({
    super.key,
    this.onToggleTheme,
  });

  @override
  State<PerfilUsuarioScreen> createState() => _PerfilUsuarioScreenState();
}

class _PerfilUsuarioScreenState extends State<PerfilUsuarioScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();

  bool loading = true;
  String? fotoUrl;
  bool alterandoFoto = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    setState(() => loading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      _nomeController.text = doc.data()?['nome'] ?? '';
      _emailController.text = user.email ?? '';
      fotoUrl = doc.data()?['fotoUrl'];
    }
    setState(() => loading = false);
  }

  Future<void> _editarCampo(String campo, String valorAtual) async {
    final controller = TextEditingController(text: valorAtual);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${campo == "nome" ? "Nome" : "Email"}'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: campo == "nome" ? "Nome do Usuário" : "Email",
          ),
          keyboardType: campo == "email" ? TextInputType.emailAddress : TextInputType.text,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (ok == true) {
      if (campo == "nome") {
        await _salvarNomeModal(controller.text);
      } else {
        await _salvarEmailModal(controller.text);
      }
    }
  }

  Future<void> _salvarNomeModal(String nomeNovo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'nome': nomeNovo.trim(),
    });
    setState(() => _nomeController.text = nomeNovo.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nome atualizado!")),
    );
  }

  Future<void> _salvarEmailModal(String emailNovo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await user.updateEmail(emailNovo.trim());
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'email': emailNovo.trim(),
      });
      setState(() => _emailController.text = emailNovo.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email atualizado!")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar email: ${e.message}")),
      );
    }
  }

  Future<void> _alterarFoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => alterandoFoto = true);

    try {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref('usuarios/${user.uid}/foto.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'fotoUrl': url,
      });
      setState(() {
        fotoUrl = url;
        alterandoFoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto atualizada!")),
      );
    } catch (e) {
      setState(() => alterandoFoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar foto: $e")),
      );
    }
  }

  Future<void> _apagarConta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final uid = user.uid;
    try {
      final ingressosSnap = await FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in ingressosSnap.docs) {
        await doc.reference.delete();
      }
      final fotoRef = FirebaseStorage.instance.ref('usuarios/$uid/foto.jpg');
      try {
        await fotoRef.delete();
      } catch (_) {}
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      await user.delete();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginScreen(
              onToggleTheme: widget.onToggleTheme,
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil de Usuário',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
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
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
                        backgroundImage: (fotoUrl != null && fotoUrl!.isNotEmpty)
                            ? NetworkImage(fotoUrl!)
                            : null,
                        child: (fotoUrl == null || fotoUrl!.isEmpty)
                            ? Icon(Icons.person, size: 60, color: isDark ? Colors.white24 : Colors.grey)
                            : null,
                      ),
                      if (alterandoFoto)
                        const Positioned.fill(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: isDark ? Colors.white12 : Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            onPressed: alterandoFoto ? null : _alterarFoto,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _nomeController,
                    readOnly: true,
                    enableInteractiveSelection: false,
                    decoration: InputDecoration(
                      labelText: "Nome do Usuário",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarCampo("nome", _nomeController.text),
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey,
                        ),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                    ),
                    style: TextStyle(color: textColor),
                  ),
                  const SizedBox(height: 22),

                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    enableInteractiveSelection: false,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarCampo("email", _emailController.text),
                        color: isDark ? Colors.white : Colors.black,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey,
                        ),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                    ),
                    style: TextStyle(color: textColor),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: 160,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cardColor,
                        foregroundColor: Colors.red,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final confirmar = await showDialog<bool>(
                          context: context,
                          builder: (context) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: Colors.red,
                                    surface: cardColor,
                                  ), dialogTheme: DialogThemeData(backgroundColor: cardColor),
                            ),
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              title: Text(
                                'Confirmar Exclusão',
                                style: TextStyle(
                                  color: textColor,
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
                                    foregroundColor: isDark ? Colors.white70 : Colors.black,
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
