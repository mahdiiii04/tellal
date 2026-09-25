// Fichier : lib/screens/ajouter_produit_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/produit.dart';

class AjouterProduitScreen extends StatefulWidget {
  const AjouterProduitScreen({super.key});

  @override
  State<AjouterProduitScreen> createState() => _AjouterProduitScreenState();
}

class _AjouterProduitScreenState extends State<AjouterProduitScreen> {
  final _formKey = GlobalKey<FormState>();
  String nom = '';
  double poids = 0.0;
  double prixDeBase = 0.0;
  
  // Variables pour la gestion de l'image
  File? _imageSelectionnee;
  String imagePathFinal = '';

  Future<void> _choisirImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageSelectionnee = File(pickedFile.path);
      });
    }
  }

  Future<String> _sauvegarderImageLocalement(File image) async {
    // Obtenir le dossier des documents de l'application
    final directory = await getApplicationDocumentsDirectory();
    final nomFichier = path.basename(image.path);
    final cheminLocal = path.join(directory.path, nomFichier);

    // Copier l'image vers ce dossier sécurisé
    final imageSauvegardee = await image.copy(cheminLocal);
    return imageSauvegardee.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau Produit au Catalogue'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Zone de sélection d'image
              GestureDetector(
                onTap: _choisirImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _imageSelectionnee != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageSelectionnee!, fit: BoxFit.cover, width: double.infinity),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Appuyez pour ajouter une image'),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nom du produit (ex: Café Brésilien)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Veuillez entrer un nom' : null,
                onSaved: (value) => nom = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Poids (en kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => poids = double.tryParse(value ?? '0') ?? 0.0,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Prix de base unitaire (DA)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => prixDeBase = double.tryParse(value ?? '0') ?? 0.0,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    // Si une image a été sélectionnée, on la sauvegarde de manière permanente
                    if (_imageSelectionnee != null) {
                      imagePathFinal = await _sauvegarderImageLocalement(_imageSelectionnee!);
                    }

                    final nouveauProduit = Produit(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nom: nom,
                      poids: poids,
                      imagePath: imagePathFinal, // Le chemin de l'image est enregistré
                      prixDeBase: prixDeBase,
                    );
                    
                    if (context.mounted) Navigator.pop(context, nouveauProduit);
                  }
                },
                child: const Text('Enregistrer le produit', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}