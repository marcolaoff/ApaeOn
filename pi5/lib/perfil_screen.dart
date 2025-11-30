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

  int _totalIngressos = 0;
  int _ingressosAtivos = 0;

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
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Dados básicos
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        final data = doc.data() as Map<String, dynamic>?;

        // Nome: prioridade Firestore -> displayName -> vazio
        String nome = '';
        if (data != null &&
            data['nome'] != null &&
            data['nome'].toString().trim().isNotEmpty) {
          nome = data['nome'].toString().trim();
        } else if (user.displayName != null &&
            user.displayName!.trim().isNotEmpty) {
          nome = user.displayName!.trim();
        }

        // E-mail: prioridade Firestore -> auth
        String email = '';
        if (data != null &&
            data['email'] != null &&
            data['email'].toString().trim().isNotEmpty) {
          email = data['email'].toString().trim();
        } else {
          email = user.email ?? '';
        }

        // Foto: prioridade Firestore -> auth
        String? foto;
        if (data != null &&
            data['fotoUrl'] != null &&
            data['fotoUrl'].toString().trim().isNotEmpty) {
          foto = data['fotoUrl'].toString().trim();
        } else {
          foto = user.photoURL;
        }

        _nomeController.text = nome;
        _emailController.text = email;
        fotoUrl = foto;

        // Estatísticas de ingressos
        final ingressosSnap = await FirebaseFirestore.instance
            .collection('tickets')
            .where('userId', isEqualTo: user.uid)
            .get();

        int ativos = 0;
        for (final t in ingressosSnap.docs) {
          final dataTicket = t.data() as Map<String, dynamic>;
          if ((dataTicket['status'] ?? '').toString().toLowerCase() == 'ativo') {
            ativos++;
          }
        }

        _totalIngressos = ingressosSnap.docs.length;
        _ingressosAtivos = ativos;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar perfil.'),
        ),
      );
    }
    setState(() => loading = false);
  }

  Future<void> _editarCampo(String campo, String valorAtual) async {
    final controller = TextEditingController(text: valorAtual);

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${campo == "nome" ? "nome" : "e-mail"}'),
        content: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: campo == "nome" ? "Nome completo" : "E-mail",
          ),
          keyboardType:
              campo == "email" ? TextInputType.emailAddress : TextInputType.text,
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

    final nomeFormatado = nomeNovo.trim();
    if (nomeFormatado.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O nome não pode ficar em branco.")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'nome': nomeFormatado,
    });

    // Atualiza também no perfil do FirebaseAuth
    await user.updateDisplayName(nomeFormatado);
    await user.reload();

    setState(() => _nomeController.text = nomeFormatado);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Nome atualizado com sucesso!")),
    );
  }

  Future<void> _salvarEmailModal(String emailNovo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final emailFormatado = emailNovo.trim();
      await user.updateEmail(emailFormatado);
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'email': emailFormatado,
      });
      await user.reload();
      setState(() => _emailController.text = emailFormatado);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("E-mail atualizado com sucesso!")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar e-mail: ${e.message}")),
      );
    }
  }

  Future<void> _alterarFoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked == null) return;

    setState(() => alterandoFoto = true);

    try {
      final file = File(picked.path);
      final ref = FirebaseStorage.instance.ref('usuarios/${user.uid}/foto.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fotoUrl': url,
      });

      // Atualiza também no perfil do FirebaseAuth
      await user.updatePhotoURL(url);
      await user.reload(); // garante que currentUser fique atualizado

      setState(() {
        fotoUrl = url;
        alterandoFoto = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto de perfil atualizada!")),
      );
    } catch (e) {
      setState(() => alterandoFoto = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao atualizar foto de perfil: $e")),
      );
    }
  }

  /// Pede a senha novamente e reautentica o usuário antes de operações sensíveis
  Future<bool> _reautenticarUsuario(User user) async {
    final email = user.email;
    if (email == null || email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível obter o e-mail para reautenticação.'),
        ),
      );
      return false;
    }

    final senhaController = TextEditingController();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar senha'),
          content: TextField(
            controller: senhaController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Digite novamente sua senha',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true) return false;

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: senhaController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      return true;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'wrong-password'
                ? 'Senha incorreta. Tente novamente.'
                : 'Erro na reautenticação: ${e.message}',
          ),
        ),
      );
      return false;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro inesperado na reautenticação: $e'),
        ),
      );
      return false;
    }
  }

  Future<void> _apagarConta() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final uid = user.uid;

    // 1) Reautenticar antes de apagar
    final ok = await _reautenticarUsuario(user);
    if (!ok) {
      // Usuário cancelou ou falhou a reautenticação
      return;
    }

    try {
      // 2) Apagar ingressos do usuário
      final ingressosSnap = await FirebaseFirestore.instance
          .collection('tickets')
          .where('userId', isEqualTo: uid)
          .get();
      for (final doc in ingressosSnap.docs) {
        await doc.reference.delete();
      }

      // 3) Apagar foto de perfil do Storage (se existir)
      final fotoRef = FirebaseStorage.instance.ref('usuarios/$uid/foto.jpg');
      try {
        await fotoRef.delete();
      } catch (_) {
        // Se não existir, ignora
      }

      // 4) Apagar documento do usuário em "users"
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // 5) Apagar usuário do Auth
      await user.delete();

      if (!mounted) return;

      // 6) Voltar para tela de login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onToggleTheme: widget.onToggleTheme,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'requires-recent-login') {
        msg =
            'Por segurança, faça login novamente e tente apagar a conta mais uma vez.';
      } else {
        msg = 'Erro ao apagar a conta: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao apagar a conta: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final textSecondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Meu perfil',
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
          : RefreshIndicator(
              onRefresh: _loadUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    // FOTO
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor:
                              isDark ? Colors.grey[700] : Colors.grey[300],
                          backgroundImage: (fotoUrl != null &&
                                  fotoUrl!.isNotEmpty)
                              ? NetworkImage(fotoUrl!)
                              : null,
                          child: (fotoUrl == null || fotoUrl!.isEmpty)
                              ? Icon(Icons.person,
                                  size: 60,
                                  color:
                                      isDark ? Colors.white24 : Colors.grey)
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
                            backgroundColor:
                                isDark ? Colors.white12 : Colors.black54,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                              onPressed: alterandoFoto ? null : _alterarFoto,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // NOME
                    TextField(
                      controller: _nomeController,
                      readOnly: true,
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        labelText: "Nome completo",
                        labelStyle: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.black87),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _editarCampo("nome", _nomeController.text),
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
                        fillColor:
                            isDark ? Colors.grey[900] : Colors.white,
                      ),
                      style: TextStyle(color: textColor),
                    ),
                    const SizedBox(height: 22),

                    // EMAIL
                    TextField(
                      controller: _emailController,
                      readOnly: true,
                      enableInteractiveSelection: false,
                      decoration: InputDecoration(
                        labelText: "E-mail",
                        labelStyle: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : Colors.black87),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () =>
                              _editarCampo("email", _emailController.text),
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
                        fillColor:
                            isDark ? Colors.grey[900] : Colors.white,
                      ),
                      style: TextStyle(color: textColor),
                    ),

                    const SizedBox(height: 28),

                    // ====== CARDS DE ESTATÍSTICAS ======
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Resumo da conta",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            color: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total de ingressos",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_totalIngressos',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Card(
                            color: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 12),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ingressos ativos",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_ingressosAtivos',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // BOTÃO APAGAR CONTA
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor: Colors.red,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          side: BorderSide(
                            color:
                                isDark ? Colors.white12 : Colors.black12,
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => Theme(
                              data: Theme.of(context).copyWith(
                                dialogBackgroundColor: cardColor,
                                colorScheme: Theme.of(context)
                                    .colorScheme
                                    .copyWith(
                                      primary: Colors.red,
                                      surface: cardColor,
                                    ),
                              ),
                              child: AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(18)),
                                title: Text(
                                  'Confirmar exclusão da conta',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  'Tem certeza de que deseja apagar sua conta? Esta ação não pode ser desfeita.',
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: isDark
                                          ? Colors.white70
                                          : Colors.black,
                                    ),
                                    child: const Text('Cancelar'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                    child: const Text('Apagar conta'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              ),
                            ),
                          );
                          if (confirmar == true) _apagarConta();
                        },
                        child: const Text(
                          'Apagar conta',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
