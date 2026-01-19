class Doctor {
  final int id;
  final String name;
  final String specialization;
  final String address;
  final String phone;
  final String email;
  final bool isActive;

  Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.address,
    required this.phone,
    required this.email,
    this.isActive = true,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
      specialization: json['specialization'] ?? '',
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
      'specialization': specialization,
      'address': address,
      'phone': phone,
      'email': email,
      'isActive': isActive ? 1 : 0,
    };
  }
}
