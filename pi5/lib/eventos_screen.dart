import 'package:flutter/material.dart';
import 'package:pi5/details_screen.dart';
import 'perfil_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ingressosqrcode_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class EventosScreen extends StatelessWidget {
  final void Function(bool)? onToggleTheme;

  const EventosScreen({super.key, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme
              .of(context)
              .appBarTheme
              .backgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            labelColor:
            Theme
                .of(context)
                .tabBarTheme
                .labelColor ??
                (isDark ? Colors.white : Colors.black),
            unselectedLabelColor:
            Theme
                .of(context)
                .tabBarTheme
                .unselectedLabelColor ??
                (isDark ? Colors.white60 : Colors.black54),
            indicatorColor:
            Theme
                .of(context)
                .tabBarTheme
                .indicatorColor ??
                (isDark ? Colors.white : Colors.black),
            tabs: const [
              Tab(text: 'Eventos'),
              Tab(text: 'Meus Ingressos'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            EventosTab(onToggleTheme: onToggleTheme),
            MeusIngressosTab(onToggleTheme: onToggleTheme),
            ConfiguracoesTab(onToggleTheme: onToggleTheme),
          ],
        ),
      ),
    );
  }
}

class EventosTab extends StatelessWidget {
  final void Function(bool)? onToggleTheme;

  const EventosTab({super.key, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final textColor = Theme
        .of(context)
        .textTheme
        .bodyLarge
        ?.color;
    final cardColor = Theme
        .of(context)
        .cardColor;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('events').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar eventos',
              style: TextStyle(color: textColor),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'Nenhum evento encontrado.',
              style: TextStyle(color: textColor),
            ),
          );
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
              '${date.day.toString().padLeft(2, '0')}/${date.month
                  .toString()
                  .padLeft(2, '0')}/${date.year} às ${date.hour
                  .toString()
                  .padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 18),
              elevation: 2,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.event,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
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
                            const SizedBox(height: 2),
                            Text(
                              'Data: $dataFormatada',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
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
                          String? imageUrl = evento['imageUrl']?.toString();
                          if (imageUrl == null) {
                            return Container(
                              height: 100,
                              width: double.infinity,
                              color: isDark ? Colors.red[900] : Colors.red[200],
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
                              color:
                              isDark
                                  ? Colors.orange[900]
                                  : Colors.orange[200],
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
                              color:
                              isDark
                                  ? Colors.yellow[800]
                                  : Colors.yellow[200],
                              child: Center(
                                child: Text(
                                  'URL INVÁLIDA:\n$imageUrl',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
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
                            errorBuilder:
                                (_, __, ___) =>
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  color:
                                  isDark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      descricao,
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 150,
                      height: 34,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                          isDark ? Colors.deepPurpleAccent : Colors.white,
                          foregroundColor: isDark ? Colors.white : Colors.black,
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
                              builder:
                                  (context) =>
                                  DetailsScreen(
                                    eventId: eventos[index].id,
                                    onToggleTheme: onToggleTheme,
                                  ),
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
  final void Function(bool)? onToggleTheme;

  const MeusIngressosTab({super.key, this.onToggleTheme});

  Stream<Map<String, Map<String, dynamic>>>
  _streamUserTicketsGroupedByEvent() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield {};
      return;
    }
    await for (final ticketsSnap
    in FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .snapshots()) {
      final Map<String, Map<String, dynamic>> grouped = {};

      for (var doc in ticketsSnap.docs) {
        final ticket = doc.data();
        final eventId = ticket['eventId'];
        if (eventId == null || (eventId is String && eventId
            .trim()
            .isEmpty)) {
          continue;
        }

        if (!grouped.containsKey(eventId)) {
          final eventSnap =
          await FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .get();
          if (!eventSnap.exists) continue;

          grouped[eventId] = {
            'evento': eventSnap.data()!
              ..['id'] = eventSnap.id,
            'tickets': <Map<String, dynamic>>[],
          };
        }
        final ticketMap = Map<String, dynamic>.from(ticket);
        ticketMap['ticketId'] = doc.id;
        (grouped[eventId]!['tickets'] as List).add(ticketMap);
      }
      yield grouped;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final textColor = Theme
        .of(context)
        .textTheme
        .bodyLarge
        ?.color;
    final cardColor = Theme
        .of(context)
        .cardColor;

    return StreamBuilder<Map<String, Map<String, dynamic>>>(
      stream: _streamUserTicketsGroupedByEvent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Erro ao carregar ingressos.',
              style: TextStyle(color: textColor),
            ),
          );
        }
        final data = snapshot.data ?? {};
        if (data.isEmpty) {
          return Center(
            child: Text(
              'Você ainda não possui ingressos.',
              style: TextStyle(color: textColor),
            ),
          );
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
            final eventId = evento?['id'] ?? '';
            String dataFormatada = '';
            if (dataTimestamp != null && dataTimestamp is Timestamp) {
              final date = dataTimestamp.toDate();
              dataFormatada =
              '${date.day.toString().padLeft(2, '0')}/${date.month
                  .toString()
                  .padLeft(2, '0')}/${date.year} às ${date.hour
                  .toString()
                  .padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
            }
            return Card(
              margin: const EdgeInsets.only(bottom: 18),
              elevation: 2,
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blueAccent,
                          child: Icon(
                            Icons.event,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
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
                            const SizedBox(height: 2),
                            Text(
                              'Data: $dataFormatada',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
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
                              color:
                              isDark ? Colors.grey[700] : Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey,
                              ),
                            );
                          }
                          imageUrl = imageUrl.replaceAll('"', '').trim();
                          if (!imageUrl.startsWith('http')) {
                            return Container(
                              height: 100,
                              width: double.infinity,
                              color:
                              isDark
                                  ? Colors.yellow[800]
                                  : Colors.yellow[200],
                              child: Center(
                                child: Text(
                                  'URL INVÁLIDA:\n$imageUrl',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 10,
                                  ),
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
                            errorBuilder:
                                (_, __, ___) =>
                                Container(
                                  height: 100,
                                  width: double.infinity,
                                  color:
                                  isDark
                                      ? Colors.grey[700]
                                      : Colors.grey[300],
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      descricao,
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quantidade de ingressos: ${tickets.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 150,
                      height: 34,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                          isDark ? Colors.deepPurpleAccent : Colors.white,
                          foregroundColor: isDark ? Colors.white : Colors.black,
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
                              builder:
                                  (context) =>
                                  IngressosQRCodesScreen(
                                    nomeEvento: nome,
                                    eventId: eventId,
                                    onToggleTheme: onToggleTheme,
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

  const ConfiguracoesTab({super.key, this.onToggleTheme});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(onToggleTheme: onToggleTheme),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

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
                        activeThumbColor: Colors.black,
                        onChanged: (val) {
                          if (onToggleTheme != null) {
                            onToggleTheme!(val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                                color: cardColor,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
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
                                  Text(
                                    'Versão do app : Teste 1.0.3',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: 100,
                                    height: 36,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: cardColor,
                                        foregroundColor: textColor,
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
                    child: Text(
                      "VERSÃO DO APLICATIVO",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () async {
                      const url = 'https://www.google.com/maps/search/?api=1&query=-22.424345194559244,-46.81835773070385';
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
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
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
            ),
          ],
        ),
      ),
    );
  }
}
