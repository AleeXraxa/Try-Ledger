import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/saas_table.dart';
import '../controllers/transactions_controller.dart';
import '../models/transaction_model.dart';

class TransactionsView extends StatelessWidget {
  final TransactionsController controller = Get.put(TransactionsController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: Obx(
        () => SaaSTable(
          title: 'Transactions',
          subtitle: 'View all sales and purchases',
          columns: ['Date', 'Type', 'Amount', 'Actions'],
          columnTypes: ['text', 'text', 'currency', 'actions'],
          rows: controller.transactions
              .map(
                (transaction) => {
                  'Date': formatDate(transaction.date),
                  'Type': transaction.type.isNotEmpty
                      ? '${transaction.type[0].toUpperCase()}${transaction.type.substring(1)}'
                      : '',
                  'Amount': formatCurrency(transaction.amount),
                },
              )
              .toList(),
          onAddPressed: () {
            // Add transaction
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
