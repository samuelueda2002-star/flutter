import 'package:flutter/material.dart';

class InsumosView extends StatelessWidget {
  const InsumosView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> estoque = [
      {'nome': 'Fertilizante NPK', 'qtd': '500 kg'},
      {'nome': 'Semente Soja RR', 'qtd': '20 sacas'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Estoque de Insumos")),
      body: ListView.separated(
        itemCount: estoque.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          leading: const Icon(Icons.inventory_2, color: Color(0xFF0A747C)),
          title: Text(estoque[index]['nome']!),
          trailing: Text(estoque[index]['qtd']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
        ),
      ),
    );
  }
}