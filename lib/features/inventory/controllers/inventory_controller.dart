import 'package:get/get.dart';
import '../models/product_model.dart';
import '../models/invoice_model.dart';
import '../services/inventory_service.dart';

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
}
