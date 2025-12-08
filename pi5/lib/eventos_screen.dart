import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import 'details_screen.dart';
import 'perfil_screen.dart';
import 'login_screen.dart';
import 'ingressosqrcode_screen.dart';
import 'chatbot_screen.dart';
import 'sobre_apae_screen.dart';

class EventosScreen extends StatefulWidget {
  final void Function(bool)? onToggleTheme;

  const EventosScreen({super.key, this.onToggleTheme});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  int _selectedIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String get _title {
    switch (_selectedIndex) {
      case 0:
        return 'Eventos';
      case 1:
        return 'Meus Ingressos';
      case 2:
        return 'Configurações';
      default:
        return 'ApaeOn';
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
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
    final user = FirebaseAuth.instance.currentUser;

    late final Widget body;
    switch (_selectedIndex) {
      case 0:
        body = EventosTab(onToggleTheme: widget.onToggleTheme);
        break;
      case 1:
        body = MeusIngressosTab(onToggleTheme: widget.onToggleTheme);
        break;
      case 2:
      default:
        body = ConfiguracoesTab(onToggleTheme: widget.onToggleTheme);
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        title: Text(
          _title,
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: scaffoldBg,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Cabeçalho com dados do usuário logado (Firestore + FirebaseAuth)
              if (user != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    final data =
                        snapshot.data?.data() as Map<String, dynamic>?;

                    // Nome
                    String nomeDrawer;
                    final firestoreNome = data?['nome'] as String?;
                    if (firestoreNome != null &&
                        firestoreNome.trim().isNotEmpty) {
                      nomeDrawer = firestoreNome.trim();
                    } else if (user.displayName != null &&
                        user.displayName!.trim().isNotEmpty) {
                      nomeDrawer = user.displayName!.trim();
                    } else {
                      nomeDrawer = 'Usuário';
                    }

                    // Email
                    String emailDrawer;
                    final firestoreEmail = data?['email'] as String?;
                    if (firestoreEmail != null &&
                        firestoreEmail.trim().isNotEmpty) {
                      emailDrawer = firestoreEmail.trim();
                    } else {
                      emailDrawer = user.email ?? 'Sem email cadastrado';
                    }

                    // Foto (prioridade Firestore -> Auth)
                    String? fotoDrawer;
                    final firestoreFoto = data?['fotoUrl'] as String?;
                    if (firestoreFoto != null &&
                        firestoreFoto.trim().isNotEmpty) {
                      fotoDrawer = firestoreFoto.trim();
                    } else if (user.photoURL != null &&
                        user.photoURL!.trim().isNotEmpty) {
                      fotoDrawer = user.photoURL!.trim();
                    } else {
                      fotoDrawer = null;
                    }

                    return UserAccountsDrawerHeader(
                      decoration: BoxDecoration(
                        color: appBarBg,
                      ),
                      accountName: Text(
                        nomeDrawer,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      accountEmail: Text(
                        emailDrawer,
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                      currentAccountPicture: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 36,
                        child: ClipOval(
                          child: (fotoDrawer != null &&
                                  fotoDrawer.trim().isNotEmpty)
                              ? Image.network(
                                  fotoDrawer.trim(),
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Icon(
                                      Icons.person,
                                      size: 40,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black54,
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  size: 40,
                                  color: isDark
                                      ? Colors.white
                                      : Colors.black54,
                                ),
                        ),
                      ),
                    );
                  },
                )
              else
                DrawerHeader(
                  decoration: BoxDecoration(color: appBarBg),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Usuário não logado',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Eventos
              ListTile(
                leading: Icon(Icons.event, color: textColor),
                title: Text(
                  'Eventos',
                  style: TextStyle(color: textColor),
                ),
                selected: _selectedIndex == 0,
                selectedTileColor: isDark ? Colors.white10 : Colors.black12,
                onTap: () {
                  Navigator.pop(context);
                  _selectPage(0);
                },
              ),

              // Meus Ingressos
              ListTile(
                leading: Icon(Icons.qr_code, color: textColor),
                title: Text(
                  'Meus ingressos',
                  style: TextStyle(color: textColor),
                ),
                selected: _selectedIndex == 1,
                selectedTileColor: isDark ? Colors.white10 : Colors.black12,
                onTap: () {
                  Navigator.pop(context);
                  _selectPage(1);
                },
              ),

              // Configurações
              ListTile(
                leading: Icon(Icons.settings, color: textColor),
                title: Text(
                  'Configurações',
                  style: TextStyle(color: textColor),
                ),
                selected: _selectedIndex == 2,
                selectedTileColor: isDark ? Colors.white10 : Colors.black12,
                onTap: () {
                  Navigator.pop(context);
                  _selectPage(2);
                },
              ),

              const Divider(),

              // Ajuda (Chatbot)
              ListTile(
                leading: Icon(Icons.help_outline, color: textColor),
                title: Text(
                  'Ajuda',
                  style: TextStyle(color: textColor),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChatbotScreen(),
                    ),
                  );
                },
              ),

              const Divider(),

              // Sair
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Sair',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  await _logout();
                },
              ),
            ],
          ),
        ),
      ),
      body: body,
    );
  }
}

// ===================== Eventos =========================

