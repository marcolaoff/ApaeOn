import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

// BASE URL AUTOMÁTICA (Chrome / Android Emulador)
const String baseUrl =
    kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';

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
        'qrCodeData': 'QR-MEIA-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': eventId,
      });
      ticketIds.add(doc.id);
    }
    return ticketIds;
  }

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

  Future<Map<String, dynamic>> consultarPagamento(String paymentId) async {
    final url = Uri.parse('$baseUrl/payment/$paymentId');
    final resp = await http.get(url);

    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception(
          'Erro ao consultar pagamento: ${resp.statusCode} ${resp.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkMode;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Selecionar Ingresso', style: TextStyle(color: textColor)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Evento não encontrado!',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;
          final double valorIngresso = (eventData['preco'] ?? 0).toDouble();
          final double valorMeia = valorIngresso / 2;
          final double total = (quantidadeNormal * valorIngresso) +
              (quantidadeMeia * valorMeia);

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
                      color: textColor),
                ),
                const SizedBox(height: 20),

                // NORMAL
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Normal',
                        style: TextStyle(fontSize: 16, color: textColor)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: textColor),
                          onPressed: quantidadeNormal > 0
                              ? () => setState(() => quantidadeNormal--)
                              : null,
                        ),
                        Text('$quantidadeNormal',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: textColor),
                          onPressed: () =>
                              setState(() => quantidadeNormal++),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Valor: R\$ ${valorIngresso.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54),
                ),
                const SizedBox(height: 10),

                // MEIA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Meia',
                        style: TextStyle(fontSize: 16, color: textColor)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline,
                              color: textColor),
                          onPressed: quantidadeMeia > 0
                              ? () => setState(() => quantidadeMeia--)
                              : null,
                        ),
                        Text('$quantidadeMeia',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline,
                              color: textColor),
                          onPressed: () => setState(() => quantidadeMeia++),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  'Valor: R\$ ${valorMeia.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white60 : Colors.black54),
                ),
                const Spacer(),

                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor)),
                      Text('R\$ ${total.toStringAsFixed(2)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: textColor)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // BOTÃO CONFIRMAR
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: (quantidadeNormal + quantidadeMeia > 0)
                        ? () async {
                            setState(() => _loading = true);

                            try {
                              final user =
                                  FirebaseAuth.instance.currentUser;
                              if (user == null)
                                throw Exception('Usuário não autenticado');

                              final payment = await criarPagamentoPix(
                                amount: total,
                                email: user.email ?? '',
                                fullName: user.displayName ?? 'Comprador',
                              );

                              final paymentId =
                                  payment['id']?.toString() ?? '';
                              final txn =
                                  payment['point_of_interaction']
                                      ?['transaction_data'];
                              final qrBase64 =
                                  txn?['qr_code_base64'];
                              final copiaCola = txn?['qr_code'];

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
                                                  ticketIds:
                                                      ticketIds),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              setState(() => _loading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Erro ao gerar PIX: $e'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: _loading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2)
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

// PAGAMENTO PIX
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
  String _statusMessage = 'Aguardando pagamento...';

  Future<void> _copiarCopiaCola() async {
    await Clipboard.setData(
        ClipboardData(text: widget.copiaCola ?? ''));
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
        'completed'
      ].contains(status);

      if (paid) {
        setState(() {
          _statusMessage = 'Pagamento confirmado!';
          _paid = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final now = DateTime.now();
        final tickets = <String>[];

        final ticketsCollection =
            FirebaseFirestore.instance.collection('tickets');

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
      setState(() {
        _statusMessage = 'Erro: $e';
      });
    }

    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento PIX')),
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
              const Text('QR Code não disponível'),

            const SizedBox(height: 20),
            SelectableText(
              widget.copiaCola ?? 'Código PIX indisponível',
              textAlign: TextAlign.center,
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
            Text(_statusMessage),

            const Spacer(),

            if (_paid)
              ElevatedButton(
                child: const Text('Ver Ingressos'),
                onPressed: () {},
              )
          ],
        ),
      ),
    );
  }
}



class QRCodesGeradosScreen extends StatelessWidget {
  final List<String> ticketIds;

  const QRCodesGeradosScreen({
    super.key,
    required this.ticketIds,
  });

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Meus Ingressos'),
      automaticallyImplyLeading: false,
    ),
    body: Column(
      children: [
        // 🔹 Lista de ingressos
        Expanded(
          child: FutureBuilder<List<DocumentSnapshot>>(
            future: Future.wait(ticketIds.map((id) =>
                FirebaseFirestore.instance.collection('tickets').doc(id).get())),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final tickets = snapshot.data!;

              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: tickets.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, i) {
                  final data = tickets[i].data() as Map<String, dynamic>? ?? {};
                  final tipo = data['tipo'] ?? '';
                  final qrData = data['qrCodeData'] ?? '';

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          QrImageView(
                            data: qrData,
                            size: 180,
                            version: QrVersions.auto,
                          ),
                          const SizedBox(height: 12),
                          Text('Tipo: $tipo'),
                          Text('Código: $qrData',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // 🔹 BOTÃO "VOLTAR PARA EVENTOS"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
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