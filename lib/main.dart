import 'package:flutter/material.dart';
import 'pages/homepage.dart';
import 'pages/login_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Verified backend core engine import link
import 'pet/pet_store_controller.dart';
import 'package:provider/provider.dart';
import 'responsive/responsive_layout.dart';
import 'responsive/mobile_body.dart';
import 'responsive/desktop_body.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🚀 Initialize the Supabase Connection with your exact live keys
  await Supabase.initialize(
    url: 'https://ipafrcpbzzvhfmnlycdg.supabase.co',
    anonKey: 'sb_publishable_JZUKji-uU5yoA-KSlDMMow_nJpbNnIH',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => PetStoreController(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}