import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

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
    final ticketsCollection = FirebaseFirestore.instance.collection('tickets');
    final now = DateTime.now();
    final List<String> ticketIds = [];

    for (int i = 0; i < quantidadeNormal; i++) {
      final doc = await ticketsCollection.add({
        'userId': user.uid,
        'email': userEmail,
        'tipo': 'Normal',
        'qrCodeData': 'QR-NORMAL-${user.uid}-${now.millisecondsSinceEpoch}-$i',
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

  // Chama o backend para criar pagamento PIX
  Future<Map<String, dynamic>> criarPagamentoPix({
    required double amount,
    required String email,
    required String fullName,
  }) async {
    // se estiver em emulador Android use 10.0.2.2, caso contrário use o IP da sua máquina
    final url = Uri.parse('http://10.0.2.2:3000/pix');
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

  // Consulta pagamento por id no backend
  Future<Map<String, dynamic>> consultarPagamento(String paymentId) async {
    final url = Uri.parse('http://10.0.2.2:3000/payment/$paymentId');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    } else {
      throw Exception('Erro ao consultar pagamento: ${resp.statusCode} ${resp.body}');
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
        future: FirebaseFirestore.instance.collection('events').doc(widget.eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Evento não encontrado ou erro ao carregar!',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final eventData = snapshot.data!.data() as Map<String, dynamic>;
          final double valorIngresso = (eventData['preco'] ?? 0).toDouble();
          final double valorMeia = valorIngresso / 2;
          final double total = (quantidadeNormal * valorIngresso) + (quantidadeMeia * valorMeia);

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quantidade de Ingressos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Normal', style: TextStyle(fontSize: 16, color: textColor)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: textColor),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: textColor),
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
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Meia', style: TextStyle(fontSize: 16, color: textColor)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline, color: textColor),
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
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle_outline, color: textColor),
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
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: isDark ? Colors.white : Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: (quantidadeNormal + quantidadeMeia > 0)
                        ? () async {
                            // Ao clicar, primeiro gerar o PIX
                            setState(() => _loading = true);
                            try {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) throw Exception('Usuário não autenticado');

                              final amount = total;
                              final email = user.email ?? '';
                              final fullName = user.displayName ?? 'Comprador';

                              final payment = await criarPagamentoPix(
                                amount: amount,
                                email: email,
                                fullName: fullName,
                              );

                              // Extrair dados do retorno
                              final paymentId = payment['id']?.toString() ?? '';
                              final txn = payment['point_of_interaction'] != null
                                  ? payment['point_of_interaction']['transaction_data']
                                  : null;
                              final qrBase64 = txn != null ? txn['qr_code_base64'] : null;
                              final copiaCola = txn != null ? txn['qr_code'] : null;

                              if (!mounted) return;
                              setState(() => _loading = false);

                              // Navega para a tela PIX, passando dados e callback para salvar após confirmação
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PagamentoPixScreen(
                                    paymentId: paymentId,
                                    qrBase64: qrBase64,
                                    copiaCola: copiaCola,
                                    quantidadeNormal: quantidadeNormal,
                                    quantidadeMeia: quantidadeMeia,
                                    eventId: widget.eventId,
                                    onPagamentoAprovado: (List<String> ticketIds) {
                                      // Depois que o pagamento for confirmado e os ingressos gerados,
                                      // vamos direto para a tela de QR codes finais
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => QRCodesGeradosScreen(ticketIds: ticketIds),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            } catch (e) {
                              setState(() => _loading = false);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao criar PIX: $e')));
                            }
                          }
                        : null,
                    child: _loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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

// Tela de Pagamento PIX
class PagamentoPixScreen extends StatefulWidget {
  final String paymentId;
  final String? qrBase64;
  final String? copiaCola;
  final int quantidadeNormal;
  final int quantidadeMeia;
  final String eventId;
  final void Function(List<String> ticketIds) onPagamentoAprovado;

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
  String _statusMessage = 'Aguardando pagamento...';
  bool _paid = false;

  Future<void> _copiarCopiaCola() async {
    if (widget.copiaCola == null) return;
    await Clipboard.setData(ClipboardData(text: widget.copiaCola));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Código PIX copiado')));
  }

  Future<void> _verificarPagamento() async {
    setState(() {
      _checking = true;
      _statusMessage = 'Verificando...';
    });

    try {
      final url = Uri.parse('http://10.0.2.2:3000/payment/${widget.paymentId}');
      final resp = await http.get(url);
      if (resp.statusCode != 200) {
        throw Exception('Resposta inválida: ${resp.statusCode}');
      }
      final body = jsonDecode(resp.body);
      // dependendo do backend pode vir { ok:true, payment: {...} } ou só payment
      final payment = body['payment'] ?? body;
      final status = (payment['status'] ?? '').toString().toLowerCase();

      // verificar status que indiquem pagamento concluído
      final paid = status == 'approved' || status == 'paid' || status == 'accredited' || status == 'success' || status == 'completed';

      if (paid) {
        setState(() {
          _statusMessage = 'Pagamento confirmado!';
          _paid = true;
        });

        // gerar ingressos no firestore
        final parentState = context.findAncestorStateOfType<_IngressoScreenState>();
        // Caso não encontre, recriamos lógica: salvar diretamente aqui
        final ticketIds = await _salvarIngressosDepoisDoPagamento();
        widget.onPagamentoAprovado(ticketIds);
      } else {
        setState(() {
          _statusMessage = 'Pagamento ainda não confirmado. Status: $status';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Erro ao verificar pagamento: $e';
      });
    } finally {
      setState(() {
        _checking = false;
      });
    }
  }

  Future<List<String>> _salvarIngressosDepoisDoPagamento() async {
    // salva os ingressos no Firestore (mesma lógica da tela principal)
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userEmail = user.email ?? '';
    final ticketsCollection = FirebaseFirestore.instance.collection('tickets');
    final now = DateTime.now();
    final List<String> ticketIds = [];

    for (int i = 0; i < widget.quantidadeNormal; i++) {
      final doc = await ticketsCollection.add({
        'userId': user.uid,
        'email': userEmail,
        'tipo': 'Normal',
        'qrCodeData': 'QR-NORMAL-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': widget.eventId,
      });
      ticketIds.add(doc.id);
    }
    for (int i = 0; i < widget.quantidadeMeia; i++) {
      final doc = await ticketsCollection.add({
        'userId': user.uid,
        'email': userEmail,
        'tipo': 'Meia',
        'qrCodeData': 'QR-MEIA-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': widget.eventId,
      });
      ticketIds.add(doc.id);
    }
    return ticketIds;
  }

  @override
  Widget build(BuildContext context) {
    final qrBase64 = widget.qrBase64;
    final copia = widget.copiaCola ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Pagamento PIX')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (qrBase64 != null) ...[
              // renderiza imagem a partir de base64
              Image.memory(base64Decode(qrBase64), width: 250, height: 250),
            ] else ...[
              const SizedBox(height: 250, child: Center(child: Text('QR não disponível'))),
            ],
            const SizedBox(height: 18),
            SelectableText('Copia & cola:\n$copia', textAlign: TextAlign.center),
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
                  label: _checking ? const Text('Verificando...') : const Text('Verificar pagamento'),
                  onPressed: _checking ? null : _verificarPagamento,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(_statusMessage),
            const Spacer(),
            if (_paid)
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  onPressed: () async {
                    // caso queira forçar geração e ir para QR codes
                    final tickets = await _salvarIngressosDepoisDoPagamento();
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => QRCodesGeradosScreen(ticketIds: tickets)),
                    );
                  },
                  child: const Text('Ir para meus ingressos'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class QRCodesGeradosScreen extends StatelessWidget {
  final List<String> ticketIds;

  const QRCodesGeradosScreen({super.key, required this.ticketIds});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Seus QR Codes'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ticketIds.isEmpty
                ? const Center(child: Text('Nenhum ingresso gerado.'))
                : FutureBuilder<List<DocumentSnapshot>>(
                    future: Future.wait(ticketIds.map((id) =>
                        FirebaseFirestore.instance.collection('tickets').doc(id).get())),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final tickets = snapshot.data!;
                      return ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: tickets.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 28),
                        itemBuilder: (context, i) {
                          final ticket = tickets[i].data() as Map<String, dynamic>;
                          final tipo = ticket['tipo'] ?? '';
                          final qrData = ticket['qrCodeData'] ?? '';
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 180,
                                    gapless: false,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  const SizedBox(height: 18),
                                  Text('Tipo: $tipo', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('Código: $qrData', style: const TextStyle(fontSize: 12, color: Colors.black54)),
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
