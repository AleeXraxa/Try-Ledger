import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/layout_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import '../utils/screen_utils.dart';

class Sidebar extends StatelessWidget {
  final LayoutController controller = Get.put(LayoutController());

  final List<String> menuItems = [
    'Dashboard',
    'Inventory',
    'Transactions',
    'Ledger',
    'Reports',
    'Backup',
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard,
    Icons.inventory,
    Icons.swap_horiz,
    Icons.book,
    Icons.bar_chart,
    Icons.backup,
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LayoutController>(
      builder: (controller) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: controller.isCollapsed ? 75 : 250,
        color: AppColors.sidebarBackground,
        child: Column(
          children: [
            SizedBox(height: ScreenUtils.setHeight(10)),
            // Toggle button
            IconButton(
              icon: AnimatedRotation(
                turns: controller.isCollapsed ? 0.5 : 0,
                duration: Duration(milliseconds: 300),
                child: Icon(Icons.menu, color: Colors.white),
              ),
              onPressed: () => controller.toggleSidebar(),
            ),
            SizedBox(height: ScreenUtils.setHeight(10)),
            // Logo or title
            AnimatedOpacity(
              opacity: controller.isCollapsed ? 0 : 1,
              duration: Duration(milliseconds: 200),
              child: Text(
                'TryLedger',
                style: AppStyles.headingStyle.copyWith(color: Colors.white),
              ),
            ),
            SizedBox(height: ScreenUtils.setHeight(20)),
            // Menu items
            Expanded(
              child: ListView.builder(
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return Tooltip(
                    message: controller.isCollapsed ? menuItems[index] : '',
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: controller.selectedIndex == index
                            ? AppColors.accent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () => controller.selectIndex(index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                menuIcons[index],
                                color: controller.selectedIndex == index
                                    ? AppColors.accent
                                    : Colors.white70,
                                size: 24,
                              ),
                              if (!controller.isCollapsed) ...[
                                SizedBox(width: 16),
                                AnimatedOpacity(
                                  opacity: controller.isCollapsed ? 0 : 1,
                                  duration: Duration(milliseconds: 200),
                                  child: AnimatedSlide(
                                    offset: controller.isCollapsed
                                        ? Offset(-1, 0)
                                        : Offset.zero,
                                    duration: Duration(milliseconds: 200),
                                    child: Text(
                                      menuItems[index],
                                      style: AppStyles.bodyStyle.copyWith(
                                        color: controller.selectedIndex == index
                                            ? AppColors.accent
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
