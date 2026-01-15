import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/saas_table.dart';
import '../controllers/inventory_controller.dart';

class ViewAllProductsDialog extends StatelessWidget {
  final InventoryController controller = Get.find<InventoryController>();

  List<Map<String, String>> _buildProductRows(List products) {
    return products.asMap().entries.map<Map<String, String>>((entry) {
      int index = entry.key;
      var product = entry.value;
      return {
        'S.No': (index + 1).toString(),
        'Name': product.name,
        'Price': formatCurrency(product.price),
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 800,
        height: 600,
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.background,
              AppColors.background.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 40,
              offset: Offset(0, 20),
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.1),
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
                  'All Products',
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(Icons.close, color: AppColors.neutral),
                ),
              ],
            ),
            SizedBox(height: 24),
            Expanded(
              child: Obx(
                () => SaaSTable(
                  title: '',
                  subtitle: null,
                  columns: ['S.No', 'Name', 'Price'],
                  columnTypes: ['text', 'text', 'currency'],
                  rows: _buildProductRows(controller.products),
                  onAddPressed: () {},
                  onFilterPressed: () {},
                  onExportPressed: () {},
                  onRowTap: (index) {},
                  onActionPressed: (index, action) {},
                  isLoading: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
