import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/invoice_model.dart';
import '../services/inventory_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class InventoryController extends GetxController {
  final InventoryService _service = InventoryService();

  var products = <Product>[].obs;
  var invoices = <Invoice>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
    loadInvoices();
  }

  void loadProducts() async {
    products.value = await _service.getProducts();
  }

  Future<void> addProduct(Product product) async {
    await _service.addProduct(product);
    loadProducts();
  }

  void updateProduct(Product product) async {
    await _service.updateProduct(product);
    loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _service.deleteProduct(id);
    loadProducts();
  }

  void loadInvoices() async {
    invoices.value = await _service.getInvoices();
  }

  Future<void> addInvoice(Invoice invoice) async {
    await _service.addInvoice(invoice);
    loadInvoices();
  }

  void updateInvoice(Invoice invoice) async {
    await _service.updateInvoice(invoice);
    loadInvoices();
  }

  Future<void> deleteInvoice(int id) async {
    await _service.deleteInvoice(id);
    loadInvoices();
  }

  Future<void> downloadInvoice(Invoice invoice) async {
    final pdf = pw.Document();

    // Define fonts
    final regularFont = pw.Font.helvetica();
    final boldFont = pw.Font.helveticaBold();
    final titleFont = pw.Font.timesBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: pw.EdgeInsets.only(bottom: 20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
                  ),
                ),
                child: pw.Column(
                  children: [
                    // Centered company info
                    pw.Container(
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        children: [
                          pw.Text(
                            'Wintop Pharma',
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: 32,
                              color: PdfColors.blue,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'Purchase Invoice',
                            style: pw.TextStyle(
                              font: boldFont,
                              fontSize: 20,
                              color: PdfColors.black,
                              decoration: pw.TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    // Left-aligned invoice details
                    pw.Container(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Invoice #: ${invoice.reference}',
                            style: pw.TextStyle(font: boldFont, fontSize: 12),
                          ),
                          pw.Text(
                            'Date: ${invoice.date.toLocal().toString().split(' ')[0]}',
                            style: pw.TextStyle(font: boldFont, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Items Table
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1, color: PdfColors.grey),
                ),
                child: pw.TableHelper.fromTextArray(
                  headers: [
                    'S.No',
                    'Product Name',
                    'Batch No',
                    'Expiry',
                    'Quantity',
                    'Total Value',
                  ],
                  headerStyle: pw.TextStyle(
                    font: boldFont,
                    fontSize: 12,
                    color: PdfColors.white,
                  ),
                  headerDecoration: pw.BoxDecoration(color: PdfColors.blue),
                  data: invoice.items.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final item = entry.value;
                    final name =
                        item['name'] ?? item['productName'] ?? 'Unknown';
                    final batch = item['batch'] ?? '';
                    final expiry = item['expiry'] != null
                        ? (() {
                            final date = DateTime.parse(
                              item['expiry'],
                            ).toLocal();
                            return '${date.month.toString().padLeft(2, '0')}/${date.year}';
                          })()
                        : '';
                    final quantity = item['qty'] ?? item['quantity'] ?? 0;
                    final totalValue =
                        item['value'] ?? ((item['price'] ?? 0.0) * quantity);
                    return [
                      index.toString(),
                      name,
                      batch,
                      expiry,
                      quantity.toString(),
                      'PKR ${totalValue.toStringAsFixed(2)}',
                    ];
                  }).toList(),
                  cellStyle: pw.TextStyle(font: regularFont, fontSize: 11),
                  cellPadding: pw.EdgeInsets.all(8),
                  border: pw.TableBorder.all(
                    width: 0.5,
                    color: PdfColors.grey300,
                  ),
                ),
              ),

              pw.SizedBox(height: 10),

              // Table Total Row (separate from table)
              pw.Container(
                width: double.infinity,
                padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(width: 1, color: PdfColors.grey),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 14,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.Text(
                      'Quantity: ${invoice.items.fold<int>(0, (sum, item) => sum + ((item['qty'] ?? item['quantity'] ?? 0) as int))}    Total Value: PKR ${invoice.items.fold<double>(0.0, (sum, item) {
                        final quantity = item['qty'] ?? item['quantity'] ?? 0;
                        final totalValue = item['value'] ?? ((item['price'] ?? 0.0) * quantity);
                        return sum + totalValue;
                      }).toStringAsFixed(2)}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 12,
                        color: PdfColors.black,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Grand Total Section
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: pw.EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 1, color: PdfColors.grey),
                  ),
                  child: pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text(
                        'GRAND TOTAL:',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 16,
                          color: PdfColors.black,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Text(
                        'PKR ${invoice.total.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          font: boldFont,
                          fontSize: 18,
                          color: PdfColors.blue,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Container(
                padding: pw.EdgeInsets.only(top: 20),
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                    top: pw.BorderSide(width: 1, color: PdfColors.grey),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Software by: TryUnity Solutions',
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 10,
                        color: PdfColors.grey,
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Email: dev-alee@outlook.com',
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 10,
                            color: PdfColors.grey,
                          ),
                        ),
                        pw.Text(
                          'Phone: +92-302-3476605',
                          style: pw.TextStyle(
                            font: regularFont,
                            fontSize: 10,
                            color: PdfColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Get the downloads directory
    final directory = await getDownloadsDirectory();
    if (directory == null) {
      throw Exception('Could not access downloads directory');
    }

    // Create a unique file name
    final fileName =
        'invoice_${invoice.reference}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${directory.path}/$fileName';

    // Save the PDF
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the file
    await OpenFile.open(filePath);
  }
}
