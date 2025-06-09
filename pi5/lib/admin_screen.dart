import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tela_lerqrcode.dart';

class AdminScreen extends StatelessWidget {
  final String nome;
  final String email;

  const AdminScreen({super.key, required this.nome, required this.email});

  // Abre o PDF gerado pela VM (relatório do evento)
  Future<void> _abrirRelatorioPDF(BuildContext context, String eventId) async {
    final url = Uri.parse('http://35.247.243.145:5000/relatorio/$eventId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final pdfUrl = data['pdf_url'];
      final pdfUri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(pdfUri)) {
        await launchUrl(pdfUri, mode: LaunchMode.externalApplication);
      } else {
        _mostrarErro(context, 'Não foi possível abrir o PDF.');
      }
    } else {
      _mostrarErro(context, 'Erro ao gerar relatório.');
    }
  }

  // Abre um PDF público externo para teste
  Future<void> _abrirPDFExterno(BuildContext context) async {
    // Exemplo de PDF público (Google Docs ou outro PDF acessível)
    final testUrl = 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf';
    final uri = Uri.parse(testUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      _mostrarErro(context, 'Não foi possivel abrir o PDF de teste.');
    }
  }

  void _mostrarErro(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Painel do Administrador', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo, $nome!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)),
            const SizedBox(height: 8),
            Text(email, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 38),
            // Botão de validação de ingressos
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text('Validar Ingressos', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaQRCode()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Botão de relatório PDF (chama a VM)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Relatório PDF', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: () {
                  _abrirRelatorioPDF(context, 'JoEN2fUI695ZGE8oFnYM'); // Troque pelo eventId correto!
                },
              ),
            ),
            const SizedBox(height: 16),
            // Botão para teste externo de PDF
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: const Text('Testar PDF Externo', style: TextStyle(fontSize: 18, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                onPressed: () {
                  _abrirPDFExterno(context);
                },
              ),
            ),
            const Spacer(),
            // Botão sair
            Center(
              child: SizedBox(
                width: 120,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  child: const Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