class EventosTab extends StatelessWidget {
  final void Function(bool)? onToggleTheme;

  const EventosTab({super.key, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final cardColor = theme.cardColor;

    return StreamBuilder<QuerySnapshot>(
      // ordena por data para ficar mais organizado
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('data')
          .snapshots(),
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
            Map<String, dynamic> evento;
            try {
              evento = eventos[index].data() as Map<String, dynamic>;
            } catch (_) {
              return Container(
                margin: const EdgeInsets.only(bottom: 18),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.red[900] : Colors.red[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Evento inválido ou corrompido.',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            final nome = evento['nome'] ?? 'Sem nome';
            final descricao = evento['descrição'] ?? '';
            final dataTimestamp = evento['data'];
            String dataFormatada = '';
            if (dataTimestamp != null && dataTimestamp is Timestamp) {
              final date = dataTimestamp.toDate();
              dataFormatada =
                  '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/'
                  '${date.year} às '
                  '${date.hour.toString().padLeft(2, '0')}:'
                  '${date.minute.toString().padLeft(2, '0')}';
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
                    // Cabeçalho
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blueAccent,
                          child: const Icon(
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
                                color:
                                    isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Imagem
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _EventImage(
                        imageUrl: evento['imageUrl'],
                        isDark: isDark,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Descrição
                    Text(
                      descricao,
                      style: TextStyle(fontSize: 13, color: textColor),
                    ),
                    const SizedBox(height: 12),

                    // Botão Detalhes
                    SizedBox(
                      width: 150,
                      height: 34,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.deepPurpleAccent : Colors.white,
                          foregroundColor:
                              isDark ? Colors.white : Colors.black,
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
                              builder: (context) => DetailsScreen(
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

/// Widget reutilizável para exibir imagem de evento com tratamento de URL
class _EventImage extends StatelessWidget {
  final dynamic imageUrl;
  final bool isDark;

  const _EventImage({
    required this.imageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    String? url = imageUrl?.toString();

    if (url == null) {
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

    url = url.replaceAll('"', '').trim();

    if (url.isEmpty) {
      return Container(
        height: 100,
        width: double.infinity,
        color: isDark ? Colors.orange[900] : Colors.orange[200],
        child: const Center(
          child: Text(
            'URL VAZIA',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!url.startsWith('http')) {
      return Container(
        height: 100,
        width: double.infinity,
        color: isDark ? Colors.yellow[800] : Colors.yellow[200],
        child: Center(
          child: Text(
            'URL INVÁLIDA:\n$url',
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
      url,
      height: 100,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 100,
        width: double.infinity,
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        child: const Icon(
          Icons.broken_image,
          size: 48,
          color: Colors.grey,
        ),
      ),
    );
  }
}

// ===================== Meus Ingressos =========================

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

    await for (final ticketsSnap in FirebaseFirestore.instance
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .snapshots()) {
      final Map<String, Map<String, dynamic>> grouped = {};

      for (final doc in ticketsSnap.docs) {
        final ticket = doc.data();
        final eventId = ticket['eventId'];

        if (eventId == null ||
            (eventId is String && eventId.trim().isEmpty)) {
          continue;
        }

        if (!grouped.containsKey(eventId)) {
          final eventSnap = await FirebaseFirestore.instance
              .collection('events')
              .doc(eventId)
              .get();
          if (!eventSnap.exists) continue;

          grouped[eventId] = {
            'evento': eventSnap.data()!..['id'] = eventSnap.id,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final cardColor = theme.cardColor;

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
            final evento = eventos[index]['evento'] as Map<String, dynamic>?;
            final tickets = eventos[index]['tickets'] as List;
            final nome = evento?['nome'] ?? 'Evento sem nome';
            final descricao = evento?['descrição'] ?? '';
            final eventId = evento?['id'] ?? '';

            final dataTimestamp = evento?['data'];
            String dataFormatada = '';
            if (dataTimestamp != null && dataTimestamp is Timestamp) {
              final date = dataTimestamp.toDate();
              dataFormatada =
                  '${date.day.toString().padLeft(2, '0')}/'
                  '${date.month.toString().padLeft(2, '0')}/'
                  '${date.year} às '
                  '${date.hour.toString().padLeft(2, '0')}:'
                  '${date.minute.toString().padLeft(2, '0')}';
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
                    // Cabeçalho
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blueAccent,
                          child: const Icon(
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
                                color:
                                    isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Imagem
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: _EventImage(
                        imageUrl: evento?['imageUrl'],
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Descrição
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

                    // Botão Ver Ingressos
                    SizedBox(
                      width: 150,
                      height: 34,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              isDark ? Colors.deepPurpleAccent : Colors.white,
                          foregroundColor:
                              isDark ? Colors.white : Colors.black,
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

// ===================== Configurações =========================

class ConfiguracoesTab extends StatelessWidget {
  final void Function(bool)? onToggleTheme;

  const ConfiguracoesTab({super.key, this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 36, left: 18, right: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modo escuro
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

              // Perfil Usuário
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

              // Sobre a APAE
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

              // Localização
              GestureDetector(
                onTap: () async {
                  const url =
                      'https://www.google.com/maps/search/?api=1&query=-22.424345194559244,-46.81835773070385';
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
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
