class Transaction {
  final int id;
  final String type; // 'sale' or 'purchase'
  final double amount;
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}
