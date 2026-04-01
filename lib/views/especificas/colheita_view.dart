import 'package:flutter/material.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/dialogs_helper.dart';

class ColheitaView extends StatelessWidget {
  const ColheitaView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);

    final List<Map<String, String>> historicoColheita = [
      {'safra': 'Soja 2025/26', 'talhao': 'Talhão 02', 'produtividade': '72 sc/ha'},
      {'safra': 'Milho 2025', 'talhao': 'Talhão 05', 'produtividade': '145 sc/ha'},
      {'safra': 'Feijão 2025', 'talhao': 'Talhão 01', 'produtividade': '38 sc/ha'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Registro de Colheita"),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Média Geral da Propriedade",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 5),
                Text(
                  "85.4 sc/ha",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Histórico Recente",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historicoColheita.length,
              itemBuilder: (context, index) {
                final item = historicoColheita[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(item['safra']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['talhao']!),
                    trailing: Text(
                      item['produtividade']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                );
              },
            ),
          ),
        
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomButton(
              texto: "Registrar Nova Colheita",
              onPressed: () {
                DialogsHelper.showSnackBar(context, "Funcionalidade de registro aberta.");
              },
            ),
          ),
        ],
      ),
    );
  }
}