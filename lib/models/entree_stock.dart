import 'produit.dart';

class EntreeStock {
  String id;
  Produit produit;
  int quantite;
  double prixAchat;
  DateTime dateAjout;

  EntreeStock({
    required this.id,
    required this.produit,
    required this.quantite,
    required this.prixAchat,
    DateTime? dateAjout,
  }) : dateAjout = dateAjout ?? DateTime.now();

  double get coutTotal => prixAchat * quantite;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'produitId': produit.id, // On sauvegarde uniquement l'ID du produit
      'quantite': quantite,
      'prixAchat': prixAchat,
      'dateAjout': dateAjout.toIso8601String(),
    };
  }

  // fromMap nécessite l'objet Produit reconstruit au préalable
  factory EntreeStock.fromMap(Map<String, dynamic> map, Produit produitAssocie) {
    return EntreeStock(
      id: map['id'],
      produit: produitAssocie,
      quantite: map['quantite']?.toInt() ?? 0,
      prixAchat: (map['prixAchat'] ?? 0).toDouble(),
      dateAjout: DateTime.parse(map['dateAjout']),
    );
  }
}