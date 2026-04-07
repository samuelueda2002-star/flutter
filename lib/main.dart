import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:device_preview/device_preview.dart';
import 'controllers/auth_controller.dart';
import 'controllers/propriedade_controller.dart';
import 'controllers/safra_controller.dart';
import 'controllers/insumo_controller.dart';
import 'views/auth/login_view.dart';
import 'views/auth/cadastro_view.dart';
import 'views/auth/recuperacao_view.dart';
import 'views/home/home_view.dart';
import 'views/sobre/sobre_view.dart';
import 'views/especificas/propriedades_view.dart';
import 'views/especificas/safras_list_view.dart';
import 'views/especificas/cadastro_safra_view.dart';
import 'views/especificas/insumos_view.dart';
import 'views/especificas/despesas_view.dart';
import 'views/especificas/colheita_view.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, 
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthController()),
          ChangeNotifierProvider(create: (_) => PropriedadeController()),
          ChangeNotifierProvider(create: (_) => SafraController()),
          ChangeNotifierProvider(create: (_) => InsumoController()),
        ],
        child: const RuralApp(),
      ),
    ),
  );
}

class RuralApp extends StatelessWidget {
  const RuralApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF0A747C);

    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      title: 'Gestão Rural UNAERP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryGreen,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginView(),
        '/cadastro': (context) => const CadastroView(),
        '/recuperar': (context) => const RecuperacaoView(),
        '/home': (context) => const HomeView(),
        '/sobre': (context) => const SobreView(),
        '/propriedades': (context) => const PropriedadesView(),
        '/safras': (context) => const SafrasListView(),
        '/cadastro_safra': (context) => const CadastroSafraView(),
        '/insumos': (context) => const InsumosView(),
        '/financeiro': (context) => const DespesasView(),
        '/colheita': (context) => const ColheitaView(),
      },
    );
  }
}