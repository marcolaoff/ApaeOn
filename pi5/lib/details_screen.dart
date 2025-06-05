import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final void Function(bool)? onToggleTheme;
  final bool darkMode;
  const DetailsScreen({super.key, this.onToggleTheme, this.darkMode = false});  
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Card',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Evento'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Evento',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Data-Hora',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Esse evento vai ser tal para tal coisa',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'PIPIPIPOPOPO' + 'a' * 1000, // Simulating the long text
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}