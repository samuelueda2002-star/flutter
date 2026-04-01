import 'package:flutter/material.dart';

class PropriedadesView extends StatelessWidget {
  const PropriedadesView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);
    final List<String> fazendas = ['Fazenda Santa Luzia', 'Sítio Novo Horizonte', 'Estância Ouro Verde'];

    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Propriedades"), backgroundColor: primaryColor, foregroundColor: Colors.white),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: fazendas.length,
        itemBuilder: (context, index) {
          return Card(
            color: primaryColor.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.landscape, size: 40, color: primaryColor),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(fazendas[index], textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}