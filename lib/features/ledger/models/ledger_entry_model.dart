class LedgerEntry {
  final int id;
  final String description;
  final double debit;
  final double credit;
  final DateTime date;

  LedgerEntry({
    required this.id,
    required this.description,
    required this.debit,
    required this.credit,
    required this.date,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'],
      description: json['description'],
      debit: json['debit'],
      credit: json['credit'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'debit': debit,
      'credit': credit,
      'date': date.toIso8601String(),
    };
  }
}
