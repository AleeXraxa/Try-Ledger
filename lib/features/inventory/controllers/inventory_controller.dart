import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/invoice_model.dart';
import '../services/inventory_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Purchase Invoice',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Reference: ${invoice.reference}'),
              pw.Text(
                'Date: ${invoice.date.toLocal().toString().split(' ')[0]}',
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Item', 'Quantity', 'Price', 'Total'],
                data: invoice.items
                    .map(
                      (item) => [
                        item['name'] ?? item['productName'] ?? 'Unknown',
                        item['quantity']?.toString() ?? '0',
                        item['price']?.toString() ?? '0',
                        ((item['quantity'] ?? 0) * (item['price'] ?? 0))
                            .toString(),
                      ],
                    )
                    .toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Total Amount: \$${invoice.total}',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
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
