// Fichier : lib/models/client.dart

class Client {
  String id;
  String nom;
  String localisation;
  String telephone;

  Client({
    required this.id,
    required this.nom,
    required this.localisation,
    required this.telephone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'localisation': localisation,
      'telephone': telephone,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      nom: map['nom'],
      localisation: map['localisation'] ?? '',
      telephone: map['telephone'] ?? '',
    );
  }
}