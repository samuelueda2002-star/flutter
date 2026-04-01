import 'package:flutter/material.dart';

class SafrasListView extends StatelessWidget {
  const SafrasListView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);

    
    final List<Map<String, String>> safrasMockadas = [
      {'talhao': 'Talhão 01', 'cultura': 'Soja', 'status': 'Em Crescimento', 'area': '50 ha'},
      {'talhao': 'Talhão 05', 'cultura': 'Milho', 'status': 'Pronto para Colheita', 'area': '30 ha'},
      {'talhao': 'Talhão 02', 'cultura': 'Cana-de-Açúcar', 'status': 'Maturação', 'area': '120 ha'},
      {'talhao': 'Talhão 08', 'cultura': 'Soja', 'status': 'Plantio Recente', 'area': '45 ha'},
      {'talhao': 'Talhão 03', 'cultura': 'Feijão', 'status': 'Colhido', 'area': '15 ha'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monitoramento de Safras"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: safrasMockadas.length,
        itemBuilder: (context, index) {
          final safra = safrasMockadas[index];
          
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor.withOpacity(0.1),
                child: const Icon(Icons.grass, color: primaryColor),
              ),
              title: Text(
                safra['talhao']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${safra['cultura']} - Área: ${safra['area']}"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(safra['status']!).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  safra['status']!,
                  style: TextStyle(
                    color: _getStatusColor(safra['status']!),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Detalhes do ${safra['talhao']} selecionado."),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }


  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pronto para Colheita': return Colors.green;
      case 'Em Crescimento': return Colors.blue;
      case 'Colhido': return Colors.grey;
      default: return Colors.orange;
    }
  }
}