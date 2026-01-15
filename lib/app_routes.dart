import 'package:get/get.dart';
import 'features/dashboard/views/dashboard_view.dart';
import 'features/inventory/views/inventory_view.dart';
import 'features/ledger/views/ledger_view.dart';
import 'features/reports/views/reports_view.dart';
import 'features/backup/views/backup_view.dart';

class AppRoutes {
  static const dashboard = '/dashboard';
  static const inventory = '/inventory';
  static const ledger = '/ledger';
  static const reports = '/reports';
  static const backup = '/backup';

  static final routes = [
    GetPage(name: dashboard, page: () => DashboardView()),
    GetPage(name: inventory, page: () => InventoryView()),
    GetPage(name: ledger, page: () => LedgerView()),
    GetPage(name: reports, page: () => ReportsView()),
    GetPage(name: backup, page: () => BackupView()),
  ];
}
