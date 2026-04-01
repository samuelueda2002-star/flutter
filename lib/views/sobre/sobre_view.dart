import 'package:flutter/material.dart';

class SobreView extends StatelessWidget {
  const SobreView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0A747C);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sobre o Aplicativo"),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.info_outline,
                size: 80,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            
            
            const Text(
              "Objetivo",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 8),
            const Text(
              "Este aplicativo foi desenvolvido para auxiliar o produtor rural na gestão de suas propriedades, "
              "safras e insumos, proporcionando um controle digital eficiente do campo à colheita.",
              style: TextStyle(fontSize: 16),
            ),
            
            const Divider(height: 40),

            
            const Text(
              "Equipe de Desenvolvimento",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 8),
            const Text("• André Luiz Lourenço", style: TextStyle(fontSize: 16)),
            const Text("• Samuel Eiji Ueda", style: TextStyle(fontSize: 16)),
            
            const SizedBox(height: 24),
            
            const Text(
              "Informações Institucionais",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            const SizedBox(height: 12),
            
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: const [
                TableRow(children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Instituição:", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("UNAERP")),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Professor:", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Dr. Edilson Carlos Caritá")),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Curso:", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Engenharia de Software (7ª Etapa)")),
                ]),
                TableRow(children: [
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("Versão:", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Text("1.0.0")),
                ]),
              ],
            ),
            
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Ribeirão Preto, 2026",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}