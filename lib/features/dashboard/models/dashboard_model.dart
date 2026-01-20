enum ActivityType { drLedger, companyLedger, sales, advancePayment }

enum TransactionType { debit, credit }

class ActivityItem {
  final int id;
  final String description;
  final double amount;
  final DateTime date;
  final ActivityType activityType;
  final TransactionType transactionType;
  final String? doctorName;
  final String? companyName;
  final String? referenceNo;

  ActivityItem({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.activityType,
    required this.transactionType,
    this.doctorName,
    this.companyName,
    this.referenceNo,
  });

  String get typeLabel {
    switch (activityType) {
      case ActivityType.drLedger:
        return 'Dr Ledger';
      case ActivityType.companyLedger:
        return 'Company Ledger';
      case ActivityType.sales:
        return 'Sales';
      case ActivityType.advancePayment:
        return 'Advance Payment';
    }
  }

  String get transactionLabel {
    return transactionType == TransactionType.debit ? 'Debit' : 'Credit';
  }

  String get formattedAmount {
    return '${transactionType == TransactionType.debit ? '+' : '-'}Rs. ${amount.toStringAsFixed(2)}';
  }
}

class DashboardModel {
  final int totalStock;
  final double totalSales;
  final double profit;

  DashboardModel({
    required this.totalStock,
    required this.totalSales,
    required this.profit,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalStock: json['totalStock'] ?? 0,
      totalSales: json['totalSales'] ?? 0.0,
      profit: json['profit'] ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStock': totalStock,
      'totalSales': totalSales,
      'profit': profit,
    };
  }
}
