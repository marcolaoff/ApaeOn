import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ingresso_screen.dart';

class DetailsScreen extends StatelessWidget {
  final String eventId;
  final void Function(bool)? onToggleTheme;
  final bool darkMode;

  const DetailsScreen({
    super.key,
    required this.eventId,
    this.onToggleTheme,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = darkMode;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Detalhes do Evento',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.titleTextStyle?.color ?? (isDark ? Colors.white : Colors.black),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).appBarTheme.iconTheme?.color ?? (isDark ? Colors.white : Colors.black),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                'Evento não encontrado',
                style: TextStyle(color: textColor),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final nome = data['nome'] ?? 'Sem nome';
          final local = data['local'] ?? 'Local não informado';
          final descricao = data['descrição'] ?? '';
          final infoAdicionais = data['Informações Adicionais'] ?? '';
          final dataTimestamp = data['data'];
          final imageUrl = data['imageUrl'] as String?;
          final preco = (data['preco'] as num?)?.toDouble() ?? 0.0; // <-- Aqui pega o preço

          String dataFormatada = '';
          if (dataTimestamp != null && dataTimestamp is Timestamp) {
            final date = dataTimestamp.toDate();
            dataFormatada =
              '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} às ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              child: Card(
                elevation: 3,
                color: cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.blueAccent,
                            child: const Icon(Icons.event, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nome,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Data: $dataFormatada',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Local: $local',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Valor: R\$ ${preco.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // Imagem do evento
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 56,
                                        color: isDark ? Colors.white54 : Colors.grey,
                                      ),
                                    ),
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(child: CircularProgressIndicator());
                                  },
                                ),
                              )
                            : Center(
                                child: Icon(Icons.image, size: 56, color: isDark ? Colors.white54 : Colors.grey),
                              ),
                      ),
                      const SizedBox(height: 22),

                      // Descrição
                      Text(
                        'Descrição',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        descricao,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Informações adicionais
                      Text(
                        'Informações adicionais',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        infoAdicionais,
                        style: TextStyle(
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Botão comprar ingressos
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark ? Colors.deepPurpleAccent : Colors.white,
                            foregroundColor: isDark ? Colors.white : Colors.black,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.black12),
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => IngressoScreen(
                                  eventId: eventId,
                                  onToggleTheme: onToggleTheme,
                                  darkMode: darkMode,
                                ),
                              ),
                            );
                          },
                          child: const Text('Comprar Ingressos'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
