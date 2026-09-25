import 'package:flutter/material.dart';
import '../models/produit.dart';
import '../models/entree_stock.dart';

class AjouterStockScreen extends StatefulWidget {
  final Produit produit; // Le produit sélectionné

  const AjouterStockScreen({super.key, required this.produit});

  @override
  State<AjouterStockScreen> createState() => _AjouterStockScreenState();
}

class _AjouterStockScreenState extends State<AjouterStockScreen> {
  final _formKey = GlobalKey<FormState>();
  int quantite = 1;
  late double prixAchat;

  @override
  void initState() {
    super.initState();
    // On pré-remplit avec le prix de base du produit
    prixAchat = widget.produit.prixDeBase;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alimenter: ${widget.produit.nom}'),
        backgroundColor: Colors.green, // Vert pour signifier une entrée/achat
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text(widget.produit.nom, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                subtitle: Text('Poids: ${widget.produit.poids} kg'),
              ),
              const Divider(),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: quantite.toString(),
                decoration: const InputDecoration(labelText: 'Quantité (Nombre de sacs/unités)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => quantite = int.tryParse(value ?? '1') ?? 1,
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: prixAchat.toString(),
                decoration: const InputDecoration(labelText: 'Prix d\'achat unitaire (DA)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => prixAchat = double.tryParse(value ?? '0') ?? widget.produit.prixDeBase,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    final entree = EntreeStock(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      produit: widget.produit,
                      quantite: quantite,
                      prixAchat: prixAchat,
                    );
                    
                    Navigator.pop(context, entree);
                  }
                },
                child: const Text('Confirmer l\'entrée en stock', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}