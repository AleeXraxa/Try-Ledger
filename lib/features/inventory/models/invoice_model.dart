import 'dart:convert';

class Invoice {
  final int id;
  final String reference;
  final DateTime date;
  final List<Map<String, dynamic>> items;
  final double total;
  final int? companyId;

  Invoice({
    required this.id,
    required this.reference,
    required this.date,
    required this.items,
    required this.total,
    this.companyId,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      reference: json['reference'],
      date: DateTime.parse(json['date']),
      items: List<Map<String, dynamic>>.from(jsonDecode(json['items'])),
      total: json['total'],
      companyId: json['companyId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'date': date.toIso8601String(),
      'items': jsonEncode(items),
      'total': total,
      'companyId': companyId,
    };
  }
}
