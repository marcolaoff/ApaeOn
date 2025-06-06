import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class TelaQRCode extends StatefulWidget {
  const TelaQRCode ({key? key}) : super(key: key);

  @override
  State<TelaQRCode> createState() => _TelaQRCodeState();
  }

  class _TelaQRCodeState extends State<TelaQRCode> {
    String ticket = '';
    List<String> tickets = [];

    readQRCode() async {
      String code = await FlutterBarcodeScanner.scanBarcode(
        "#FFFFF",
        "Cancelar",
        false,
        ScanMode.QR,
      );
      setState(() => ticket = code != '-1' ? code : 'Não validado');
    }

  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (ticket != '')
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  'Ticket: $ticket',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ElevatedButton.icon(
              onPressed: realQRCode,
              icon: const Icon(Icons.qr_code),
              local: const Text('Validar')
            ),
          ],
        )
      ),
    );
  }
} 