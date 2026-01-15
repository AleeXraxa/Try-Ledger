import '../models/product_model.dart';
import 'package:tryledger/utils/database_helper.dart';

class InventoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Product>> getProducts() async {
    return await _dbHelper.getProducts();
  }

  Future<void> addProduct(Product product) async {
    print('Service adding product');
    await _dbHelper.insertProduct(product);
  }

  Future<void> updateProduct(Product product) async {
    await _dbHelper.updateProduct(product);
  }

  Future<void> deleteProduct(int id) async {
    await _dbHelper.deleteProduct(id);
  }
}
