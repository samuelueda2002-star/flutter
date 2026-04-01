import 'package:flutter/material.dart';

class DespesasView extends StatelessWidget {
  const DespesasView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> despesas = [
      {'item': 'Diesel Trator', 'valor': 1250.00, 'data': '15/03/2026'},
      {'item': 'Manutenção Grade', 'valor': 850.50, 'data': '10/03/2026'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Controle Financeiro")),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF0A747C).withOpacity(0.1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Total do Mês:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("R\$ 2.100,50", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: despesas.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(despesas[index]['item']),
                subtitle: Text(despesas[index]['data']),
                trailing: Text("R\$ ${despesas[index]['valor']}", style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}