import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/saas_table.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../controllers/inventory_controller.dart';
import '../models/product_model.dart';
import 'add_product_dialog.dart';
import 'product_details_dialog.dart';
import 'purchase_dialog.dart';

class InventoryView extends StatelessWidget {
  final InventoryController controller = Get.put(InventoryController());

  Widget _buildPremiumButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return InkWell(
          onTap: onPressed,
          onHover: (value) => setState(() => isHovered = value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHovered
                    ? [color.withOpacity(0.9), color.withOpacity(0.8)]
                    : [color, color.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  title,
                  style: AppStyles.bodyStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background,
                  AppColors.background.withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 40,
                  offset: Offset(0, 20),
                  spreadRadius: 0,
                ),
              ],
              border: Border.all(
                color: AppColors.primary.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Inventory',
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    _buildPremiumButton(
                      'Add Product',
                      Icons.add,
                      AppColors.primary,
                      () {
                        showDialog(
                          context: context,
                          builder: (context) => AddProductDialog(),
                        );
                      },
                    ),
                    SizedBox(width: 12),
                    _buildPremiumButton(
                      'Add Invoice',
                      Icons.receipt_long,
                      AppColors.accent,
                      () {
                        showDialog(
                          context: context,
                          builder: (context) => PurchaseDialog(),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Manage your product stock',
                  style: AppStyles.bodyStyle.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Obx(
              () => SaaSTable(
                title: '', // Remove title since we have it above
                subtitle: null,
                columns: ['Name', 'Stock', 'Price', 'Value'],
                columnTypes: ['text', 'numeric', 'currency', 'currency'],
                rows: controller.products
                    .map(
                      (product) => {
                        'Name': product.name,
                        'Stock': product.stock.toString(),
                        'Price': formatCurrency(product.price),
                        'Value': formatCurrency(product.stock * product.price),
                      },
                    )
                    .toList(),
                onAddPressed: () {
                  // Add product
                },
                onFilterPressed: () {
                  // Filter
                },
                onExportPressed: () {
                  // Export
                },
                onRowTap: (index) {
                  showDialog(
                    context: context,
                    builder: (context) => ProductDetailsDialog(
                      product: controller.products[index],
                    ),
                  );
                },
                onActionPressed: (index, action) {
                  if (action == 'edit') {
                    // Edit
                  } else if (action == 'delete') {
                    // Delete
                  }
                },
                isLoading: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
