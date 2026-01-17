class Product {
  final int id;
  final String name;
  final int stock;
  final double price;
  final String? category;
  final int? companyId;

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
    this.category,
    this.companyId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      stock: json['stock'],
      price: json['price'],
      category: json['category'] as String?,
      companyId: json['companyId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stock': stock,
      'price': price,
      'category': category,
      'companyId': companyId,
    };
  }
}
