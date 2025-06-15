import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_lerqrcode.dart'; // Ajuste para seu caminho

class AdminScreen extends StatelessWidget {
  final String nome;
  final String email;

  const AdminScreen({super.key, required this.nome, required this.email});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Painel do Administrador', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Gerenciar Eventos'),
              Tab(text: 'Validar Ingressos'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            GerenciarEventosTab(),
            ValidarIngressosTab(),
            AdminConfiguracoesTab(),
          ],
        ),
      ),
    );
  }
}

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
  String informacoesAdicionais = dataMap?['Informações Adicionais']?.toString() ?? '';
  String imageUrl = dataMap?['imageUrl']?.toString() ?? '';
  String local = dataMap?['local']?.toString() ?? '';
  int preco = int.tryParse(dataMap?['preco']?.toString() ?? '') ?? 0;
  String status = dataMap?['status']?.toString() ?? 'ativo';
  DateTime? data = (dataMap?['data'] is Timestamp)
      ? (dataMap!['data'] as Timestamp).toDate()
      : null;
  XFile? novaImagem;
  bool carregandoLocal = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setModal) => AlertDialog(
          title: Text(doc == null ? 'Adicionar Evento' : 'Editar Evento'),
          content: SizedBox(
            width: 340,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: carregandoLocal
                          ? null
                          : () async {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
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
                              border: Border.all(color: Colors.grey.shade400),
                              shape: BoxShape.circle,
                            ),
                            child: novaImagem != null
                                ? ClipOval(child: Image.file(File(novaImagem!.path), fit: BoxFit.cover, height: 110, width: 110))
                                : (imageUrl.isNotEmpty
                                    ? ClipOval(child: Image.network(imageUrl, fit: BoxFit.cover, height: 110, width: 110))
                                    : const Icon(Icons.camera_alt, size: 48, color: Colors.grey)),
                          ),
                          if (carregandoLocal) const CircularProgressIndicator(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: nome,
                      decoration: const InputDecoration(labelText: 'Nome do Evento'),
                      onChanged: (v) => nome = v,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: descricao,
                      decoration: const InputDecoration(labelText: 'Descrição'),
                      onChanged: (v) => descricao = v,
                      maxLines: 2,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe a descrição' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: informacoesAdicionais,
                      decoration: const InputDecoration(labelText: 'Informações Adicionais'),
                      onChanged: (v) => informacoesAdicionais = v,
                      maxLines: 3,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe as informações adicionais' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: local,
                      decoration: const InputDecoration(labelText: 'Local'),
                      onChanged: (v) => local = v,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe o local' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: preco.toString(),
                      decoration: const InputDecoration(labelText: 'Preço'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => preco = int.tryParse(v) ?? 0,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Informe o preço' : null,
                    ),
                    const SizedBox(height: 8),
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
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        data == null
                            ? 'Escolha a data do evento'
                            : 'Data: ${data!.day.toString().padLeft(2, '0')}/'
                                '${data!.month.toString().padLeft(2, '0')}/'
                                '${data!.year} às ${data!.hour.toString().padLeft(2, '0')}:'
                                '${data!.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.date_range),
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
                                      ? TimeOfDay(hour: data!.hour, minute: data!.minute)
                                      : const TimeOfDay(hour: 19, minute: 0),
                                );
                                if (t != null) {
                                  setModal(() {
                                    data = DateTime(d.year, d.month, d.day, t.hour, t.minute);
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
            TextButton(
              child: const Text('Cancelar'),
              onPressed: carregandoLocal ? null : () => Navigator.pop(context),
            ),
            ElevatedButton(
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
                        'data': data != null ? Timestamp.fromDate(data!) : null,
                        'imageUrl': url,
                        'Informações Adicionais': informacoesAdicionais,
                      };
                      if (doc == null) {
                        await FirebaseFirestore.instance.collection('events').add(eventoData);
                      } else {
                        await doc.reference.update(eventoData);
                      }
                      Navigator.pop(context);
                    },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _removerEvento(DocumentSnapshot doc) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remover Evento'),
      content: const Text('Tem certeza que deseja remover este evento? Todos os ingressos desse evento também serão apagados!'),
      actions: [
        TextButton(
          child: const Text('Cancelar'),
          onPressed: () => Navigator.pop(context, false),
        ),
        ElevatedButton(
          child: const Text('Remover'),
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    ),
  );
  if (confirm == true) {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Apaga todos os tickets com esse eventId
    final ticketsQuery = await FirebaseFirestore.instance
        .collection('tickets')
        .where('eventId', isEqualTo: doc.id)
        .get();

    for (final ticketDoc in ticketsQuery.docs) {
      batch.delete(ticketDoc.reference);
    }

    // 2. Apaga o evento
    batch.delete(doc.reference);

    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento e todos os ingressos removidos!')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: const Text('Adicionar Evento'),
        icon: const Icon(Icons.add),
        onPressed: () => _abrirFormularioEvento(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').orderBy('data').snapshots(),
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
              final info = evento['Informações Adicionais'] ?? '';
              String dataFormatada = '';
              if (evento['data'] != null && evento['data'] is Timestamp) {
                final date = (evento['data'] as Timestamp).toDate();
                dataFormatada =
                  '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
              }

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.only(bottom: 18),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: imageUrl != null && imageUrl.toString().isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(imageUrl, width: 60, height: 60, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.event, size: 32, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 60, height: 60, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.event, size: 32, color: Colors.grey)),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (dataFormatada.isNotEmpty)
                        Text(dataFormatada, style: const TextStyle(fontSize: 13)),
                      if (descricao.isNotEmpty)
                        Text(descricao, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      if (info.isNotEmpty)
                        Text(info, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _abrirFormularioEvento(doc: docs[i]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removerEvento(docs[i]),
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

class ValidarIngressosTab extends StatelessWidget {
  const ValidarIngressosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const TelaQRCode();
  }
}

class AdminConfiguracoesTab extends StatelessWidget {
  const AdminConfiguracoesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 36, left: 18, right: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Configurações",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 120,
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      } else {
                        Navigator.of(context).pushReplacementNamed('/');
                      }
                    },
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
