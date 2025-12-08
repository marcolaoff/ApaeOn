import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'tela_lerqrcode.dart';
import 'login_screen.dart';
import 'perfil_screen.dart';
import 'relatorio_pdf.dart';
import 'sobre_apae_screen.dart';
import 'package:printing/printing.dart';


class AdminScreen extends StatefulWidget {
  final String nome;
  final String email;

  /// callback global de tema, vindo do main
  final void Function(bool)? onToggleTheme;

  /// estado atual do tema (pra deixar o switch alinhado)
  final bool darkMode;

  const AdminScreen({
    super.key,
    required this.nome,
    required this.email,
    this.onToggleTheme,
    this.darkMode = false,
  });

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Gerenciar Eventos';
      case 1:
        return 'Validar Ingressos';
      case 2:
        return 'Relatório';
      case 3:
        return 'Configurações';
      default:
        return 'Admin ApaeOn';
    }
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => LoginScreen(onToggleTheme: widget.onToggleTheme),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final scaffoldBg = theme.scaffoldBackgroundColor;
    final appBarBg = theme.appBarTheme.backgroundColor ?? scaffoldBg;

    final currentUser = FirebaseAuth.instance.currentUser;

    // 🔹 Evita null na displayName/email e deixa legível
    final adminName = (currentUser?.displayName ?? '').trim();
    final adminEmail = (currentUser?.email ?? '').trim();

    Widget body;
    switch (_selectedIndex) {
      case 0:
        body = const GerenciarEventosTab();
        break;
      case 1:
        body = const ValidarIngressosTab();
        break;
      case 2:
        body = const RelatorioTab();
        break;
      case 3:
      default:
        body = AdminConfiguracoesTab(
          onToggleTheme: widget.onToggleTheme,
        );
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title,
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: appBarBg,
        elevation: 0,
        iconTheme: theme.appBarTheme.iconTheme ??
            IconThemeData(
              color: textColor,
            ),
      ),
      drawer: Drawer(
        backgroundColor: theme.drawerTheme.backgroundColor ?? scaffoldBg,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // ====== CABEÇALHO COM USUÁRIO ADMIN ======
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: appBarBg,
              ),
              accountName: Text(
                adminName.isNotEmpty ? adminName : 'Administrador',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              accountEmail: Text(
                adminEmail.isNotEmpty ? adminEmail : 'Sem e-mail cadastrado',
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                ),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: (currentUser?.photoURL != null &&
                          currentUser!.photoURL!.trim().isNotEmpty)
                      ? Image.network(
                          currentUser.photoURL!.trim(),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Icon(
                              Icons.person,
                              size: 40,
                              color: isDark ? Colors.white : Colors.black54,
                            );
                          },
                        )
                      : Icon(
                          Icons.person,
                          size: 40,
                          color: isDark ? Colors.white : Colors.black54,
                        ),
                ),
              ),
            ),

            // Gerenciar Eventos
            ListTile(
              leading: Icon(Icons.event, color: textColor),
              title: Text('Gerenciar Eventos', style: TextStyle(color: textColor)),
              selected: _selectedIndex == 0,
              selectedTileColor:
                  isDark ? Colors.white12 : Colors.deepPurple.withOpacity(0.06),
              onTap: () {
                Navigator.pop(context);
                _selectPage(0);
              },
            ),

            // Validar Ingressos
            ListTile(
              leading: Icon(Icons.qr_code_scanner, color: textColor),
              title: Text('Validar Ingressos', style: TextStyle(color: textColor)),
              selected: _selectedIndex == 1,
              selectedTileColor:
                  isDark ? Colors.white12 : Colors.deepPurple.withOpacity(0.06),
              onTap: () {
                Navigator.pop(context);
                _selectPage(1);
              },
            ),

            // Relatório
            ListTile(
              leading: Icon(Icons.bar_chart, color: textColor),
              title: Text('Relatório', style: TextStyle(color: textColor)),
              selected: _selectedIndex == 2,
              selectedTileColor:
                  isDark ? Colors.white12 : Colors.deepPurple.withOpacity(0.06),
              onTap: () {
                Navigator.pop(context);
                _selectPage(2);
              },
            ),

            // Configurações
            ListTile(
              leading: Icon(Icons.settings, color: textColor),
              title: Text('Configurações', style: TextStyle(color: textColor)),
              selected: _selectedIndex == 3,
              selectedTileColor:
                  isDark ? Colors.white12 : Colors.deepPurple.withOpacity(0.06),
              onTap: () {
                Navigator.pop(context);
                _selectPage(3);
              },
            ),

            const Divider(),

            // Sair
            ListTile(
              leading: const Icon(
                Icons.exit_to_app,
                color: Colors.red,
              ),
              title: const Text(
                'Sair',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _logout(context);
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}

// =====================================================================
// GERENCIAR EVENTOS
// =====================================================================

class GerenciarEventosTab extends StatefulWidget {
  const GerenciarEventosTab({super.key});

  @override
  State<GerenciarEventosTab> createState() => _GerenciarEventosTabState();
}

class _GerenciarEventosTabState extends State<GerenciarEventosTab> {
  Future<String> uploadImageAndGetUrl(XFile imageFile, String fileName) async {
    final storageRef = FirebaseStorage.instance.ref().child('eventos/$fileName');
    await storageRef.putFile(File(imageFile.path));
    return await storageRef.getDownloadURL();
  }

  Future<void> _abrirFormularioEvento({DocumentSnapshot? doc}) async {
    final formKey = GlobalKey<FormState>();
    final dataMap = doc?.data() as Map<String, dynamic>?;

    String nome = dataMap?['nome']?.toString() ?? '';
    String descricao = dataMap?['descrição']?.toString() ?? '';
    String informacoesAdicionais =
        dataMap?['Informações Adicionais']?.toString() ?? '';
    String imageUrl = dataMap?['imageUrl']?.toString() ?? '';
    String local = dataMap?['local']?.toString() ?? '';
    String status = dataMap?['status']?.toString() ?? 'ativo';

    double preco = 0.0;
    if (dataMap != null && dataMap['preco'] != null) {
      if (dataMap['preco'] is num) {
        preco = (dataMap['preco'] as num).toDouble();
      } else {
        preco = double.tryParse(dataMap['preco'].toString()) ?? 0.0;
      }
    }

    DateTime? data = (dataMap?['data'] is Timestamp)
        ? (dataMap!['data'] as Timestamp).toDate()
        : null;
    XFile? novaImagem;
    bool carregandoLocal = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final isDark = theme.brightness == Brightness.dark;
        final textColor =
            theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);

        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                doc == null ? 'Adicionar Evento' : 'Editar Evento',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              content: SizedBox(
                width: 340,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // IMAGEM
                        GestureDetector(
                          onTap: carregandoLocal
                              ? null
                              : () async {
                                  final picker = ImagePicker();
                                  final picked = await picker.pickImage(
                                    source: ImageSource.gallery,
                                    imageQuality: 70,
                                  );
                                  if (picked != null) {
                                    setModal(() {
                                      novaImagem = picked;
                                    });
                                  }
                                },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.grey.shade400,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: novaImagem != null
                                    ? ClipOval(
                                        child: Image.file(
                                          File(novaImagem!.path),
                                          fit: BoxFit.cover,
                                          height: 110,
                                          width: 110,
                                        ),
                                      )
                                    : (imageUrl.isNotEmpty
                                        ? ClipOval(
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                              height: 110,
                                              width: 110,
                                            ),
                                          )
                                        : Icon(
                                            Icons.camera_alt,
                                            size: 48,
                                            color: isDark
                                                ? Colors.white54
                                                : Colors.grey,
                                          )),
                              ),
                              if (carregandoLocal)
                                const CircularProgressIndicator(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // NOME
                        TextFormField(
                          initialValue: nome,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Nome do Evento',
                          ),
                          onChanged: (v) => nome = v,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                        ),
                        const SizedBox(height: 8),

                        // DESCRIÇÃO
                        TextFormField(
                          initialValue: descricao,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(labelText: 'Descrição'),
                          onChanged: (v) => descricao = v,
                          maxLines: 2,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Informe a descrição'
                              : null,
                        ),
                        const SizedBox(height: 8),

                        // INFORMAÇÕES ADICIONAIS
                        TextFormField(
                          initialValue: informacoesAdicionais,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                              labelText: 'Informações Adicionais'),
                          onChanged: (v) => informacoesAdicionais = v,
                          maxLines: 3,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Informe as informações adicionais'
                              : null,
                        ),
                        const SizedBox(height: 8),

                        // LOCAL
                        TextFormField(
                          initialValue: local,
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(labelText: 'Local'),
                          onChanged: (v) => local = v,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Informe o local' : null,
                        ),
                        const SizedBox(height: 8),

                        // PREÇO
                        TextFormField(
                          initialValue: preco > 0 ? preco.toStringAsFixed(2) : '',
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(labelText: 'Preço'),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9\.,]')),
                          ],
                          onChanged: (v) {
                            v = v.replaceAll(',', '.');
                            final parsed = double.tryParse(v);
                            if (parsed != null) {
                              preco = parsed;
                            }
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe o preço';
                            }
                            final normalizado = v.replaceAll(',', '.');
                            final parsed = double.tryParse(normalizado);
                            if (parsed == null) {
                              return 'Digite um valor numérico válido';
                            }
                            if (parsed <= 0) {
                              return 'O preço deve ser maior que zero';
                            }
                            final reg = RegExp(r'^\d+([.,]\d{1,2})?$');
                            if (!reg.hasMatch(v.trim())) {
                              return 'Use no máximo 2 casas decimais';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // STATUS
                        DropdownButtonFormField<String>(
                          value: status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: const [
                            DropdownMenuItem(value: 'ativo', child: Text('Ativo')),
                            DropdownMenuItem(value: 'inativo', child: Text('Inativo')),
                          ],
                          onChanged: (v) => status = v ?? 'ativo',
                        ),
                        const SizedBox(height: 8),

                        // DATA
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            data == null
                                ? 'Escolha a data do evento'
                                : 'Data: ${data!.day.toString().padLeft(2, '0')}/'
                                    '${data!.month.toString().padLeft(2, '0')}/'
                                    '${data!.year} às '
                                    '${data!.hour.toString().padLeft(2, '0')}:'
                                    '${data!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(color: textColor),
                          ),
                          trailing: Icon(
                            Icons.date_range,
                            color: textColor,
                          ),
                          onTap: carregandoLocal
                              ? null
                              : () async {
                                  final d = await showDatePicker(
                                    context: context,
                                    initialDate: data ?? DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2100),
                                  );
                                  if (d != null) {
                                    final t = await showTimePicker(
                                      context: context,
                                      initialTime: data != null
                                          ? TimeOfDay(
                                              hour: data!.hour,
                                              minute: data!.minute,
                                            )
                                          : const TimeOfDay(hour: 19, minute: 0),
                                    );
                                    if (t != null) {
                                      setModal(() {
                                        data = DateTime(
                                          d.year,
                                          d.month,
                                          d.day,
                                          t.hour,
                                          t.minute,
                                        );
                                      });
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                // CANCELAR
                TextButton(
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: carregandoLocal ? null : () => Navigator.pop(context),
                ),

                // ADICIONAR / SALVAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(doc == null ? 'Adicionar' : 'Salvar'),
                  onPressed: carregandoLocal
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setModal(() => carregandoLocal = true);

                          String url = imageUrl;
                          if (novaImagem != null) {
                            url = await uploadImageAndGetUrl(
                              novaImagem!,
                              '${nome}_${DateTime.now().millisecondsSinceEpoch}.jpg',
                            );
                          }

                          final eventoData = {
                            'nome': nome,
                            'descrição': descricao,
                            'local': local,
                            'preco': preco,
                            'status': status,
                            'data':
                                data != null ? Timestamp.fromDate(data!) : null,
                            'imageUrl': url,
                            'Informações Adicionais': informacoesAdicionais,
                          };

                          if (doc == null) {
                            await FirebaseFirestore.instance
                                .collection('events')
                                .add(eventoData);
                          } else {
                            await doc.reference.update(eventoData);
                          }

                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  doc == null
                                      ? 'Evento criado com sucesso!'
                                      : 'Evento atualizado com sucesso!',
                                ),
                              ),
                            );
                          }
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _removerEvento(DocumentSnapshot doc) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Evento'),
        content: const Text(
          'Tem certeza que deseja remover este evento? '
          'Todos os ingressos desse evento também serão apagados!',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Remover'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final batch = FirebaseFirestore.instance.batch();

      final ticketsQuery = await FirebaseFirestore.instance
          .collection('tickets')
          .where('eventId', isEqualTo: doc.id)
          .get();

      for (final ticketDoc in ticketsQuery.docs) {
        batch.delete(ticketDoc.reference);
      }

      batch.delete(doc.reference);
      await batch.commit();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evento e todos os ingressos removidos!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final cardColor = theme.cardColor;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        label: const Text('Adicionar Evento'),
        icon: const Icon(Icons.add),
        onPressed: () => _abrirFormularioEvento(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('events')
            .orderBy('data')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Nenhum evento cadastrado.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final Map<String, dynamic> evento;
              try {
                evento = docs[i].data() as Map<String, dynamic>;
              } catch (e) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Evento inválido/corrompido!',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }

              final nome = evento['nome'] ?? 'Sem nome';
              final descricao = evento['descrição'] ?? '';
              final imageUrl = evento['imageUrl'] ?? '';
              String dataFormatada = '';
              if (evento['data'] != null && evento['data'] is Timestamp) {
                final date = (evento['data'] as Timestamp).toDate();
                dataFormatada =
                    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}'
                    ' às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              }

              return Card(
                elevation: 2,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 18),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor:
                                isDark ? Colors.white12 : Colors.black12,
                            child: const Icon(
                              Icons.event,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nome,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (dataFormatada.isNotEmpty)
                                  Text(
                                    'Data: $dataFormatada',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white60
                                          : Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Imagem
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imageUrl.toString().isNotEmpty
                            ? Image.network(
                                imageUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 120,
                                  width: double.infinity,
                                  color: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Container(
                                height: 120,
                                width: double.infinity,
                                color: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 48,
                                  color: Colors.grey,
                                ),
                              ),
                      ),

                      const SizedBox(height: 14),

                      // Descrição
                      if (descricao.toString().isNotEmpty)
                        Text(
                          descricao,
                          style: TextStyle(
                            fontSize: 14,
                            color: textColor,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Botões
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.white60
                                    : Colors.black54,
                              ),
                              foregroundColor: textColor,
                            ),
                            onPressed: () =>
                                _abrirFormularioEvento(doc: docs[i]),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: isDark
                                    ? Colors.red[300]!
                                    : Colors.red,
                              ),
                              foregroundColor:
                                  isDark ? Colors.red[300] : Colors.red,
                            ),
                            onPressed: () => _removerEvento(docs[i]),
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Excluir'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================================
// RELATÓRIO
// =====================================================================

class RelatorioTab extends StatefulWidget {
  const RelatorioTab({super.key});

  @override
  State<RelatorioTab> createState() => _RelatorioTabState();
}

class _RelatorioTabState extends State<RelatorioTab> {
  bool carregando = false;
  String? erro;
  Map<String, dynamic>? relatorio;

  Future<void> _gerarRelatorioLocal() async {
    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      // Buscar todos os eventos
      final eventosSnap =
      await FirebaseFirestore.instance.collection("events").get();

      List eventos = [];
      double totalGeral = 0;

      for (var doc in eventosSnap.docs) {
        final data = doc.data();
        final eventId = doc.id;

        final preco = (data["preco"] ?? 0).toDouble();

        // Buscar ingressos vendidos
        final ticketsSnap = await FirebaseFirestore.instance
            .collection("tickets")
            .where("eventId", isEqualTo: eventId)
            .get();

        final vendidos = ticketsSnap.docs.length;

        // Se existir campo total no evento
        final total = data["total"] ?? vendidos;
        final naoVendidos = total - vendidos;

        final arrecadado = vendidos * preco;
        totalGeral += arrecadado;

        eventos.add({
          "evento": data["nome"] ?? "Evento sem nome",
          "vendidos": vendidos,
          "nao_vendidos": naoVendidos,
          "arrecadado": arrecadado,
        });
      }

      setState(() {
        relatorio = {
          "eventos": eventos,
          "total_geral": totalGeral,
        };
      });
    } catch (e) {
      setState(() {
        erro = "Erro ao gerar relatório: $e";
      });
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _gerarRelatorioLocal();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : erro != null
          ? Center(
        child: Text(
          erro!,
          style: const TextStyle(color: Colors.red),
        ),
      )
          : relatorio == null
          ? const Center(child: Text("Nenhum relatório encontrado."))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Relatório Geral de Eventos",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),

            // Lista de eventos
            Expanded(
              child: ListView.builder(
                itemCount: relatorio!["eventos"].length,
                itemBuilder: (context, index) {
                  final e = relatorio!["eventos"][index];
                  return Card(
                    margin:
                    const EdgeInsets.only(bottom: 14),
                    child: ListTile(
                      title: Text(
                        e["evento"],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "Vendidos: ${e['vendidos']} | "
                            "Não vendidos: ${e['nao_vendidos']}\n"
                            "Arrecadado: R\$ ${e['arrecadado'].toStringAsFixed(2)}",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Total geral
            Text(
              "Total geral arrecadado: R\$ ${relatorio!['total_geral'].toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 20),

            // Botão PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Gerar PDF"),
                onPressed: () async {
                  final pdf = await RelatorioPDF.gerarPDF(relatorio!);
                  await Printing.layoutPdf(
                    onLayout: (_) async => pdf,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Atualizar
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Atualizar"),
                onPressed: _gerarRelatorioLocal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// =====================================================================
// VALIDAR INGRESSOS
// =====================================================================

class ValidarIngressosTab extends StatelessWidget {
  const ValidarIngressosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TelaQRCode();
  }
}

// =====================================================================
// CONFIGURAÇÕES DO ADMIN
// =====================================================================

class AdminConfiguracoesTab extends StatelessWidget {
  final void Function(bool)? onToggleTheme;

  const AdminConfiguracoesTab({super.key, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 36, left: 18, right: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MODO ESCURO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "MODO ESCURO",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textColor,
                    ),
                  ),
                  Switch(
                    value: isDark,
                    activeColor: Colors.black,
                    onChanged: (val) {
                      if (onToggleTheme != null) {
                        onToggleTheme!(val);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // PERFIL USUÁRIO
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PerfilUsuarioScreen(
                        onToggleTheme: onToggleTheme,
                      ),
                    ),
                  );
                },
                child: Text(
                  "PERFIL USUARIO",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // SOBRE A APAE
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SobreApaeScreen(),
                    ),
                  );
                },
                child: Text(
                  "SOBRE A APAE",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // LOCALIZAÇÃO
              GestureDetector(
                onTap: () async {
                  const url =
                      'https://www.google.com/maps/search/?api=1&query=-22.424345194559244,-46.81835773070385';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "LOCALIZAÇÃO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
