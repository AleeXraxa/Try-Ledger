import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/inventory_service.dart';

class InventoryController extends GetxController {
  final InventoryService _service = InventoryService();

  var products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void loadProducts() async {
    products.value = await _service.getProducts();
  }

  void addProduct(Product product) async {
    await _service.addProduct(product);
    loadProducts();
  }

  void updateProduct(Product product) async {
    await _service.updateProduct(product);
    loadProducts();
  }

  void deleteProduct(int id) async {
    await _service.deleteProduct(id);
    loadProducts();
  }
}
