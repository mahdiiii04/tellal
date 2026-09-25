// Fichier : lib/services/pdf_service.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/vente.dart';

class PdfService {
  static Future<void> imprimerFacture(Vente vente) async {
    final pdf = pw.Document();

    // Création de la page PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // En-tête
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('FACTURE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
                  // Le nom a été changé ici :
                  pw.Text('Café Tellal', style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                ],
              ),
              pw.SizedBox(height: 30),
              
              // Informations Client et Date
              pw.Text('Informations du client :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Nom : ${vente.client.nom}'),
              pw.Text('Téléphone : ${vente.client.telephone}'),
              pw.Text('Date : ${vente.dateVente.day}/${vente.dateVente.month}/${vente.dateVente.year} à ${vente.dateVente.hour}:${vente.dateVente.minute.toString().padLeft(2, '0')}'),
              pw.SizedBox(height: 30),

              // Tableau des articles
              pw.TableHelper.fromTextArray(
                headers: ['Produit', 'Quantité', 'Prix Unitaire (DA)', 'Total (DA)'],
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.green700),
                rowDecoration: const pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                ),
                data: vente.lignes.map((ligne) {
                  final prixUnitaire = ligne.prixDeBase + ligne.marge;
                  return [
                    ligne.produit.nom,
                    ligne.quantite.toString(),
                    prixUnitaire.toStringAsFixed(2),
                    ligne.totalLigne.toStringAsFixed(2),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),

              // Total Général
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey200,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                  ),
                  child: pw.Text(
                    'TOTAL À PAYER : ${vente.totalVente.toStringAsFixed(2)} DA',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Ouvre l'aperçu et le gestionnaire d'impression de Windows
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Facture_${vente.client.nom}_${vente.dateVente.millisecondsSinceEpoch}.pdf',
    );
  }
}