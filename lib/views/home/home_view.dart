import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../auth/login_view.dart';
import '../especificas/safras_list_view.dart';
import '../especificas/cadastro_propriedade_view.dart';
import '../especificas/insumos_view.dart';
import '../especificas/despesas_view.dart';
import '../especificas/colheita_view.dart';
import '../sobre/sobre_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthController _authController = AuthController();

  // Função para executar o Logout com segurança
  void _fazerLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Saída'),
        content: const Text('Deseja realmente terminar a sessão no aplicativo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              await _authController.sair(); // Executa o logout no Firebase Auth
              
              if (!mounted) return;
              // Redireciona para a tela de login limpando o histórico de rotas
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginView()),
                (route) => false,
              );
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para construir os cartões do Dashboard de forma limpa
  Widget _buildDashboardCard({
    required String titulo,
    required IconData icone,
    required Color cor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icone, size: 40, color: cor),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agro App - Dashboard'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Botão de Logout no canto superior direito
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair da Conta',
            onPressed: _fazerLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mensagem de boas-vindas simples
              const Text(
                'Bem-vindo ao Campo!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'Selecione uma das opções abaixo para gerir o seu negócio:',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Grid que organiza todos os módulos dinamicamente
              GridView.count(
                crossAxisCount: 2, // 2 colunas
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(), // Grid rola junto com a Column
                children: [
                  // 1. Módulo de Safras
                  _buildDashboardCard(
                    titulo: 'Safras',
                    icone: Icons.agriculture,
                    cor: Colors.green,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SafrasListView()),
                    ),
                  ),

                  // 2. Módulo de Propriedades
                //  _buildDashboardCard(
                //    titulo: 'Propriedades',
                //    icone: Icons.landscape,
                 //   cor: Colors.brown,
                 //   onTap: () => Navigator.push(
                    //  context,
                    //  MaterialPageRoute(builder: (context) => const propriedades_view()),
                //    )//,
                //  ),

                  // 3. Módulo de Insumos
                  _buildDashboardCard(
                    titulo: 'Insumos',
                    icone: Icons.inventory_2,
                    cor: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InsumosView()),
                    ),
                  ),

                  // 4. Módulo de Colheitas
                  _buildDashboardCard(
                    titulo: 'Colheitas',
                    icone: Icons.shopping_basket,
                    cor: Colors.orange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ColheitaView()),
                    ),
                  ),

                  // 5. Módulo de Despesas Financeiras
                  _buildDashboardCard(
                    titulo: 'Despesas',
                    icone: Icons.attach_money,
                    cor: Colors.red,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DespesasView()),
                    ),
                  ),

                  // 6. Módulo Sobre o App
                  _buildDashboardCard(
                    titulo: 'Sobre',
                    icone: Icons.info_outline,
                    cor: Colors.teal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SobreView()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}