// Fichier : lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../models/produit.dart';
import '../models/client.dart';
import '../models/paiement.dart';
import '../models/versement.dart';
import '../models/entree_stock.dart';
import '../models/vente.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestion_cafe.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('CREATE TABLE produits (id TEXT PRIMARY KEY, nom TEXT, poids REAL, imagePath TEXT, prixDeBase REAL, quantiteEnStock INTEGER)');
    await db.execute('CREATE TABLE clients (id TEXT PRIMARY KEY, nom TEXT, localisation TEXT, telephone TEXT)');
    await db.execute('CREATE TABLE paiements (id TEXT PRIMARY KEY, montant REAL, datePaiement TEXT)');
    await db.execute('CREATE TABLE versements (id TEXT PRIMARY KEY, clientId TEXT, montant REAL, dateVersement TEXT)');
    await db.execute('CREATE TABLE entrees (id TEXT PRIMARY KEY, produitId TEXT, quantite INTEGER, prixAchat REAL, dateAjout TEXT)');
    await db.execute('CREATE TABLE ventes (id TEXT PRIMARY KEY, clientId TEXT, dateVente TEXT, lignes TEXT)');
  }

  // --- SAUVEGARDES (INSERTS) ---
  Future<void> insertProduit(Produit produit) async {
    final db = await instance.database;
    await db.insert('produits', produit.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<void> updateProduitStock(Produit produit) async {
    final db = await instance.database;
    await db.update('produits', produit.toMap(), where: 'id = ?', whereArgs: [produit.id]);
  }
  Future<void> insertClient(Client client) async {
    final db = await instance.database;
    await db.insert('clients', client.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<void> insertPaiement(Paiement paiement) async {
    final db = await instance.database;
    await db.insert('paiements', paiement.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<void> insertVersement(Versement versement) async {
    final db = await instance.database;
    await db.insert('versements', versement.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<void> insertEntree(EntreeStock entree) async {
    final db = await instance.database;
    await db.insert('entrees', entree.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  Future<void> insertVente(Vente vente) async {
    final db = await instance.database;
    await db.insert('ventes', vente.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // --- LECTURES (FETCHES) ---
  Future<List<Produit>> getProduits() async {
    final db = await instance.database;
    final maps = await db.query('produits');
    return maps.map((map) => Produit.fromMap(map)).toList();
  }
  Future<List<Client>> getClients() async {
    final db = await instance.database;
    final maps = await db.query('clients');
    return maps.map((map) => Client.fromMap(map)).toList();
  }
  Future<List<Paiement>> getPaiements() async {
    final db = await instance.database;
    final maps = await db.query('paiements');
    return maps.map((map) => Paiement.fromMap(map)).toList();
  }
  Future<List<EntreeStock>> getEntrees(List<Produit> catalogue) async {
    final db = await instance.database;
    final maps = await db.query('entrees');
    return maps.map((map) {
      final produit = catalogue.firstWhere((p) => p.id == map['produitId']);
      return EntreeStock.fromMap(map, produit);
    }).toList();
  }
  Future<List<Versement>> getVersements(List<Client> clients) async {
    final db = await instance.database;
    final maps = await db.query('versements');
    return maps.map((map) {
      final client = clients.firstWhere((c) => c.id == map['clientId']);
      return Versement.fromMap(map, client);
    }).toList();
  }
  Future<List<Vente>> getVentes(List<Client> clients, List<Produit> catalogue) async {
    final db = await instance.database;
    final maps = await db.query('ventes');
    return maps.map((map) {
      final client = clients.firstWhere((c) => c.id == map['clientId']);
      final List<dynamic> lignesJson = jsonDecode(map['lignes'] as String);
      List<LigneVente> lignes = lignesJson.map((lMap) {
        final produit = catalogue.firstWhere((p) => p.id == lMap['produitId']);
        return LigneVente(
          produit: produit,
          quantite: lMap['quantite'],
          prixDeBase: (lMap['prixDeBase'] ?? 0).toDouble(),
          marge: (lMap['marge'] ?? 0).toDouble(),
        );
      }).toList();
      return Vente.fromMap(map, client, lignes);
    }).toList();
  }
}