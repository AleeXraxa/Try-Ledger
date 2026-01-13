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
