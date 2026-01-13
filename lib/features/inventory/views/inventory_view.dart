import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/saas_table.dart';
import '../controllers/inventory_controller.dart';
import '../models/product_model.dart';

class InventoryView extends StatelessWidget {
  final InventoryController controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: Obx(
        () => SaaSTable(
          title: 'Inventory',
          subtitle: 'Manage your product stock',
          columns: ['Name', 'Stock', 'Price', 'Value', 'Actions'],
          columnTypes: ['text', 'numeric', 'currency', 'currency', 'actions'],
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
            // View details
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
    );
  }
}
