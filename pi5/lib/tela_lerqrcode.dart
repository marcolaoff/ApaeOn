import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TelaQRCode extends StatefulWidget {
  const TelaQRCode({Key? key}) : super(key: key);

  @override
  State<TelaQRCode> createState() => _TelaQRCodeState();
}

class _TelaQRCodeState extends State<TelaQRCode> {
  String resultado = '';
  bool carregando = false;

  Future<void> validarQRCode() async {
    String code = await FlutterBarcodeScanner.scanBarcode(
      "#FFFFF",
      "Cancelar",
      false,
      ScanMode.QR,
    );

    if (code == '-1') return; // Cancelado

    setState(() {
      carregando = true;
      resultado = '';
    });

    try {
      // Busca pelo ticket no Firestore pelo campo qrCodeData
      final query = await FirebaseFirestore.instance
          .collection('tickets')
          .where('qrCodeData', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() {
          resultado = 'Ingresso NÃO encontrado!';
          carregando = false;
        });
        return;
      }

      final doc = query.docs.first;
      final ticket = doc.data();

      if (ticket['status'] == 'inativo') {
        setState(() {
          resultado = 'Ingresso já foi utilizado!';
          carregando = false;
        });
        return;
      }

      // Atualiza o status para "inativo"
      await doc.reference.update({'status': 'inativo'});

      setState(() {
        resultado = 'Ingresso validado com SUCESSO!';
        carregando = false;
      });
    } catch (e) {
      setState(() {
        resultado = 'Erro ao validar ingresso!';
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Validação de Ingressos')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: carregando ? null : validarQRCode,
                icon: const Icon(Icons.qr_code),
                label: const Text('Validar Ingresso'),
              ),
              const SizedBox(height: 32),
              if (carregando) const CircularProgressIndicator(),
              if (resultado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    resultado,
                    style: TextStyle(
                      color: resultado.contains('SUCESSO')
                          ? Colors.green
                          : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
