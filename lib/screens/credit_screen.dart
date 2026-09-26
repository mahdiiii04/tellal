// Fichier : lib/screens/credit_screen.dart
import 'package:flutter/material.dart';
import '../models/paiement.dart';
import '../services/base_de_donnees.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  void _afficherDialoguePaiement() {
    final formKey = GlobalKey<FormState>();
    double montant = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouveau Paiement'),
          content: Form(
            key: formKey,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Montant versé (DA)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (val) => val == null || val.isEmpty ? 'Veuillez entrer un montant' : null,
              onSaved: (val) => montant = double.tryParse(val ?? '0') ?? 0.0,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Annuler', style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  
                  final paiement = Paiement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    montant: montant,
                  );
                  
                  await BaseDeDonnees.ajouterPaiement(paiement);
                  BaseDeDonnees.reinitialiserDetteTotale();
                  setState(() {});
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Confirmer le paiement'),
            ),
          ],
        );
      },
    );
  }

  void _afficherDialogueModificationDette() {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController(
      text: BaseDeDonnees.detteTotale.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la dette'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Montant de la dette (DA)', border: OutlineInputBorder()),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (val) => val == null || val.isEmpty ? 'Veuillez entrer un montant' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final value = double.tryParse(controller.text) ?? 0.0;
                  BaseDeDonnees.definirDetteTotale(value);
                  setState(() {});
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double detteActuelle = BaseDeDonnees.detteTotale;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du Crédit'),
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _afficherDialogueModificationDette,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            color: Colors.red[50],
            child: Column(
              children: [
                const Text('Dette Totale Actuelle', style: TextStyle(fontSize: 18, color: Colors.red)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _afficherDialogueModificationDette,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      '${detteActuelle.toStringAsFixed(2)} DA',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BaseDeDonnees.historiquePaiements.isEmpty
                ? const Center(child: Text('Aucun paiement effectué pour le moment.'))
                : ListView.builder(
                    itemCount: BaseDeDonnees.historiquePaiements.length,
                    itemBuilder: (context, index) {
                      final paiementsReverses = BaseDeDonnees.historiquePaiements.reversed.toList();
                      final paiement = paiementsReverses[index];
                      String dateFormatee = "${paiement.datePaiement.day}/${paiement.datePaiement.month}/${paiement.datePaiement.year} à ${paiement.datePaiement.hour}:${paiement.datePaiement.minute.toString().padLeft(2, '0')}";

                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.check, color: Colors.white)),
                        title: Text('Paiement de ${paiement.montant} DA', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(dateFormatee),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red, foregroundColor: Colors.white,
        icon: const Icon(Icons.payment),
        label: const Text('Ajouter un paiement'),
        onPressed: _afficherDialoguePaiement,
      ),
    );
  }
}