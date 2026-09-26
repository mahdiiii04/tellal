// Fichier : lib/screens/ajouter_client_screen.dart
import 'package:flutter/material.dart';
import '../models/client.dart';

class AjouterClientScreen extends StatefulWidget {
  const AjouterClientScreen({super.key});

  @override
  State<AjouterClientScreen> createState() => _AjouterClientScreenState();
}

class _AjouterClientScreenState extends State<AjouterClientScreen> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  String localisation = '';
  String telephone = '';
  double detteInitiale = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau Client')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom du client', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
                onSaved: (val) => nom = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Localisation', border: OutlineInputBorder()),
                onSaved: (val) => localisation = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Numéro de téléphone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                onSaved: (val) => telephone = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dette initiale (DA)', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                initialValue: '0',
                onSaved: (val) => detteInitiale = double.tryParse(val ?? '0') ?? 0.0,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final client = Client(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nom: nom,
                      localisation: localisation,
                      telephone: telephone,
                      detteInitiale: detteInitiale,
                    );
                    Navigator.pop(context, client);
                  }
                },
                child: const Text('Enregistrer le client'),
              )
            ],
          ),
        ),
      ),
    );
  }
}