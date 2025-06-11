import 'package:flutter/material.dart';
import 'package:pi5/details_screen.dart';
import 'perfil_screen.dart'; // Importe sua tela de perfil aqui
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Garanta que está no seu projeto
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ingressosqrcode_screen.dart'; // Troque pelo caminho correto do seu projeto


class EventosScreen extends StatelessWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;
  const EventosScreen({super.key, this.onToggleTheme, this.darkMode = false});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Eventos'),
              Tab(text: 'Meus Ingressos'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const EventosTab(),
            const MeusIngressosTab(),
            ConfiguracoesTab(
              onToggleTheme: onToggleTheme,
              darkMode: darkMode,
            ),
          ],
        ),
      ),
    );
  }
}

class EventosTab extends StatelessWidget {
  const EventosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar eventos'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhum evento encontrado.'));
        }

        final eventos = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          itemCount: eventos.length,
          itemBuilder: (context, index) {
  final evento = eventos[index].data() as Map<String, dynamic>;
  final nome = evento['nome'] ?? 'Sem nome';
  final descricao = evento['descrição'] ?? '';
  final dataTimestamp = evento['data'];
  String dataFormatada = '';
  if (dataTimestamp != null && dataTimestamp is Timestamp) {
    final date = dataTimestamp.toDate();
    dataFormatada =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  return Card(
    margin: const EdgeInsets.only(bottom: 18),
    elevation: 2,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.event, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Data: $dataFormatada',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // IMAGEM DO EVENTO (corrigida)
          ClipRRect(
  borderRadius: BorderRadius.circular(6),
  child: Builder(
    builder: (context) {
      // Pega e mostra no console o valor do campo
      String? imageUrl = evento['imageUrl']?.toString();
      print('DEBUG - Campo imageUrl do evento: $imageUrl');
      if (imageUrl == null) {
        return Container(
          height: 100,
          width: double.infinity,
          color: Colors.red[200],
          child: const Center(
            child: Text(
              'URL NULA',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      imageUrl = imageUrl.replaceAll('"', '').trim();
      if (imageUrl.isEmpty) {
        return Container(
          height: 100,
          width: double.infinity,
          color: Colors.orange[200],
          child: const Center(
            child: Text(
              'URL VAZIA',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
      if (!imageUrl.startsWith('http')) {
        return Container(
          height: 100,
          width: double.infinity,
          color: Colors.yellow[200],
          child: Center(
            child: Text(
              'URL INVÁLIDA:\n$imageUrl',
              style: const TextStyle(color: Colors.black, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return Image.network(
        imageUrl,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 100,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
        ),
      );
    },
  ),
),


          const SizedBox(height: 16),
          Text(
            descricao,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 150,
            height: 34,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontSize: 15),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailsScreen(eventId: eventos[index].id),
                  ),
                );
              },
              child: const Text('Detalhes'),
            ),
          ),
        ],
      ),
    ),
  );
},

        );
      },
    );
  }
}


class MeusIngressosTab extends StatelessWidget {
  const MeusIngressosTab({super.key});

  // Stream de tickets do usuário agrupados por evento
  Stream<Map<String, Map<String, dynamic>>> _streamUserTicketsGroupedByEvent() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield {};
      return;
    }
    // Escuta os tickets em tempo real
    await for (final ticketsSnap in FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .snapshots()) {
      final Map<String, Map<String, dynamic>> grouped = {};

      for (var doc in ticketsSnap.docs) {
        final ticket = doc.data();
        // Somente ingressos válidos!
        if (ticket['status'] != 'ativo') continue;
        final eventId = ticket['eventId'];
        if (eventId == null || (eventId is String && eventId.trim().isEmpty)) continue;

        if (!grouped.containsKey(eventId)) {
          final eventSnap = await FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .get();
          if (!eventSnap.exists) continue;

          grouped[eventId] = {
            'evento': eventSnap.data()!..['id'] = eventSnap.id, // Adiciona o id do evento
            'tickets': <Map<String, dynamic>>[],
          };
        }
        final ticketMap = Map<String, dynamic>.from(ticket);
        ticketMap['ticketId'] = doc.id;
        (grouped[eventId]!['tickets'] as List).add(ticketMap);
      }
      // Remova eventos SEM ingressos válidos
      grouped.removeWhere((_, v) => (v['tickets'] as List).isEmpty);
      yield grouped;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, Map<String, dynamic>>>(
      stream: _streamUserTicketsGroupedByEvent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Erro ao carregar ingressos.'));
        }
        final data = snapshot.data ?? {};
        if (data.isEmpty) {
          return const Center(child: Text('Você ainda não possui ingressos.'));
        }
        final eventos = data.values.toList();
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          itemCount: eventos.length,
          itemBuilder: (context, index) {
            final evento = eventos[index]['evento'];
            final tickets = eventos[index]['tickets'] as List;
            final nome = evento?['nome'] ?? 'Evento sem nome';
            final dataTimestamp = evento?['data'];
            final descricao = evento?['descrição'] ?? '';
            final eventId = evento?['id'] ?? ''; // Garante o ID
            String dataFormatada = '';
            if (dataTimestamp != null && dataTimestamp is Timestamp) {
              final date = dataTimestamp.toDate();
              dataFormatada =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 18),
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(Icons.event, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nome,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Data: $dataFormatada',
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Builder(
                        builder: (context) {
                          String? imageUrl = evento?['imageUrl']?.toString();
                          if (imageUrl == null || imageUrl.isEmpty) {
                            return Container(
                              height: 100,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            );
                          }
                          imageUrl = imageUrl.replaceAll('"', '').trim();
                          if (!imageUrl.startsWith('http')) {
                            return Container(
                              height: 100,
                              width: double.infinity,
                              color: Colors.yellow[200],
                              child: Center(
                                child: Text(
                                  'URL INVÁLIDA:\n$imageUrl',
                                  style: const TextStyle(color: Colors.black, fontSize: 10),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return Image.network(
                            imageUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 100,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                    Text(
                      descricao,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quantidade de ingressos: ${tickets.length}',
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 150,
                      height: 34,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.black26),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(fontSize: 15),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IngressosQRCodesScreen(
                                nomeEvento: nome,
                                eventId: eventId, // Passe só o nomeEvento e o eventId
                              ),
                            ),
                          );
                        },
                        child: const Text('Ver Ingressos'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}



class ConfiguracoesTab extends StatelessWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;
  const ConfiguracoesTab({super.key, this.onToggleTheme, this.darkMode = false});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            onToggleTheme: onToggleTheme,
            darkMode: darkMode,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36, left: 18, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modo escuro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "MODO ESCURO",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Switch(
                        value: darkMode,
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

                  // Perfil Usuário
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PerfilUsuarioScreen()),
                      );
                    },
                    child: const Text(
                      "PERFIL USUARIO",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 16,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Versão do app : Teste 1.0.3',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 100,
                                    height: 36,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.black,
                                        elevation: 1,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        side: const BorderSide(color: Colors.black12),
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Fechar'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text(
                      "VERSÃO DO APLICATIVO",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Text(
                    "LOCALIZAÇÃO",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),

            // Botão Sair (agora faz logout real!)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Colors.black12),
                    ),
                    onPressed: () => _logout(context),
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}