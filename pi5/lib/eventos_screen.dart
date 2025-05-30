import 'package:flutter/material.dart';

class EventosScreen extends StatelessWidget {
  const EventosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.black54,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: 'Eventos'),
              Tab(text: 'Meus Ingressos'),
              Tab(text: 'Configurações'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            EventosTab(),
            MeusIngressosTab(), // agora sua aba personalizada!
            ConfiguracoesTab(),
          ],
        ),
      ),
    );
  }
}

// EventosTab (mesmo do exemplo anterior)
class EventosTab extends StatelessWidget {
  const EventosTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      children: [
        const Text(
          'Evento 01',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        const Text(
          'Data : 00/00/00 as 00:00 hrs',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 18),
        Container(
          width: 140,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.image,
            size: 56,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Nome do evento',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 2),
        const Text(
          'Evento tal para tal coisa de tal coisa',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 96,
          height: 34,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(fontSize: 15),
            ),
            onPressed: () {},
            child: const Text('Detalhes'),
          ),
        ),
      ],
    );
  }
}

// MeusIngressosTab adaptado
class MeusIngressosTab extends StatelessWidget {
  const MeusIngressosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      children: [
        Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black38,
                      child: Text('A', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Evento 01',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Data-hora',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.more_vert, color: Colors.black54),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Orgia de Traveco',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Detalhes',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        Align(
          alignment: Alignment.centerRight,
          child: SizedBox(
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text('Ver Ingressos', style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Exemplo simples para configurações (pode editar depois)
class ConfiguracoesTab extends StatelessWidget {
  const ConfiguracoesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aqui vão as configurações do aplicativo',
        style: TextStyle(fontSize: 18, color: Colors.black54),
      ),
    );
  }
}
