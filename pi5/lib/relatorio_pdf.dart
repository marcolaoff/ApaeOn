import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:typed_data';

class RelatorioPDF {
  static Future<Uint8List> gerarPDF(Map<String, dynamic> relatorio) async {
    final pdf = pw.Document();

    final eventos = relatorio["eventos"] as List<dynamic>;
    final totalGeral = relatorio["total_geral"] as double;

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Relatório Geral de Eventos",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  )),
              pw.SizedBox(height: 20),

              /// Lista de eventos
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Evento")),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Vendidos")),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Não vendidos")),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text("Arrecadado")),
                    ],
                  ),
                  ...eventos.map((e) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(e["evento"])),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text("${e['vendidos']}")),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text("${e['nao_vendidos']}")),
                        pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                                "R\$ ${e['arrecadado'].toStringAsFixed(2)}")),
                      ],
                    );
                  }).toList(),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                "Total geral arrecadado: R\$ ${totalGeral.toStringAsFixed(2)}",
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
