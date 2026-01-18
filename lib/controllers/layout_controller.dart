import 'package:get/get.dart';
import '../features/ledger/controllers/ledger_controller.dart';

class LayoutController extends GetxController {
  int selectedIndex = 0;
  bool isCollapsed = false;

  void selectIndex(int index) {
    // If navigating away from ledger screen (index 2), reset company selection
    if (selectedIndex == 2 && index != 2) {
      final ledgerController = Get.find<LedgerController>();
      ledgerController.selectCompany(null);
    }
    selectedIndex = index;
    update();
  }

  void toggleSidebar() {
    isCollapsed = !isCollapsed;
    update();
  }
}
