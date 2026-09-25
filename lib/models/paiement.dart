// Fichier : lib/models/paiement.dart

class Paiement {
  String id;
  double montant;
  DateTime datePaiement;

  Paiement({
    required this.id,
    required this.montant,
    DateTime? datePaiement,
  }) : datePaiement = datePaiement ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'montant': montant,
      // SQLite ne stocke pas les dates natives, on les convertit en texte ISO
      'datePaiement': datePaiement.toIso8601String(), 
    };
  }

  factory Paiement.fromMap(Map<String, dynamic> map) {
    return Paiement(
      id: map['id'],
      montant: (map['montant'] ?? 0).toDouble(),
      datePaiement: DateTime.parse(map['datePaiement']),
    );
  }
}