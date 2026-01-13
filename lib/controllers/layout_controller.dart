import 'package:get/get.dart';

class LayoutController extends GetxController {
  int selectedIndex = 0;
  bool isCollapsed = false;

  void selectIndex(int index) {
    selectedIndex = index;
    update();
  }

  void toggleSidebar() {
    isCollapsed = !isCollapsed;
    update();
  }
}
