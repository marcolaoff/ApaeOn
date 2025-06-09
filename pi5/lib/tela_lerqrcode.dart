import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TelaQRCode extends StatefulWidget {
  const TelaQRCode({Key? key}) : super(key: key);

  @override
  State<TelaQRCode> createState() => _TelaQRCodeState();
}

class _TelaQRCodeState extends State<TelaQRCode> {
  String resultado = '';
  bool carregando = false;
  bool cameraAberta = false;

  void _abrirLeitorQRCode() {
    setState(() {
      cameraAberta = true;
      resultado = '';
    });
  }

  Future<void> _processarQRCode(String code) async {
    setState(() {
      carregando = true;
      cameraAberta = false;
      resultado = '';
    });

    try {
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
                onPressed: carregando ? null : _abrirLeitorQRCode,
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
              if (cameraAberta) ...[
                const SizedBox(height: 24),
                SizedBox(
                  height: 300,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: MobileScanner(
                      onDetect: (capture) {
                        final barcode = capture.barcodes.first;
                        if (barcode.rawValue == null) return;
                        _processarQRCode(barcode.rawValue!);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() => cameraAberta = false);
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
