// Fichier : lib/screens/ventes_screen.dart
import 'package:flutter/material.dart';
import '../services/base_de_donnees.dart';
import '../services/pdf_service.dart';
import 'nouvelle_vente_screen.dart';

class VentesScreen extends StatefulWidget {
  const VentesScreen({super.key});

  @override
  State<VentesScreen> createState() => _VentesScreenState();
}

class _VentesScreenState extends State<VentesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des Ventes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: BaseDeDonnees.historiqueVentes.isEmpty
          ? const Center(child: Text('Aucune vente enregistrée.'))
          : ListView.builder(
              itemCount: BaseDeDonnees.historiqueVentes.length,
              itemBuilder: (context, index) {
                final ventesInversees = BaseDeDonnees.historiqueVentes.reversed.toList();
                final vente = ventesInversees[index];
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.shopping_cart, color: Colors.white)),
                    title: Text(vente.client.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${vente.dateVente.day}/${vente.dateVente.month}/${vente.dateVente.year} - ${vente.lignes.length} article(s)'),
                    trailing: Text('${vente.totalVente} DA', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    children: [
                      // Liste des produits achetés
                      ...vente.lignes.map((ligne) {
                        return ListTile(
                          title: Text(ligne.produit.nom),
                          subtitle: Text('Prix de base: ${ligne.prixDeBase} | Marge: +${ligne.marge} DA'),
                          trailing: Text('${ligne.quantite}x = ${ligne.totalLigne} DA'),
                        );
                      }),
                      // Bouton d'impression
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueGrey,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimer la facture en PDF'),
                          onPressed: () async {
                            await PdfService.imprimerFacture(vente);
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle Vente'),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NouvelleVenteScreen()),
          );
          setState(() {}); // Rafraîchir la liste de l'historique des ventes
        },
      ),
    );
  }
}