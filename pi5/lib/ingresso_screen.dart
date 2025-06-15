import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> salvarIngressosNoFirestore({
    required int quantidadeNormal,
    required int quantidadeMeia,
    required String eventId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userEmail = user.email ?? '';
    final ticketsCollection = FirebaseFirestore.instance.collection('tickets');
    final now = DateTime.now();

    for (int i = 0; i < quantidadeNormal; i++) {
      await ticketsCollection.add({
        'userId': user.uid,
        'email': userEmail,
        'tipo': 'Normal',
        'qrCodeData': 'QR-NORMAL-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': eventId,
      });
    }
    for (int i = 0; i < quantidadeMeia; i++) {
      await ticketsCollection.add({
        'userId': user.uid,
        'email': userEmail,
        'tipo': 'Meia',
        'qrCodeData': 'QR-MEIA-${user.uid}-${now.millisecondsSinceEpoch}-$i',
        'criacao': now,
        'status': 'ativo',
        'eventId': eventId,
      });
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

                // Ingresso Normal
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

                // Ingresso Meia
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

                // Resumo Total
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

                // Botão Confirmar Compra
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
                            await salvarIngressosNoFirestore(
                              quantidadeNormal: quantidadeNormal,
                              quantidadeMeia: quantidadeMeia,
                              eventId: widget.eventId,
                            );
                            if (!mounted) return;
                            // Aqui você pode redirecionar para a tela de QR Codes, se desejar.
                          }
                        : null,
                    child: const Text('Confirmar Compra'),
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
