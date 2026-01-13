import 'package:get/get.dart';
import '../models/dashboard_model.dart';
import '../services/dashboard_service.dart';
import '../../ledger/models/ledger_entry_model.dart';
import '../../inventory/models/product_model.dart';

class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();

  // KPIs
  var currentBalance = 0.0.obs;
  var totalSales = 0.0.obs;
  var totalPayments = 0.0.obs;
  var stockValue = 0.0.obs;

  // Chart data (dummy)
  var salesData = <double>[].obs;

  // Ledger summary
  var openingBalance = 0.0.obs;
  var totalDebit = 0.0.obs;
  var totalCredit = 0.0.obs;
  var closingBalance = 0.0.obs;

  // Recent transactions
  var recentTransactions = <LedgerEntry>[].obs;

  // Low stock alerts
  var lowStockProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void loadData() async {
    // Dummy data
    currentBalance.value = 15000.0;
    totalSales.value = 25000.0;
    totalPayments.value = 20000.0;
    stockValue.value = 50000.0;

    salesData.value = [5000, 7000, 8000, 6000, 9000, 10000, 12000];

    openingBalance.value = 10000.0;
    totalDebit.value = 30000.0;
    totalCredit.value = 25000.0;
    closingBalance.value = 15000.0;

    recentTransactions.value = [
      LedgerEntry(
        id: 1,
        description: 'Sale Invoice #001',
        debit: 5000,
        credit: 0,
        date: DateTime.now().subtract(Duration(days: 1)),
      ),
      LedgerEntry(
        id: 2,
        description: 'Payment Received',
        debit: 0,
        credit: 5000,
        date: DateTime.now().subtract(Duration(days: 2)),
      ),
      LedgerEntry(
        id: 3,
        description: 'Purchase #002',
        debit: 0,
        credit: 3000,
        date: DateTime.now().subtract(Duration(days: 3)),
      ),
      LedgerEntry(
        id: 4,
        description: 'Sale Invoice #003',
        debit: 7000,
        credit: 0,
        date: DateTime.now().subtract(Duration(days: 4)),
      ),
      LedgerEntry(
        id: 5,
        description: 'Expense',
        debit: 0,
        credit: 1000,
        date: DateTime.now().subtract(Duration(days: 5)),
      ),
    ];

    lowStockProducts.value = [
      Product(id: 1, name: 'Medicine A', stock: 5, price: 10.0),
      Product(id: 2, name: 'Medicine B', stock: 2, price: 15.0),
    ];
  }
}
