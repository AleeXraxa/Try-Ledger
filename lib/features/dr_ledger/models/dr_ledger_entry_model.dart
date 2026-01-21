class DrLedgerEntry {
  final int id;
  final String description;
  final double debit;
  final double credit;
  final DateTime date;
  final int? doctorId;
  final double? rate;

  DrLedgerEntry({
    required this.id,
    required this.description,
    required this.debit,
    required this.credit,
    required this.date,
    this.doctorId,
    this.rate,
  });

  factory DrLedgerEntry.fromJson(Map<String, dynamic> json) {
    return DrLedgerEntry(
      id: json['id'],
      description: json['description'],
      debit: json['debit'],
      credit: json['credit'],
      date: DateTime.parse(json['date']),
      doctorId: json['doctorId'] as int?,
      rate: json['rate'] != null ? (json['rate'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'debit': debit,
      'credit': credit,
      'date': date.toIso8601String(),
      'doctorId': doctorId,
      'rate': rate,
    };
  }
}
