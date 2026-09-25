// Fichier : lib/screens/stock_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/entree_stock.dart';
import '../services/base_de_donnees.dart';
import 'choisir_produit_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  @override
  Widget build(BuildContext context) {
    final produitsEnStock = BaseDeDonnees.catalogue.where((p) => p.quantiteEnStock > 0).toList();
    
    // Calcul de la valeur totale du stock
    double valeurTotaleStock = produitsEnStock.fold(0, (sum, p) => sum + (p.quantiteEnStock * p.prixDeBase));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Stock Actuel'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bandeau Valeur du Stock
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            color: Colors.orange[50],
            child: Column(
              children: [
                const Text('Valeur Totale du Stock', style: TextStyle(fontSize: 16, color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${valeurTotaleStock.toStringAsFixed(2)} DA',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Liste du stock
          Expanded(
            child: produitsEnStock.isEmpty
                ? const Center(child: Text('Votre stock est vide. Appuyez sur + pour l\'alimenter.'))
                : ListView.builder(
                    itemCount: produitsEnStock.length,
                    itemBuilder: (context, index) {
                      final produit = produitsEnStock[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: produit.imagePath.isNotEmpty
                              ? ClipOval(
                                  child: Image.file(File(produit.imagePath), width: 50, height: 50, fit: BoxFit.cover),
                                )
                              : const CircleAvatar(backgroundColor: Colors.brown, child: Icon(Icons.inventory_2, color: Colors.white)),
                          title: Text(produit.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${produit.poids} kg'),
                          trailing: Text(
                            'En stock : ${produit.quantiteEnStock}', 
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green)
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Alimenter le stock'),
        onPressed: () async {
          final resultat = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChoisirProduitScreen(catalogue: BaseDeDonnees.catalogue)),
          );

          if (resultat != null && resultat is EntreeStock) {
            setState(() {});
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${resultat.quantite}x ${resultat.produit.nom} ajoutés.'), backgroundColor: Colors.green));
            }
          }
        },
      ),
    );
  }
}