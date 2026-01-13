import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/saas_table.dart';
import '../controllers/ledger_controller.dart';
import '../models/ledger_entry_model.dart';

class LedgerView extends StatelessWidget {
  final LedgerController controller = Get.put(LedgerController());

  List<Map<String, String>> _buildLedgerRows(List<LedgerEntry> entries) {
    double runningBalance = 0;
    return entries.map((entry) {
      runningBalance += entry.debit - entry.credit;
      String balanceStr = formatCurrency(runningBalance.abs());
      String label = runningBalance >= 0 ? 'Dr' : 'Cr';
      return {
        'Date': formatDate(entry.date),
        'Description': entry.description,
        'Debit': entry.debit > 0 ? formatCurrency(entry.debit) : '',
        'Credit': entry.credit > 0 ? formatCurrency(entry.credit) : '',
        'Balance': '$balanceStr $label',
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: Obx(
        () => SaaSTable(
          title: 'Ledger',
          subtitle: 'Track all financial transactions',
          columns: ['Date', 'Description', 'Debit', 'Credit', 'Balance'],
          columnTypes: ['text', 'text', 'currency', 'currency', 'balance'],
          rows: controller.ledgerEntries
              .map(
                (entry) => {
                  'Date': formatDate(entry.date),
                  'Description': entry.description,
                  'Debit': entry.debit > 0 ? formatCurrency(entry.debit) : '',
                  'Credit': entry.credit > 0
                      ? formatCurrency(entry.credit)
                      : '',
                  'Balance': '1000 Dr', // Need to calculate proper balance
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
