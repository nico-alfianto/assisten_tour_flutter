import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- TAMBAH INI
import 'data/tour_store.dart';
import 'pages/main_page.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider( // <-- BUNGKUS PAKE INI
      create: (_) => TourStore(),
      child: const AssistantTour(),
    ),
  );
}

class AssistantTour extends StatelessWidget {
  const AssistantTour({super.key});

  @override
  Widget build(BuildContext context) {
    final tourStore = Provider.of<TourStore>(context); // <-- GANTI INI
    final isLoggedIn = tourStore.currentUser != null;
    
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Assistant Tour",
      theme: ThemeData(
        primaryColor: const Color(0xFF0F766E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F766E),
        ),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const MainPage() : const WelcomePage(),
    );
  }
}
