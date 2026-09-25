// Fichier : lib/screens/caisse_screen.dart
import 'package:flutter/material.dart';
import '../services/base_de_donnees.dart';
import '../models/versement.dart';
import '../models/client.dart';

class CaisseScreen extends StatefulWidget {
  const CaisseScreen({super.key});

  @override
  State<CaisseScreen> createState() => _CaisseScreenState();
}

class _CaisseScreenState extends State<CaisseScreen> {
  void _afficherDialogueVersement() {
    if (BaseDeDonnees.clients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez d\'abord ajouter un client.')));
      return;
    }

    final formKey = GlobalKey<FormState>();
    double montant = 0.0;
    Client? clientSelectionne;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter un versement'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Client>(
                  decoration: const InputDecoration(labelText: 'Sélectionner le client', border: OutlineInputBorder()),
                  items: BaseDeDonnees.clients.map((c) => DropdownMenuItem(value: c, child: Text(c.nom))).toList(),
                  onChanged: (val) => clientSelectionne = val,
                  validator: (val) => val == null ? 'Veuillez choisir un client' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Montant (DA)', border: OutlineInputBorder()),
                  keyboardType: TextInputType.number,
                  validator: (val) => val == null || val.isEmpty ? 'Entrez un montant' : null,
                  onSaved: (val) => montant = double.tryParse(val ?? '0') ?? 0.0,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              onPressed: () async {
                if (formKey.currentState!.validate() && clientSelectionne != null) {
                  formKey.currentState!.save();
                  
                  final versement = Versement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    client: clientSelectionne!,
                    montant: montant,
                  );

                  // SAUVEGARDE EN BASE DE DONNÉES
                  await BaseDeDonnees.ajouterVersement(versement);
                  
                  setState(() {});
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caisse (Versements Clients)'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: BaseDeDonnees.historiqueVersements.isEmpty
          ? const Center(child: Text('Aucun versement client enregistré.'))
          : ListView.builder(
              itemCount: BaseDeDonnees.historiqueVersements.length,
              itemBuilder: (context, index) {
                final versementsReverses = BaseDeDonnees.historiqueVersements.reversed.toList();
                final versement = versementsReverses[index];
                
                return ListTile(
                  leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.attach_money, color: Colors.white)),
                  title: Text('Versement de ${versement.client.nom}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${versement.dateVersement.day}/${versement.dateVersement.month}/${versement.dateVersement.year}'),
                  trailing: Text('+ ${versement.montant} DA', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal, foregroundColor: Colors.white,
        icon: const Icon(Icons.add), label: const Text('Ajouter versement'),
        onPressed: _afficherDialogueVersement,
      ),
    );
  }
}