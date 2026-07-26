import 'package:flutter/material.dart';
import 'data/tour_store.dart';
import 'pages/main_page.dart';
import 'pages/welcome_page.dart';

void main() {
  runApp(const AssistantTour());
}

class AssistantTour extends StatelessWidget {
  const AssistantTour({super.key});

  @override
  Widget build(BuildContext context) {
    final tourStore = TourStore();
    return ListenableBuilder(
      listenable: tourStore,
      builder: (context, _) {
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
      },
    );
  }
}
