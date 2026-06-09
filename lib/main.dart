import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Importante para verificar se é modo de debug
import 'package:firebase_core/firebase_core.dart';
import 'package:device_preview/device_preview.dart'; // Import do preview
import 'firebase_options.dart'; 
import 'views/auth/login_view.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); 
  
  // Envolvemos o runApp com o DevicePreview
  runApp(
    DevicePreview(
      // O preview só ficará ativo enquanto você estiver desenvolvendo (debug).
      // Quando gerar o app final para as lojas (release), ele some sozinho.
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Adicionamos estas duas linhas para o preview controlar o tamanho e idioma
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      title: 'App Agrícola',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginView(), 
      debugShowCheckedModeBanner: false,
    );
  }
}