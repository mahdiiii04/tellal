// Fichier : lib/screens/choisir_produit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/produit.dart';
import '../models/entree_stock.dart';
import '../services/base_de_donnees.dart';
import 'ajouter_produit_screen.dart';
import 'ajouter_stock_screen.dart';

class ChoisirProduitScreen extends StatefulWidget {
  final List<Produit> catalogue;

  const ChoisirProduitScreen({super.key, required this.catalogue});

  @override
  State<ChoisirProduitScreen> createState() => _ChoisirProduitScreenState();
}

class _ChoisirProduitScreenState extends State<ChoisirProduitScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un produit'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: widget.catalogue.isEmpty
          ? const Center(child: Text('Le catalogue est vide. Créez un nouveau produit.'))
          : ListView.builder(
              itemCount: widget.catalogue.length,
              itemBuilder: (context, index) {
                final produit = widget.catalogue[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: produit.imagePath.isNotEmpty
                        ? ClipOval(
                            child: Image.file(
                              File(produit.imagePath),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.brown,
                            child: Icon(Icons.coffee, color: Colors.white),
                          ),
                    title: Text(produit.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${produit.poids} kg - Prix de base: ${produit.prixDeBase} DA'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      // Ouvre l'écran d'ajout de quantité
                      final entree = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AjouterStockScreen(produit: produit)),
                      );

                      if (entree != null && entree is EntreeStock) {
                        setState(() {
                          produit.quantiteEnStock += entree.quantite;
                        });
                        // SAUVEGARDE EN BASE DE DONNÉES
                        await BaseDeDonnees.ajouterEntree(entree);
                        if (mounted) Navigator.pop(context, entree);
                      }
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_circle),
        label: const Text('Nouveau produit'),
        backgroundColor: Colors.orange,
        onPressed: () async {
          // Création d'un nouveau produit
          final nouveauProduit = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjouterProduitScreen()),
          );

          if (nouveauProduit != null && nouveauProduit is Produit) {
            // SAUVEGARDE EN BASE DE DONNÉES
            await BaseDeDonnees.ajouterProduit(nouveauProduit);
            setState(() {});
            
            // Redirection immédiate vers l'ajout de stock pour ce nouveau produit
            final entree = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AjouterStockScreen(produit: nouveauProduit)),
            );

            if (entree != null && entree is EntreeStock) {
              setState(() {
                nouveauProduit.quantiteEnStock += entree.quantite;
              });
              // SAUVEGARDE EN BASE DE DONNÉES
              await BaseDeDonnees.ajouterEntree(entree);
              if (mounted) Navigator.pop(context, entree);
            }
          }
        },
      ),
    );
  }
}