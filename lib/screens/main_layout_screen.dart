import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/layout_controller.dart';
import '../widgets/sidebar.dart';
import '../features/dashboard/views/dashboard_view.dart';
import '../features/inventory/views/inventory_view.dart';
import '../features/transactions/views/transactions_view.dart';
import '../features/ledger/views/ledger_view.dart';
import '../features/reports/views/reports_view.dart';
import '../features/backup/views/backup_view.dart';

class MainLayoutScreen extends StatelessWidget {
  final LayoutController controller = Get.put(LayoutController());

  final List<Widget> _screens = [
    DashboardView(),
    InventoryView(),
    TransactionsView(),
    LedgerView(),
    ReportsView(),
    BackupView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: GetBuilder<LayoutController>(
              builder: (controller) => AnimatedSwitcher(
                key: ValueKey(controller.selectedIndex),
                duration: Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _screens[controller.selectedIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
