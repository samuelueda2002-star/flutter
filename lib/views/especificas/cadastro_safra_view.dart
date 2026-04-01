import 'package:flutter/material.dart';

class CadastroSafraView extends StatefulWidget {
  const CadastroSafraView({super.key});

  @override
  State<CadastroSafraView> createState() => _CadastroSafraViewState();
}

class _CadastroSafraViewState extends State<CadastroSafraView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Plantio")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(decoration: const InputDecoration(labelText: 'Nome do Talhão', border: OutlineInputBorder())),
              const SizedBox(height: 15),
              DropdownButtonFormField(
                items: const [DropdownMenuItem(value: 'Soja', child: Text('Soja')), DropdownMenuItem(value: 'Milho', child: Text('Milho'))],
                onChanged: (val) {},
                decoration: const InputDecoration(labelText: 'Cultura', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 15),
              TextFormField(decoration: const InputDecoration(labelText: 'Área (Hectares)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0A747C), minimumSize: const Size(double.infinity, 50)),
                child: const Text("Salvar Safra", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}