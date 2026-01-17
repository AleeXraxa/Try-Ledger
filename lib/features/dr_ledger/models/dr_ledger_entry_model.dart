class DrLedgerEntry {
  final int id;
  final String description;
  final double debit;
  final double credit;
  final DateTime date;

  DrLedgerEntry({
    required this.id,
    required this.description,
    required this.debit,
    required this.credit,
    required this.date,
  });

  factory DrLedgerEntry.fromJson(Map<String, dynamic> json) {
    return DrLedgerEntry(
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
