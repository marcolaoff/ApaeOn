import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:screen_brightness/screen_brightness.dart';

class IngressosQRCodesScreen extends StatefulWidget {
  final String nomeEvento;
  final String eventId;
  final void Function(bool)? onToggleTheme;

  const IngressosQRCodesScreen({
    super.key,
    required this.nomeEvento,
    required this.eventId,
    this.onToggleTheme,
  });

  @override
  State<IngressosQRCodesScreen> createState() => _IngressosQRCodesScreenState();
}

class _IngressosQRCodesScreenState extends State<IngressosQRCodesScreen> {
  double? _previousBrightness;

  @override
  void initState() {
    super.initState();
    _setBrightness();
  }

  @override
  void dispose() {
    _restoreBrightness();
    super.dispose();
  }

  Future<void> _setBrightness() async {
    try {
      _previousBrightness = await ScreenBrightness().current;
      await ScreenBrightness().setScreenBrightness(1.0);
    } catch (e) {
      // opcional: logar erro se quiser
    }
  }

  Future<void> _restoreBrightness() async {
    try {
      if (_previousBrightness != null) {
        await ScreenBrightness().setScreenBrightness(_previousBrightness!);
      }
    } catch (e) {
      // opcional: logar erro
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ingressos: ${widget.nomeEvento}',
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(
                color: theme.appBarTheme.titleTextStyle?.color ?? textColor,
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: user == null
          ? Center(
              child: Text(
                'Usuário não autenticado',
                style: TextStyle(color: textColor),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .where('userId', isEqualTo: user.uid)
                  .where('eventId', isEqualTo: widget.eventId)
                  .snapshots(),
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

                final tickets = snapshot.data?.docs ?? [];
                if (tickets.isEmpty) {
                  return Center(
                    child: Text(
                      'Nenhum ingresso disponível.',
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                // separa ativos / inativos pra mostrar ativos primeiro
                final ativos = tickets.where((d) {
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  return (data['status'] ?? '') == 'ativo';
                }).toList();

                final inativos = tickets.where((d) {
                  final data = d.data() as Map<String, dynamic>? ?? {};
                  return (data['status'] ?? '') != 'ativo';
                }).toList();

                final ticketsOrdenados = [...ativos, ...inativos];

                return PageView.builder(
                  itemCount: ticketsOrdenados.length,
                  itemBuilder: (context, i) {
                    final data = ticketsOrdenados[i].data() as Map<String, dynamic>? ?? {};
                    final tipo = data['tipo'] ?? '';
                    final status = data['status'] ?? '';
                    final qrData = data['qrCodeData'] ?? '';
                    final isAtivo = status == 'ativo';

                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Opacity(
                        opacity: isAtivo ? 1 : 0.55,
                        child: Card(
                          elevation: 2,
                          color: cardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (qrData.toString().isNotEmpty)
                                    QrImageView(
                                      data: qrData,
                                      version: QrVersions.auto,
                                      size: 240,
                                      gapless: false,
                                      backgroundColor: Colors.transparent,
                                    )
                                  else
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 80,
                                        color: isDark ? Colors.white54 : Colors.grey,
                                      ),
                                    ),
                                  const SizedBox(height: 28),
                                  Text(
                                    'Tipo: $tipo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: textColor,
                                      decoration: isAtivo ? null : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    'Status: ${isAtivo ? "Ativo" : "Inativo"}',
                                    style: TextStyle(
                                      color: isAtivo ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Código: $qrData',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? Colors.white60 : Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    'Deslize para o lado para ver outros ingressos',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
