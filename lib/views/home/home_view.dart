import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    
    final List<Map<String, dynamic>> modulos = [
      {'titulo': 'Propriedades', 'icon': Icons.landscape, 'route': '/propriedades'},
      {'titulo': 'Safras', 'icon': Icons.agriculture, 'route': '/safras'},
      {'titulo': 'Insumos', 'icon': Icons.inventory, 'route': '/insumos'},
      {'titulo': 'Financeiro', 'icon': Icons.monetization_on, 'route': '/financeiro'},
      {'titulo': 'Colheita', 'icon': Icons.compost, 'route': '/colheita'},
      {'titulo': 'Sobre', 'icon': Icons.info, 'route': '/sobre'}, // RF004
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Painel do Produtor"),
        backgroundColor: const Color(0xFF0A747C),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pushReplacementNamed(context, '/'),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 colunas
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: modulos.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () => Navigator.pushNamed(context, modulos[index]['route']),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(modulos[index]['icon'], size: 50, color: const Color(0xFF0A747C)),
                    const SizedBox(height: 10),
                    Text(modulos[index]['titulo'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}