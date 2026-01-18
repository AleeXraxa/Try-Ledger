import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/helpers.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../controllers/inventory_controller.dart';
import '../../company/controllers/company_controller.dart';
import 'edit_product_dialog.dart';

class ViewAllProductsDialog extends StatelessWidget {
  final InventoryController controller = Get.find<InventoryController>();
  final CompanyController companyController = Get.find<CompanyController>();

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
            Expanded(child: Obx(() => _buildProductsTable())),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsTable() {
    if (controller.products.isEmpty) {
      return Center(
        child: Text('No products added yet.', style: AppStyles.bodyStyle),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 16,
                headingRowHeight: 56,
                dataRowHeight: 52,
                headingRowColor: MaterialStateProperty.all(
                  AppColors.primary.withOpacity(0.05),
                ),
                columns: [
                  DataColumn(
                    label: Text(
                      'S.No',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Company',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Price',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                rows: controller.products.asMap().entries.map((entry) {
                  int index = entry.key;
                  var product = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          (index + 1).toString(),
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(Text(product.name, style: AppStyles.bodyStyle)),
                      DataCell(
                        Text(
                          product.companyId != null
                              ? (companyController.companies
                                        .firstWhereOrNull(
                                          (c) => c.id == product.companyId,
                                        )
                                        ?.name ??
                                    'Unknown')
                              : 'N/A',
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(
                        Text(
                          formatCurrency(product.price),
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  color: Colors.blue,
                                ),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      EditProductDialog(product: product),
                                ),
                                tooltip: 'Edit',
                                iconSize: 20,
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_outlined,
                                  color: Colors.red,
                                ),
                                onPressed: () =>
                                    _deleteProduct(context, product.id),
                                tooltip: 'Delete',
                                iconSize: 20,
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteProduct(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Delete Product', style: AppStyles.headingStyle),
        content: Text(
          'Are you sure you want to delete this product?',
          style: AppStyles.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppStyles.bodyStyle.copyWith(
                color: AppColors.neutral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await controller.deleteProduct(id);
              Navigator.of(context).pop();
              _showSuccessDialog(
                context,
                'Product has been deleted successfully.',
              );
            },
            child: Text(
              'Delete',
              style: AppStyles.bodyStyle.copyWith(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text(
              'Success!',
              style: AppStyles.headingStyle.copyWith(
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
        content: Text(message, style: AppStyles.bodyStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppStyles.bodyStyle.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
