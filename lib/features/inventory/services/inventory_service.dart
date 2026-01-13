import '../models/product_model.dart';

class InventoryService {
  // Dummy service for SQLite operations
  Future<List<Product>> getProducts() async {
    // Simulate database query
    await Future.delayed(Duration(seconds: 1));
    return [
      Product(id: 1, name: 'Medicine A', stock: 50, price: 10.0),
      Product(id: 2, name: 'Medicine B', stock: 30, price: 15.0),
    ];
  }

  Future<void> addProduct(Product product) async {
    // Dummy add
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> updateProduct(Product product) async {
    // Dummy update
    await Future.delayed(Duration(milliseconds: 500));
  }

  Future<void> deleteProduct(int id) async {
    // Dummy delete
    await Future.delayed(Duration(milliseconds: 500));
  }
}
