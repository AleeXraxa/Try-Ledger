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
    'Company',
    'Company Ledger',
    'Invoices',
    'Dr Ledger',
    'Backup',
  ];

  final List<IconData> menuIcons = [
    Icons.dashboard,
    Icons.business,
    Icons.book,
    Icons.inventory,
    Icons.account_balance,
    Icons.backup,
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LayoutController>(
      builder: (controller) => AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: controller.isCollapsed ? 75 : 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.sidebarBackground,
              AppColors.sidebarBackground.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(2, 0),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 40,
              offset: Offset(4, 0),
              spreadRadius: 0,
            ),
          ],
          border: Border(
            right: BorderSide(
              color: AppColors.primary.withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: ScreenUtils.setHeight(20)),
            // Toggle button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: AnimatedRotation(
                  turns: controller.isCollapsed ? 0.5 : 0,
                  duration: Duration(milliseconds: 300),
                  child: Icon(Icons.menu, color: Colors.white, size: 20),
                ),
                onPressed: () => controller.toggleSidebar(),
              ),
            ),
            SizedBox(height: ScreenUtils.setHeight(20)),
            // Logo or title
            AnimatedOpacity(
              opacity: controller.isCollapsed ? 0 : 1,
              duration: Duration(milliseconds: 200),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'TryLedger',
                  style: AppStyles.headingStyle.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(height: ScreenUtils.setHeight(20)),
            // Menu items
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 8),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  return Tooltip(
                    message: controller.isCollapsed ? menuItems[index] : '',
                    child: _buildMenuItem(index, controller),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(int index, LayoutController controller) {
    bool isSelected = controller.selectedIndex == index;
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return InkWell(
          onTap: () => controller.selectIndex(index),
          onHover: (value) => setState(() => isHovered = value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            margin: EdgeInsets.symmetric(vertical: 4),
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: controller.isCollapsed ? 8 : 12,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.08),
                      ],
                    )
                  : isHovered
                  ? LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : isHovered
                    ? Colors.white.withOpacity(0.2)
                    : Colors.transparent,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : isHovered
                        ? Colors.white.withOpacity(0.15)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    menuIcons[index],
                    color: isSelected
                        ? Colors.white
                        : isHovered
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white70,
                    size: 18,
                  ),
                ),
                if (!controller.isCollapsed) ...[
                  SizedBox(width: 12),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 200),
                      style: AppStyles.bodyStyle.copyWith(
                        color: isSelected
                            ? Colors.white
                            : isHovered
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                      child: Text(menuItems[index]),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
