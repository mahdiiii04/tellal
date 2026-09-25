import 'client.dart';

class Versement {
  String id;
  Client client;
  double montant;
  DateTime dateVersement;

  Versement({
    required this.id,
    required this.client,
    required this.montant,
    DateTime? dateVersement,
  }) : dateVersement = dateVersement ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': client.id, // On sauvegarde uniquement l'ID du client
      'montant': montant,
      'dateVersement': dateVersement.toIso8601String(),
    };
  }

  factory Versement.fromMap(Map<String, dynamic> map, Client clientAssocie) {
    return Versement(
      id: map['id'],
      client: clientAssocie,
      montant: (map['montant'] ?? 0).toDouble(),
      dateVersement: DateTime.parse(map['dateVersement']),
    );
  }
}