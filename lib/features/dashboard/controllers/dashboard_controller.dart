import 'package:get/get.dart';
import '../services/dashboard_service.dart';
import '../models/dashboard_model.dart';
import '../../ledger/models/ledger_entry_model.dart';
import '../../inventory/models/product_model.dart';
import '../../inventory/models/invoice_model.dart';
import '../../ledger/controllers/ledger_controller.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../../dr_ledger/controllers/dr_ledger_controller.dart';
import '../../dr_ledger/controllers/doctor_controller.dart';

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

  // Recent activities
  var recentActivities = <ActivityItem>[].obs;

  // Low stock alerts
  var lowStockProducts = <Product>[].obs;

  // Invoices
  var invoices = <Invoice>[].obs;

  @override
  void onInit() {
    super.onInit();
    Get.put(LedgerController());
    Get.put(InventoryController());
    Get.put(DrLedgerController());
    Get.put(DoctorController());
    final ledgerController = Get.find<LedgerController>();
    final inventoryController = Get.find<InventoryController>();
    final drLedgerController = Get.find<DrLedgerController>();
    ever(ledgerController.ledgerEntries, (_) => loadData());
    ever(inventoryController.products, (_) => loadData());
    ever(inventoryController.invoices, (_) => loadData());
    ever(drLedgerController.drLedgerEntries, (_) => loadData());
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

    // Recent activities: collect from multiple sources
    List<ActivityItem> activities = [];

    // Add Dr Ledger entries
    final drLedgerController = Get.find<DrLedgerController>();
    final doctorController = Get.find<DoctorController>();

    for (var entry in drLedgerController.drLedgerEntries) {
      String? doctorName;
      if (entry.companyId != null) {
        final doctor = doctorController.doctors.firstWhereOrNull(
          (d) => d.id == entry.companyId,
        );
        doctorName = doctor?.name;
      }

      if (entry.debit > 0) {
        activities.add(
          ActivityItem(
            id: entry.id,
            description: entry.description,
            amount: entry.debit,
            date: entry.date,
            activityType: ActivityType.drLedger,
            transactionType: TransactionType.debit,
            doctorName: doctorName,
          ),
        );
      }

      if (entry.credit > 0) {
        activities.add(
          ActivityItem(
            id: entry.id,
            description: entry.description,
            amount: entry.credit,
            date: entry.date,
            activityType: ActivityType.drLedger,
            transactionType: TransactionType.credit,
            doctorName: doctorName,
          ),
        );
      }
    }

    // Add Company Ledger entries
    for (var entry in ledgerController.ledgerEntries) {
      if (entry.debit > 0) {
        activities.add(
          ActivityItem(
            id: entry.id,
            description: entry.description,
            amount: entry.debit,
            date: entry.date,
            activityType: ActivityType.companyLedger,
            transactionType: TransactionType.debit,
            referenceNo: entry.referenceNo,
          ),
        );
      }

      if (entry.credit > 0) {
        activities.add(
          ActivityItem(
            id: entry.id,
            description: entry.description,
            amount: entry.credit,
            date: entry.date,
            activityType: ActivityType.companyLedger,
            transactionType: TransactionType.credit,
            referenceNo: entry.referenceNo,
          ),
        );
      }
    }

    // Sort by date (most recent first) and take top 10
    activities.sort((a, b) => b.date.compareTo(a.date));
    recentActivities.value = activities.take(10).toList();

    // Low stock: products with stock < 10
    lowStockProducts.value = inventoryController.products
        .where((p) => p.stock < 10)
        .toList();

    // Invoices
    invoices.value = inventoryController.invoices;
  }
}
