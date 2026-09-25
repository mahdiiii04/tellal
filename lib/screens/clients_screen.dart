// Fichier : lib/screens/clients_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/base_de_donnees.dart';
import '../models/client.dart';
import 'ajouter_client_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  @override
  Widget build(BuildContext context) {
    // 1. Calcul de la dette pour chaque client et ajout dans une liste temporaire
    List<Map<String, dynamic>> clientsAvecDettes = [];
    double creancesTotales = 0.0;

    for (var client in BaseDeDonnees.clients) {
      double dette = BaseDeDonnees.detteClient(client.id);
      creancesTotales += dette;
      clientsAvecDettes.add({
        'client': client,
        'dette': dette,
      });
    }

    // 2. Tri de la liste : de la dette la plus élevée à la plus faible
    clientsAvecDettes.sort((a, b) => (b['dette'] as double).compareTo(a['dette'] as double));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des Clients'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bandeau Créances (Total de l'argent dehors)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20.0),
            color: Colors.blue[50],
            child: Column(
              children: [
                const Text('Total des Créances (Argent dehors)', style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${creancesTotales.toStringAsFixed(2)} DA',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Liste des clients triée
          Expanded(
            child: clientsAvecDettes.isEmpty
                ? const Center(child: Text('Aucun client enregistré.'))
                : ListView.builder(
                    itemCount: clientsAvecDettes.length,
                    itemBuilder: (context, index) {
                      final item = clientsAvecDettes[index];
                      final Client client = item['client'];
                      final double dette = item['dette'];

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(client.nom, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${client.localisation} • ${client.telephone}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Dette: ${dette.toStringAsFixed(2)} DA',
                                style: TextStyle(
                                  color: dette > 0 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.phone, color: Colors.blue),
                                onPressed: () async {
                                  final Uri url = Uri.parse('tel:${client.telephone}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () async {
          final nouveauClient = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AjouterClientScreen()),
          );
          if (nouveauClient != null && nouveauClient is Client) {
            await BaseDeDonnees.ajouterClient(nouveauClient);
            setState(() {});
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}