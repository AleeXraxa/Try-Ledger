class Company {
  final int id;
  final String name;
  final String type;
  final String address;
  final String phone;
  final String email;
  final bool isActive;

  Company({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.phone,
    required this.email,
    this.isActive = true,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? '',
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      isActive: (json['isActive'] as int?) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'phone': phone,
      'email': email,
      'isActive': isActive ? 1 : 0,
    };
  }
}
