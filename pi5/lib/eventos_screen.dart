import 'package:flutter/material.dart';
import 'package:pi5/details_screen.dart';
import 'perfil_screen.dart'; // Importe sua tela de perfil aqui

class EventosScreen extends StatelessWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;
  const EventosScreen({super.key, this.onToggleTheme, this.darkMode = false});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? Colors.white,
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
        body: TabBarView(
          children: [
            const EventosTab(),
            const MeusIngressosTab(),
            ConfiguracoesTab(
              onToggleTheme: onToggleTheme,
              darkMode: darkMode,
            ),
          ],
        ),
      ),
    );
  }
}

// EventosTab (sem alteração)
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context)=> DetailsScreen(
                )
                ),
              );
            },
            child: const Text('Detalhes'),
            
          ),
        ),
      ],
    );
  }
}

// MeusIngressosTab (sem alteração)
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
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16, ),
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
        const SizedBox(height: 12),
        SizedBox(
            width: 96,
            height:34,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side:const BorderSide(color: Colors.black26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontSize: 15),
              ),
              onPressed: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Text('Ver Ingressos', style: TextStyle(fontSize: 15)),
              ),
            ),
          ),
      ],
    );
  }
}

// ConfiguracoesTab recebe agora os parâmetros
class ConfiguracoesTab extends StatefulWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;
  const ConfiguracoesTab({super.key, this.onToggleTheme, this.darkMode = false});

  @override
  State<ConfiguracoesTab> createState() => _ConfiguracoesTabState();
}

class _ConfiguracoesTabState extends State<ConfiguracoesTab> {
  late bool modoEscuro;

  @override
  void initState() {
    super.initState();
    modoEscuro = widget.darkMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 36, left: 18, right: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modo escuro
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "MODO ESCURO",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Switch(
                        value: modoEscuro,
                        activeColor: Colors.black,
                        onChanged: (val) {
                          setState(() {
                            modoEscuro = val;
                          });
                          if (widget.onToggleTheme != null) {
                            widget.onToggleTheme!(val);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Perfil Usuário
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PerfilUsuarioScreen()),
                      );
                    },
                    child: const Text(
                      "PERFIL USUARIO",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: (){
                      showDialog(
                        context: context, 
                        builder: (BuildContext context){
                          return Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Versão do app : Teste 1.0.3'),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Fechar'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                        );
                    },
                    child: Text("VERSÃO DO APLICATIVO", 
                    style:TextStyle(fontWeight: FontWeight.bold, fontSize: 15,)),
                  ),
                    const SizedBox(height: 32),


                  const Text(
                    "LOCALIZAÇÃO",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  
                ],
              ),
            ),

            // Botão Sair
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: SizedBox(
                  width: 90,
                  height: 36,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Colors.black12),
                    ),
                    onPressed: () {
                      // Implemente a ação de logout aqui
                    },
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
