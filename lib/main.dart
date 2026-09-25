// Fichier : lib/main.dart
import 'dart:io'; // Ajout de cet import
import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/dashboard_screen.dart';
import 'services/base_de_donnees.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // On n'initialise FFI QUE si on est sur un ordinateur (Windows/Linux)
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  // Chargement des données
  await BaseDeDonnees.initialiser();
  
  runApp(const GestionCafeApp());
}

class GestionCafeApp extends StatelessWidget {
  const GestionCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telal App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}