// Fichier : lib/screens/nouvelle_vente_screen.dart

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/produit.dart';
import '../models/vente.dart';
import '../services/base_de_donnees.dart';

class NouvelleVenteScreen extends StatefulWidget {
  const NouvelleVenteScreen({super.key});

  @override
  State<NouvelleVenteScreen> createState() => _NouvelleVenteScreenState();
}

class _NouvelleVenteScreenState extends State<NouvelleVenteScreen> {
  Client? clientSelectionne;
  List<LigneVente> lignes = [];

  double get totalGlobal => lignes.fold(0, (somme, ligne) => somme + ligne.totalLigne);

  void _afficherDialogueAjoutProduit() {
    // On ne montre que les produits qui ont du stock
    final produitsDispo = BaseDeDonnees.catalogue.where((p) => p.quantiteEnStock > 0).toList();
    
    if (produitsDispo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucun produit disponible en stock !')));
      return;
    }

    final formKey = GlobalKey<FormState>();
    Produit? produitSelectionne;
    int quantite = 1;
    double marge = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Ajouter un produit'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Produit>(
                      decoration: const InputDecoration(labelText: 'Produit', border: OutlineInputBorder()),
                      items: produitsDispo.map((p) {
                        return DropdownMenuItem(value: p, child: Text('${p.nom} (En stock: ${p.quantiteEnStock})'));
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() { produitSelectionne = val; });
                      },
                      validator: (val) => val == null ? 'Choisissez un produit' : null,
                    ),
                    const SizedBox(height: 16),
                    if (produitSelectionne != null) ...[
                      Text('Prix de base : ${produitSelectionne!.prixDeBase} DA', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Marge ajoutée (DA/unité)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => marge = double.tryParse(val ?? '0') ?? 0.0,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Quantité', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      initialValue: '1',
                      validator: (val) {
                        int q = int.tryParse(val ?? '0') ?? 0;
                        if (q <= 0) return 'Quantité invalide';
                        if (produitSelectionne != null && q > produitSelectionne!.quantiteEnStock) {
                          return 'Stock insuffisant (Max: ${produitSelectionne!.quantiteEnStock})';
                        }
                        return null;
                      },
                      onSaved: (val) => quantite = int.tryParse(val ?? '1') ?? 1,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () {
                    if (formKey.currentState!.validate() && produitSelectionne != null) {
                      formKey.currentState!.save();
                      setState(() {
                        lignes.add(
                          LigneVente(
                            produit: produitSelectionne!,
                            quantite: quantite,
                            prixDeBase: produitSelectionne!.prixDeBase,
                            marge: marge,
                          )
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          }
        );
      },
    );
  }

void _validerVente() async {
    if (clientSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner un client.')));
      return;
    }
    if (lignes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez ajouter au moins un produit.')));
      return;
    }

    // 1. Déduction du stock physique en RAM
    for (var ligne in lignes) {
      ligne.produit.quantiteEnStock -= ligne.quantite;
    }

    // 2. Création de la transaction
    final nouvelleVente = Vente(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      client: clientSelectionne!,
      lignes: lignes,
    );

    // 3. SAUVEGARDE EN BASE DE DONNÉES
    await BaseDeDonnees.ajouterVente(nouvelleVente);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vente validée et sauvegardée !'), backgroundColor: Colors.green));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle Facture'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Client>(
              decoration: const InputDecoration(labelText: 'Sélectionner le Client', border: OutlineInputBorder()),
              items: BaseDeDonnees.clients.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.nom));
              }).toList(),
              onChanged: (val) => setState(() { clientSelectionne = val; }),
            ),
            const SizedBox(height: 16),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Articles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.add, color: Colors.green),
                  label: const Text('Ajouter un produit', style: TextStyle(color: Colors.green)),
                  onPressed: _afficherDialogueAjoutProduit,
                )
              ],
            ),
            Expanded(
              child: lignes.isEmpty
                  ? const Center(child: Text('Aucun article ajouté.'))
                  : ListView.builder(
                      itemCount: lignes.length,
                      itemBuilder: (context, index) {
                        final ligne = lignes[index];
                        return ListTile(
                          title: Text(ligne.produit.nom),
                          subtitle: Text('${ligne.quantite}x (${ligne.prixDeBase} + ${ligne.marge}) DA'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${ligne.totalLigne} DA', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() { lignes.removeAt(index); });
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL :', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('${totalGlobal} DA', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _validerVente,
              child: const Text('Valider la transaction', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}