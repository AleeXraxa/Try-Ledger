import 'package:get/get.dart';
import '../services/dashboard_service.dart';
import '../../ledger/models/ledger_entry_model.dart';
import '../../inventory/models/product_model.dart';
import '../../inventory/models/invoice_model.dart';
import '../../ledger/controllers/ledger_controller.dart';
import '../../inventory/controllers/inventory_controller.dart';

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

  // Invoices
  var invoices = <Invoice>[].obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(LedgerController());
    Get.put(InventoryController());
    final ledgerController = Get.find<LedgerController>();
    final inventoryController = Get.find<InventoryController>();
    ever(ledgerController.ledgerEntries, (_) => loadData());
    ever(inventoryController.products, (_) => loadData());
    ever(inventoryController.invoices, (_) => loadData());
    loadData();
  }

  void loadData() {
    final ledgerController = Get.find<LedgerController>();
    final inventoryController = Get.find<InventoryController>();

    // Calculate KPIs
    double balance = 0.0;
    double sales = 0.0;
    double payments = 0.0;
    double stockVal = 0.0;
    double openingBal = 0.0;
    double totalDeb = 0.0;
    double totalCred = 0.0;

    // From ledger entries
    for (var entry in ledgerController.ledgerEntries) {
      balance += entry.debit - entry.credit;
      if (entry.debit > 0) {
        sales += entry.debit; // Assuming debits are sales
        totalDeb += entry.debit;
      }
      if (entry.credit > 0) {
        payments += entry.credit; // Assuming credits are payments received
        totalCred += entry.credit;
      }
    }

    // Stock value
    for (var product in inventoryController.products) {
      stockVal += product.price * product.stock;
    }

    // Opening balance (assuming first entry or something, but for now 0)
    openingBal = 0.0;
    double closingBal = openingBal + totalDeb - totalCred;

    currentBalance.value = balance;
    totalSales.value = sales;
    totalPayments.value = payments;
    stockValue.value = stockVal;

    openingBalance.value = openingBal;
    totalDebit.value = totalDeb;
    totalCredit.value = totalCred;
    closingBalance.value = closingBal;

    // Recent transactions: last 5
    recentTransactions.value = ledgerController.ledgerEntries.reversed
        .take(5)
        .toList();

    // Low stock: products with stock < 10
    lowStockProducts.value = inventoryController.products
        .where((p) => p.stock < 10)
        .toList();

    // Invoices
    invoices.value = inventoryController.invoices;
  }
}
