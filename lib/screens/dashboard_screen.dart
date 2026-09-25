// Fichier : lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'stock_screen.dart';
import 'credit_screen.dart';
import 'clients_screen.dart';
import 'caisse_screen.dart';
import 'ventes_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Café Tellal - Accueil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          children: [
            _buildMenuCard(context, 'Stock', Icons.inventory, Colors.orange),
            _buildMenuCard(context, 'Ventes', Icons.point_of_sale, Colors.green),
            _buildMenuCard(context, 'Clients', Icons.people, Colors.blue),
            _buildMenuCard(context, 'Crédit & Paiements', Icons.money_off, Colors.red),
            _buildMenuCard(context, 'Caisse', Icons.account_balance_wallet, Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (title == 'Stock') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const StockScreen()));
          } else if (title == 'Ventes') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const VentesScreen()));
          } else if (title == 'Clients') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsScreen()));
          } else if (title == 'Crédit & Paiements') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreditScreen()));
          } else if (title == 'Caisse') {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CaisseScreen()));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}