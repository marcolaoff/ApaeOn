import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class IngressosQRCodesScreen extends StatelessWidget {
  final String nomeEvento;
  final List<Map<String, dynamic>> tickets;

  const IngressosQRCodesScreen({
    super.key,
    required this.nomeEvento,
    required this.tickets,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ingressos: $nomeEvento', style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 28),
        itemBuilder: (context, i) {
          final ticket = tickets[i];
          final tipo = ticket['tipo'] ?? '';
          final status = ticket['status'] ?? '';
          final qrData = ticket['qrCodeData'] ?? '';

          return Card(
            elevation: 2,
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
                  ),
                  const SizedBox(height: 18),
                  Text('Tipo: $tipo', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Status: $status', style: const TextStyle(color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text('Código: $qrData', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
