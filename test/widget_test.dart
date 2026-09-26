import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tellal/main.dart';
import 'package:tellal/models/client.dart';
import 'package:tellal/models/produit.dart';
import 'package:tellal/models/vente.dart';
import 'package:tellal/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const GestionCafeApp());

    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  test('A sale exposes its total margin', () {
    final vente = Vente(
      id: 'v1',
      client: Client(
        id: 'c1',
        nom: 'Client Test',
        localisation: 'Algiers',
        telephone: '123456789',
      ),
      lignes: [
        LigneVente(
          produit: Produit(
            id: 'p1',
            nom: 'Produit 1',
            poids: 1,
            imagePath: '',
            prixDeBase: 100,
          ),
          quantite: 2,
          prixDeBase: 100,
          marge: 20,
        ),
        LigneVente(
          produit: Produit(
            id: 'p2',
            nom: 'Produit 2',
            poids: 1,
            imagePath: '',
            prixDeBase: 50,
          ),
          quantite: 3,
          prixDeBase: 50,
          marge: 10,
        ),
      ],
    );

    expect(vente.totalVente, 420);
    expect(vente.margeVente, 70);
  });
}