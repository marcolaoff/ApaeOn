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
  bool processando = false;

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

      final status = (ticket['status'] ?? '').toString().toLowerCase();

      if (status == 'inativo') {
        setState(() {
          resultado = 'Ingresso já foi utilizado!';
          carregando = false;
        });
        return;
      }

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor =
        theme.textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Colors.black);
    final cardColor = theme.cardColor;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: theme.appBarTheme.iconTheme ?? IconThemeData(color: textColor),
        elevation: 0,
        title: Text(
          'Validação de Ingressos',
          style: theme.appBarTheme.titleTextStyle ??
              TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cardColor,
                  foregroundColor: textColor,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: carregando ? null : _abrirLeitorQRCode,
                icon: Icon(Icons.qr_code, color: textColor),
                label: Text(
                  'Validar Ingresso',
                  style: TextStyle(color: textColor),
                ),
              ),

              const SizedBox(height: 32),

              if (carregando) const CircularProgressIndicator(),

              if (resultado.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    resultado,
                    style: TextStyle(
                      color: resultado.contains('SUCESSO') ? Colors.green : Colors.red,
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
                      fit: BoxFit.contain,
                      onDetect: (capture) {
                        final barcodes = capture.barcodes;
                        if (barcodes.isEmpty) return;

                        final barcode = barcodes.first;
                        final value = barcode.rawValue;

                        if (value == null || processando) return;

                        // evita múltiplas leituras seguidas
                        processando = true;
                        _processarQRCode(value).whenComplete(() {
                          processando = false;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      cameraAberta = false;
                      resultado = '';
                    });
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
