import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SobreApaeScreen extends StatelessWidget {
  const SobreApaeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Sobre a APAE",
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        backgroundColor: theme.appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LOGO
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/logo.jpg',
                height: 120,
                fit: BoxFit.cover,
                semanticLabel: 'Logo da APAE de Itapira',
              ),
            ),

            const SizedBox(height: 22),

            // TÍTULO
            Text(
              "APAE de Itapira",
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // DESCRIÇÃO
            Text(
              "A APAE (Associação de Pais e Amigos dos Excepcionais) é uma instituição "
              "sem fins lucrativos dedicada ao atendimento, inclusão e desenvolvimento "
              "de pessoas com deficiência intelectual e múltipla.\n\n"
              "Na cidade de Itapira, a APAE atua oferecendo educação especializada, "
              "serviços de saúde, apoio social e atividades que promovem autonomia, "
              "qualidade de vida e inclusão, contando sempre com a colaboração da "
              "população e de eventos beneficentes como o ApaeOn.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 26),

            // BOTÃO SITE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.cardColor,
                  foregroundColor: textColor,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: theme.brightness == Brightness.dark
                        ? Colors.white12
                        : Colors.black12,
                  ),
                ),
                onPressed: () async {
                  final url = Uri.parse("https://www.apaeitapira.org.br");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                child: const Text(
                  "Acessar site oficial",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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
