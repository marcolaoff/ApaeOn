import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

/// URL fixa do backend (Render)
const String baseUrl = 'https://apaeon.onrender.com';

class IngressoScreen extends StatefulWidget {
  final String eventId;
  final void Function(bool)? onToggleTheme;
  final bool darkMode;

  const IngressoScreen({
    super.key,
    required this.eventId,
    this.onToggleTheme,
    this.darkMode = false,
  });

  @override
  State<IngressoScreen> createState() => _IngressoScreenState();
}

class _IngressoScreenState extends State<IngressoScreen> {
  int quantidadeNormal = 0;
  int quantidadeMeia = 0;
  bool _loading = false;

  // 🔹 Future cacheado para não refazer o .get() a cada setState
  late Future<DocumentSnapshot> _eventFuture;

  @override
  void initState() {
    super.initState();
    _eventFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
  }

  /// (Atualmente não usada) Cria ingressos no Firestore
  Future<List<String>> salvarIngressosNoFirestore({
    required int quantidadeNormal,
    required int quantidadeMeia,
    required String eventId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userEmail = user.email ?? '';
    final ticketsCollection =
        FirebaseFirestore.instance.collection('tickets');
    final now = DateTime.now();
    final List<String> ticketIds = [];

    for (int i = 0; i < quantidadeNormal; i++) {
      final doc = await ticketsCollection.add({
        'userId': user.uid,
        'email': userEmail,
        'tipo': 'Normal',
        'qrCodeData':
            'QR-NORMAL-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': eventId,
      });
      ticketIds.add(doc.id);
    }

    for (int i = 0; i < quantidadeMeia; i++) {
      final doc = await ticketsCollection.add({
        'userId': user.uid,
        'email': userEmail,
        'tipo': 'Meia',
        'qrCodeData':
            'QR-MEIA-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': eventId,
      });
      ticketIds.add(doc.id);
    }

    return ticketIds;
  }

  /// Chama o backend para criar o pagamento PIX
  Future<Map<String, dynamic>> criarPagamentoPix({
    required double amount,
    required String email,
    required String fullName,
  }) async {
    final url = Uri.parse('$baseUrl/pix');
    final resp = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
        'email': email,
        'fullName': fullName,
      }),
    );

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Erro ao criar PIX: ${resp.statusCode} ${resp.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Colors.black54);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Selecionar Ingresso',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        // 🔹 Usa o future cacheado
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Evento não encontrado ou erro ao carregar!',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;

          // ✅ Mais robusto para campo "preco" (num ou string)
          final precoRaw = eventData['preco'];
          double valorIngresso;
          if (precoRaw is num) {
            valorIngresso = precoRaw.toDouble();
          } else if (precoRaw is String) {
            valorIngresso =
                double.tryParse(precoRaw.replaceAll(',', '.')) ?? 0.0;
          } else {
            valorIngresso = 0.0;
          }

          final double valorMeia = valorIngresso / 2;

          // 🔹 Calcula total e arredonda para 2 casas
          final double totalBruto =
              (quantidadeNormal * valorIngresso) +
              (quantidadeMeia * valorMeia);
          final double total =
              double.parse(totalBruto.toStringAsFixed(2));

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantidade de Ingressos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),

                // ========== NORMAL ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Normal',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: textColor),
                          onPressed: quantidadeNormal > 0
                              ? () {
                                  setState(() {
                                    quantidadeNormal--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '$quantidadeNormal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: textColor),
                          onPressed: () {
                            setState(() {
                              quantidadeNormal++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                  child: Text(
                    'Valor: R\$ ${valorIngresso.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ),

                // ========== MEIA ==========
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meia',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: textColor),
                          onPressed: quantidadeMeia > 0
                              ? () {
                                  setState(() {
                                    quantidadeMeia--;
                                  });
                                }
                              : null,
                        ),
                        Text(
                          '$quantidadeMeia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: textColor),
                          onPressed: () {
                            setState(() {
                              quantidadeMeia++;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 8),
                  child: Text(
                    'Valor: R\$ ${valorMeia.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: textSecondary,
                    ),
                  ),
                ),

                const Spacer(),

                // ========== TOTAL ==========
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ========== BOTÃO CONFIRMAR ==========
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor:
                          isDark ? Colors.white : Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(
                        color: isDark ? Colors.white12 : Colors.black12,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: (quantidadeNormal + quantidadeMeia > 0)
                        ? () async {
                            setState(() => _loading = true);

                            try {
                              final user =
                                  FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                throw Exception('Usuário não autenticado');
                              }

                              final payment = await criarPagamentoPix(
                                amount: total,
                                email: user.email ?? '',
                                fullName:
                                    user.displayName ?? 'Comprador',
                              );

                              final paymentId =
                                  payment['id']?.toString() ?? '';

                              // ✅ CORREÇÃO: acesso seguro ao transaction_data
                              final poi = payment['point_of_interaction']
                                  as Map<String, dynamic>?;
                              final txn = poi?['transaction_data']
                                  as Map<String, dynamic>?;

                              final qrBase64 =
                                  txn?['qr_code_base64'] as String?;
                              final copiaCola =
                                  txn?['qr_code'] as String?;

                              if (!mounted) return;
                              setState(() => _loading = false);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PagamentoPixScreen(
                                    paymentId: paymentId,
                                    qrBase64: qrBase64,
                                    copiaCola: copiaCola,
                                    quantidadeNormal:
                                        quantidadeNormal,
                                    quantidadeMeia: quantidadeMeia,
                                    eventId: widget.eventId,
                                    onPagamentoAprovado:
                                        (List<String> ticketIds) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              QRCodesGeradosScreen(
                                            ticketIds: ticketIds,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!mounted) return;
                              setState(() => _loading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Erro ao gerar PIX: $e'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: _loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Confirmar Compra'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =====================================================================
// PAGAMENTO PIX
// =====================================================================

class PagamentoPixScreen extends StatefulWidget {
  final String paymentId;
  final String? qrBase64;
  final String? copiaCola;
  final int quantidadeNormal;
  final int quantidadeMeia;
  final String eventId;
  final void Function(List<String>) onPagamentoAprovado;

  const PagamentoPixScreen({
    super.key,
    required this.paymentId,
    required this.qrBase64,
    required this.copiaCola,
    required this.quantidadeNormal,
    required this.quantidadeMeia,
    required this.eventId,
    required this.onPagamentoAprovado,
  });

  @override
  State<PagamentoPixScreen> createState() => _PagamentoPixScreenState();
}

class _PagamentoPixScreenState extends State<PagamentoPixScreen> {
  bool _checking = false;
  bool _paid = false;
  String _statusMessage = 'Aguardando pagamento.';

  Future<void> _copiarCopiaCola() async {
    await Clipboard.setData(
      ClipboardData(text: widget.copiaCola ?? ''),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código PIX copiado')),
    );
  }

  Future<void> _verificarPagamento() async {
    setState(() {
      _checking = true;
      _statusMessage = 'Verificando...';
    });

    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/payment/${widget.paymentId}'));

      if (resp.statusCode != 200) {
        throw Exception('Código ${resp.statusCode}');
      }

      final body = jsonDecode(resp.body);
      final payment = body['payment'] ?? body;
      final status =
          (payment['status'] ?? '').toString().toLowerCase();

      final paid = [
        'approved',
        'accredited',
        'paid',
        'success',
        'completed',
      ].contains(status);

      if (!mounted) return;

      if (paid) {
        setState(() {
          _statusMessage = 'Pagamento confirmado!';
          _paid = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          setState(() {
            _statusMessage =
                'Usuário não autenticado ao salvar ingressos.';
          });
          setState(() => _checking = false);
          return;
        }

        final ticketsCollection =
            FirebaseFirestore.instance.collection('tickets');
        final now = DateTime.now();
        final List<String> tickets = [];

        for (int i = 0; i < widget.quantidadeNormal; i++) {
          final doc = await ticketsCollection.add({
            'userId': user.uid,
            'email': user.email ?? '',
            'tipo': 'Normal',
            'qrCodeData':
                'QR-NORMAL-${user.uid}-${now.millisecondsSinceEpoch}-$i',
            'criacao': now,
            'status': 'ativo',
            'eventId': widget.eventId,
          });
          tickets.add(doc.id);
        }

        for (int i = 0; i < widget.quantidadeMeia; i++) {
          final doc = await ticketsCollection.add({
            'userId': user.uid,
            'email': user.email ?? '',
            'tipo': 'Meia',
            'qrCodeData':
                'QR-MEIA-${user.uid}-${now.millisecondsSinceEpoch}-$i',
            'criacao': now,
            'status': 'ativo',
            'eventId': widget.eventId,
          });
          tickets.add(doc.id);
        }

        widget.onPagamentoAprovado(tickets);
      } else {
        setState(() {
          _statusMessage = 'Pagamento pendente: $status';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Erro: $e';
      });
    }

    if (!mounted) return;
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final cardColor = theme.cardColor;

    return WillPopScope(
      // impede voltar pelo botão físico
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          // remove a setinha de voltar
          automaticallyImplyLeading: false,
          title: const Text('Pagamento PIX'),
          backgroundColor: theme.appBarTheme.backgroundColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (widget.qrBase64 != null)
                Image.memory(
                  base64Decode(widget.qrBase64!),
                  width: 250,
                  height: 250,
                )
              else
                Text(
                  'QR Code não disponível',
                  style: TextStyle(color: textColor),
                ),

              const SizedBox(height: 20),
              SelectableText(
                widget.copiaCola ?? 'Código PIX indisponível',
                textAlign: TextAlign.center,
                style: TextStyle(color: textColor),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar'),
                    onPressed: _copiarCopiaCola,
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: _checking
                        ? const Text('Verificando...')
                        : const Text('Verificar Pagamento'),
                    onPressed: _checking ? null : _verificarPagamento,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: TextStyle(color: textColor),
              ),

              const Spacer(),

              // botão de cancelar compra
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text(
                    'Cancelar compra',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textColor,
                    side: BorderSide(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                    backgroundColor: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // volta para a tela inicial (onde está a lista de eventos)
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                ),
              ),

              const SizedBox(height: 8),

              if (_paid)
                Text(
                  'Pagamento confirmado! Você já pode ver seus ingressos em "Meus ingressos".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// TELA DE EXIBIÇÃO DOS QR CODES GERADOS
// =====================================================================

class QRCodesGeradosScreen extends StatelessWidget {
  final List<String> ticketIds;

  const QRCodesGeradosScreen({
    super.key,
    required this.ticketIds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final textSecondary =
        theme.textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Colors.black54);
    final cardColor = theme.cardColor;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Seus QR Codes'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: ticketIds.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum ingresso gerado.',
                      style: TextStyle(color: textColor),
                    ),
                  )
                : FutureBuilder<List<DocumentSnapshot>>(
                    future: Future.wait(ticketIds.map((id) =>
                        FirebaseFirestore.instance
                            .collection('tickets')
                            .doc(id)
                            .get())),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final tickets = snapshot.data!;

                      return ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: tickets.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 28),
                        itemBuilder: (context, i) {
                          final data = tickets[i].data()
                                  as Map<String, dynamic>? ??
                              {};
                          final tipo = data['tipo'] ?? '';
                          final qrData = data['qrCodeData'] ?? '';

                          return Card(
                            color: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 22,
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                children: [
                                  QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 180,
                                    gapless: false,
                                    backgroundColor:
                                        Colors.transparent,
                                  ),
                                  const SizedBox(height: 18),
                                  Text(
                                    'Tipo: $tipo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    'Código: $qrData',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.event, color: Colors.white),
                label: const Text(
                  'Voltar para Eventos',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
