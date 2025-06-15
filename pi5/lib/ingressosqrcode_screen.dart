import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class IngressosQRCodesScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Ingressos: $nomeEvento',
          style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? textColor),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: Theme.of(context).appBarTheme.iconTheme ?? IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: user == null
          ? Center(child: Text('Usuário não autenticado', style: TextStyle(color: textColor)))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tickets')
                  .where('userId', isEqualTo: user.uid)
                  .where('eventId', isEqualTo: eventId)
                  // .where('status', isEqualTo: 'ativo') // <-- REMOVIDO para pegar todos!
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Erro ao carregar ingressos.', style: TextStyle(color: textColor)),
                  );
                }
                final tickets = snapshot.data?.docs ?? [];
                if (tickets.isEmpty) {
                  return Center(
                    child: Text('Nenhum ingresso disponível.', style: TextStyle(color: textColor)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 28),
                  itemBuilder: (context, i) {
                    final ticket = tickets[i].data() as Map<String, dynamic>;
                    final tipo = ticket['tipo'] ?? '';
                    final status = ticket['status'] ?? '';
                    final qrData = ticket['qrCodeData'] ?? '';

                    // Visualização diferenciada para ingresso inativo
                    final isAtivo = status == 'ativo';

                    return Opacity(
                      opacity: isAtivo ? 1 : 0.55,
                      child: Card(
                        elevation: 2,
                        color: cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                                // Se quiser esconder o QR de inativos, pode usar:
                                // foregroundColor: isAtivo ? null : Colors.grey,
                              ),
                              const SizedBox(height: 18),
                              Text(
                                'Tipo: $tipo',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  decoration: isAtivo ? null : TextDecoration.lineThrough,
                                ),
                              ),
                              Text(
                                'Status: ${isAtivo ? "Ativo" : "Inativo"}',
                                style: TextStyle(
                                  color: isAtivo ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text('Código: $qrData',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
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
