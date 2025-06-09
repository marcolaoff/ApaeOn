import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IngressoScreen extends StatefulWidget {
  final String eventId; // Novo parâmetro!

  const IngressoScreen({super.key, required this.eventId});

  @override
  State<IngressoScreen> createState() => _IngressoScreenState();
}

class _IngressoScreenState extends State<IngressoScreen> {
  int quantidadeNormal = 0;
  int quantidadeMeia = 0;

  // Valor do ingresso inteira (exemplo: 15.00)
  final double valorIngresso = 15.0;

  // Função para salvar ingressos no Firestore
  Future<void> salvarIngressosNoFirestore({
    required int quantidadeNormal,
    required int quantidadeMeia,
    required String eventId, // Recebe o eventId
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ticketsCollection = FirebaseFirestore.instance.collection('tickets');
    final now = DateTime.now();

    // Crie os tickets "Normal"
    for (int i = 0; i < quantidadeNormal; i++) {
      await ticketsCollection.add({
        'userId': user.uid,
        'tipo': 'Normal',
        'qrCodeData': 'QR-NORMAL-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': eventId, // Salva o eventId aqui!
      });
    }

    // Crie os tickets "Meia"
    for (int i = 0; i < quantidadeMeia; i++) {
      await ticketsCollection.add({
        'userId': user.uid,
        'tipo': 'Meia',
        'qrCodeData': 'QR-MEIA-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': eventId, // Salva o eventId aqui!
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double valorMeia = valorIngresso / 2;
    final double total = (quantidadeNormal * valorIngresso) + (quantidadeMeia * valorMeia);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Ingresso', style: TextStyle(color: Colors.black)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantidade de Ingressos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // Ingresso Normal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Normal',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
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
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),

            // Ingresso Meia
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meia',
                  style: TextStyle(fontSize: 16),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
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
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),

            const Spacer(),

            // Resumo Total
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'R\$ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Botão Confirmar Compra
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Colors.black12),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: (quantidadeNormal + quantidadeMeia > 0)
                    ? () async {
                        await salvarIngressosNoFirestore(
                          quantidadeNormal: quantidadeNormal,
                          quantidadeMeia: quantidadeMeia,
                          eventId: widget.eventId, // Aqui você passa o eventId!
                        );
                        if (!mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QRCodesScreen(
                              quantidadeNormal: quantidadeNormal,
                              quantidadeMeia: quantidadeMeia,
                            ),
                          ),
                        );
                      }
                    : null,
                child: const Text('Confirmar Compra'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QRCodesScreen extends StatelessWidget {
  final int quantidadeNormal;
  final int quantidadeMeia;

  const QRCodesScreen({
    super.key,
    required this.quantidadeNormal,
    required this.quantidadeMeia,
  });

  @override
  Widget build(BuildContext context) {
    final total = quantidadeNormal + quantidadeMeia;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seus QR Codes', style: TextStyle(color: Colors.black)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          for (int i = 0; i < quantidadeNormal; i++)
            QrIngressoWidget(
              index: i + 1,
              tipo: 'Normal',
            ),
          for (int i = 0; i < quantidadeMeia; i++)
            QrIngressoWidget(
              index: i + 1,
              tipo: 'Meia',
            ),
          if (total == 0)
            const Center(child: Text("Nenhum ingresso selecionado.")),
          const SizedBox(height: 30),
          // Botão voltar
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
              label: const Text(
                'Voltar aos eventos',
                style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blueAccent,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.blueAccent),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class QrIngressoWidget extends StatelessWidget {
  final int index;
  final String tipo;

  const QrIngressoWidget({super.key, required this.index, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final String qrData = 'https://fatecitapira.cps.sp.gov.br';
    return Column(
      children: [
        QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: 200.0,
          gapless: false,
        ),
        const SizedBox(height: 16),
        Text(
          'Ingresso $index - $tipo',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
