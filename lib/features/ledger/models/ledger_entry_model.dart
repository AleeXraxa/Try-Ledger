class LedgerEntry {
  final int id;
  final String description;
  final double debit;
  final double credit;
  final DateTime date;
  final int? companyId;
  final String? referenceNo;
  final int? qty;
  final double? rate;

  LedgerEntry({
    required this.id,
    required this.description,
    required this.debit,
    required this.credit,
    required this.date,
    this.companyId,
    this.referenceNo,
    this.qty,
    this.rate,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'],
      description: json['description'],
      debit: json['debit'],
      credit: json['credit'],
      date: DateTime.parse(json['date']),
      companyId: json['company_id'],
      referenceNo: json['reference_no'],
      qty: json['qty'],
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
      'company_id': companyId,
      'reference_no': referenceNo,
      'qty': qty,
      'rate': rate,
    };
  }
}
