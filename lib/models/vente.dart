import 'dart:convert';
import 'produit.dart';
import 'client.dart';

class LigneVente {
  Produit produit;
  int quantite;
  double prixDeBase;
  double marge;

  LigneVente({
    required this.produit,
    required this.quantite,
    required this.prixDeBase,
    required this.marge,
  });

  double get totalLigne => (prixDeBase + marge) * quantite;

  // Convertir une seule ligne en Map
  Map<String, dynamic> toMap() {
    return {
      'produitId': produit.id,
      'quantite': quantite,
      'prixDeBase': prixDeBase,
      'marge': marge,
    };
  }
}

class Vente {
  String id;
  Client client;
  DateTime dateVente;
  List<LigneVente> lignes;

  Vente({
    required this.id,
    required this.client,
    required this.lignes,
    DateTime? dateVente,
  }) : dateVente = dateVente ?? DateTime.now();

  double get totalVente {
    return lignes.fold(0, (somme, ligne) => somme + ligne.totalLigne);
  }

  double get margeVente {
    return lignes.fold(0, (somme, ligne) => somme + (ligne.marge * ligne.quantite));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': client.id,
      'dateVente': dateVente.toIso8601String(),
      // On encode toutes les lignes en une seule chaîne JSON pour SQLite
      'lignes': jsonEncode(lignes.map((l) => l.toMap()).toList()), 
    };
  }

  factory Vente.fromMap(Map<String, dynamic> map, Client clientAssocie, List<LigneVente> lignesAssociees) {
    return Vente(
      id: map['id'],
      client: clientAssocie,
      lignes: lignesAssociees,
      dateVente: DateTime.parse(map['dateVente']),
    );
  }
}