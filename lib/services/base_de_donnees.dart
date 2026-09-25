// Fichier : lib/services/base_de_donnees.dart
import '../models/produit.dart';
import '../models/entree_stock.dart';
import '../models/paiement.dart';
import '../models/client.dart';
import '../models/vente.dart';
import '../models/versement.dart';
import 'database_service.dart';

class BaseDeDonnees {
  static List<Produit> catalogue = [];
  static List<EntreeStock> historiqueEntrees = [];
  static List<Paiement> historiquePaiements = [];
  static List<Client> clients = [];
  static List<Vente> historiqueVentes = [];
  static List<Versement> historiqueVersements = [];

  // 1. CHANGER LE CHARGEMENT AU DÉMARRAGE
  static Future<void> initialiser() async {
    final db = DatabaseService.instance;
    
    catalogue = await db.getProduits();
    clients = await db.getClients();
    historiquePaiements = await db.getPaiements();
    
    if (catalogue.isNotEmpty) {
      historiqueEntrees = await db.getEntrees(catalogue);
    }
    if (clients.isNotEmpty) {
      historiqueVersements = await db.getVersements(clients);
    }
    if (clients.isNotEmpty && catalogue.isNotEmpty) {
      historiqueVentes = await db.getVentes(clients, catalogue);
    }
  }

  // 2. MÉTHODES POUR SAUVEGARDER FACILEMENT EN RAM + SUR DISQUE
  static Future<void> ajouterProduit(Produit p) async {
    catalogue.add(p);
    await DatabaseService.instance.insertProduit(p);
  }
  static Future<void> ajouterClient(Client c) async {
    clients.add(c);
    await DatabaseService.instance.insertClient(c);
  }
  static Future<void> ajouterEntree(EntreeStock e) async {
    historiqueEntrees.add(e);
    await DatabaseService.instance.insertEntree(e);
    await DatabaseService.instance.updateProduitStock(e.produit);
  }
  static Future<void> ajouterVente(Vente v) async {
    historiqueVentes.add(v);
    await DatabaseService.instance.insertVente(v);
    for (var ligne in v.lignes) {
      await DatabaseService.instance.updateProduitStock(ligne.produit);
    }
  }
  static Future<void> ajouterPaiement(Paiement p) async {
    historiquePaiements.add(p);
    await DatabaseService.instance.insertPaiement(p);
  }
  static Future<void> ajouterVersement(Versement v) async {
    historiqueVersements.add(v);
    await DatabaseService.instance.insertVersement(v);
  }

  // 3. CALCULS EXISTANTS
  static double get detteTotale {
    double totalAchats = historiqueEntrees.fold(0, (somme, entree) => somme + entree.coutTotal);
    double totalPaye = historiquePaiements.fold(0, (somme, paiement) => somme + paiement.montant);
    return totalAchats - totalPaye;
  }

  static double detteClient(String clientId) {
    double totalAchats = historiqueVentes
        .where((v) => v.client.id == clientId)
        .fold(0, (somme, v) => somme + v.totalVente);
        
    double totalPaye = historiqueVersements
        .where((v) => v.client.id == clientId)
        .fold(0, (somme, v) => somme + v.montant);
        
    return totalAchats - totalPaye;
  }
}