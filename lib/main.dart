import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_screen.dart'; // IMPORTANTE: certifique-se de que esse arquivo existe

void main() {
  runApp(const AlertaEnchentesApp());
}

class AlertaEnchentesApp extends StatelessWidget {
  const AlertaEnchentesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Alerta Enchentes SP',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyan,
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyan,
          secondary: Colors.greenAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFF181C24),
      ),
      // REGISTRE AS ROTAS AQUI
      routes: {
        '/': (context) => const HomeScreen(),
        '/chat': (context) =>
            const ChatScreen(), // <- AQUI ESTÁ A ROTA QUE FALTAVA
      },
    );
  }
}


// adb emu geo fix -46.8796 -23.5054  Barueri
// adb emu geo fix -46.6333 -23.5505  Bras
// adb emu geo fix -46.6832 -23.5254  Lapa
