class Product {
  final int id;
  final String name;
  final int stock;
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.stock,
    required this.price,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      stock: json['stock'],
      price: json['price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'stock': stock, 'price': price};
  }
}
