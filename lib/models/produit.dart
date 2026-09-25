// Fichier : lib/models/produit.dart

class Produit {
  String id;
  String nom;
  double poids;
  String imagePath;
  double prixDeBase;
  int quantiteEnStock;

  Produit({
    required this.id,
    required this.nom,
    required this.poids,
    required this.imagePath,
    required this.prixDeBase,
    this.quantiteEnStock = 0,
  });

  // Convertit l'objet en format compréhensible par la base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'poids': poids,
      'imagePath': imagePath,
      'prixDeBase': prixDeBase,
      'quantiteEnStock': quantiteEnStock,
    };
  }

  // Reconstruit l'objet à partir de la base de données
  factory Produit.fromMap(Map<String, dynamic> map) {
    return Produit(
      id: map['id'],
      nom: map['nom'],
      // .toDouble() est une sécurité car SQLite peut parfois renvoyer un int pour un chiffre rond
      poids: (map['poids'] ?? 0).toDouble(), 
      imagePath: map['imagePath'] ?? '',
      prixDeBase: (map['prixDeBase'] ?? 0).toDouble(),
      quantiteEnStock: map['quantiteEnStock']?.toInt() ?? 0,
    );
  }
}