import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/saas_table.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../controllers/ledger_controller.dart';
import '../models/ledger_entry_model.dart';

class LedgerView extends StatelessWidget {
  final LedgerController controller = Get.put(LedgerController());
  final double openingBalance = 0; // Can be made configurable

  List<Map<String, String>> _buildLedgerRows(List<LedgerEntry> entries) {
    List<Map<String, String>> rows = [];
    double runningBalance = openingBalance;

    // Add opening balance row if there are entries or opening balance is not zero
    if (openingBalance != 0 || entries.isNotEmpty) {
      rows.add({
        'Date': entries.isNotEmpty
            ? formatDate(entries.first.date.subtract(Duration(days: 1)))
            : '',
        'Description': 'Opening Balance',
        'Debit': '',
        'Credit': '',
        'Balance': formatCurrency(openingBalance),
      });
    }

    for (var entry in entries) {
      runningBalance += entry.debit - entry.credit;
      rows.add({
        'Date': formatDate(entry.date),
        'Description': entry.description,
        'Debit': entry.debit > 0 ? formatCurrency(entry.debit) : '',
        'Credit': entry.credit > 0 ? formatCurrency(entry.credit) : '',
        'Balance': formatCurrency(runningBalance),
      });
    }

    return rows;
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
                      'Ledger',
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    _buildPremiumButton(
                      'Add Entry',
                      Icons.add,
                      AppColors.primary,
                      () {
                        _showAddEntryDialog(context);
                      },
                    ),
                    SizedBox(width: 12),
                    _buildPremiumButton(
                      'Generate Report',
                      Icons.bar_chart,
                      AppColors.accent,
                      () {
                        // Generate report logic
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Track all financial transactions',
                  style: AppStyles.bodyStyle.copyWith(color: AppColors.neutral),
                ),
                SizedBox(height: 24),
                // Filter Section
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.background.withOpacity(0.5),
                        AppColors.background.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
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
                            width: 3,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Filter Transactions',
                            style: AppStyles.bodyStyle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePicker(
                              'From Date',
                              Icons.calendar_today,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePicker(
                              'To Date',
                              Icons.calendar_today,
                            ),
                          ),
                          SizedBox(width: 16),
                          _buildPremiumButton(
                            'Apply Filter',
                            Icons.filter_list,
                            AppColors.primary,
                            () {
                              // Apply filter logic
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Obx(
              () => controller.ledgerEntries.isEmpty
                  ? _buildEmptyState(context)
                  : SaaSTable(
                      title: '', // Remove title since we have it above
                      subtitle: null,
                      columns: [
                        'Date',
                        'Description',
                        'Debit',
                        'Credit',
                        'Balance',
                      ],
                      columnTypes: [
                        'text',
                        'text',
                        'currency',
                        'currency',
                        'currency',
                      ],
                      rows: _buildLedgerRows(controller.ledgerEntries),
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
                        if (index == 0)
                          return; // Opening balance row, no details
                        _showEntryDetailsDialog(
                          context,
                          controller.ledgerEntries[index - 1],
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

  Widget _buildDatePicker(String label, IconData icon) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        String selectedDate = 'Select Date';
        return InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: AppColors.background,
                      onSurface: AppColors.textPrimary,
                    ),
                    dialogBackgroundColor: AppColors.background,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => selectedDate = formatDate(picked));
            }
          },
          onHover: (value) => setState(() => isHovered = value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.background.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovered
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.neutral.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isHovered ? AppColors.primary : AppColors.neutral,
                  size: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppStyles.bodyStyle.copyWith(
                          fontSize: 12,
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        selectedDate,
                        style: AppStyles.bodyStyle.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.neutral, size: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddEntryDialog(BuildContext context, [LedgerEntry? entry]) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'debit';
    String? descriptionError;
    String? amountError;
    if (entry != null) {
      descriptionController.text = entry.description;
      selectedType = entry.debit > 0 ? 'debit' : 'credit';
      amountController.text = (entry.debit > 0 ? entry.debit : entry.credit)
          .toString();
      selectedDate = entry.date;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
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
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
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
                        entry == null
                            ? 'Add Ledger Entry'
                            : 'Edit Ledger Entry',
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
                  _buildFormField(
                    'Description',
                    Icons.description,
                    descriptionController,
                    'Enter transaction description',
                    errorText: descriptionError,
                  ),
                  SizedBox(height: 16),
                  _buildTypeDropdown(
                    context,
                    selectedType,
                    (type) => selectedType = type,
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    'Amount',
                    Icons.attach_money,
                    amountController,
                    '0.00',
                    keyboardType: TextInputType.number,
                    errorText: amountError,
                  ),
                  SizedBox(height: 16),
                  _buildDateField(
                    context,
                    selectedDate,
                    (date) => selectedDate = date,
                  ),
                  SizedBox(height: 24),
                  _buildPremiumButton(
                    entry == null ? 'Add Entry' : 'Update Entry',
                    Icons.add,
                    AppColors.primary,
                    () async {
                      // Validation
                      String? descError;
                      String? amtError;
                      if (descriptionController.text.trim().isEmpty) {
                        descError = 'Description is required';
                      }
                      double? amount = double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) {
                        amtError = 'Please enter a valid amount greater than 0';
                      }
                      if (descError != null || amtError != null) {
                        setState(() {
                          descriptionError = descError;
                          amountError = amtError;
                        });
                        return;
                      }
                      // Add entry logic
                      final updatedEntry = LedgerEntry(
                        id: entry?.id ?? DateTime.now().millisecondsSinceEpoch,
                        description: descriptionController.text,
                        debit: selectedType == 'debit' ? amount! : 0,
                        credit: selectedType == 'credit' ? amount! : 0,
                        date: selectedDate,
                      );
                      if (entry == null) {
                        await controller.addLedgerEntry(updatedEntry);
                      } else {
                        await controller.updateLedgerEntry(updatedEntry);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    IconData icon,
    TextEditingController controller,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.neutral.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.neutral.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.background.withOpacity(0.5),
            errorText: errorText,
          ),
          style: AppStyles.bodyStyle,
        ),
      ],
    );
  }

  void _showEntryDetailsDialog(BuildContext context, LedgerEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 500,
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
            mainAxisSize: MainAxisSize.min,
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
                    'Ledger Entry Details',
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
              _buildDetailRow('Description', entry.description),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailRow(
                      'Debit',
                      formatCurrency(entry.debit),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailRow(
                      'Credit',
                      formatCurrency(entry.credit),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildDetailRow('Date', formatDate(entry.date)),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppStyles.bodyStyle.copyWith(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildPremiumButton(
                      'Edit',
                      Icons.edit,
                      AppColors.accent,
                      () {
                        Navigator.of(context).pop();
                        _showAddEntryDialog(context, entry);
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildPremiumButton(
                      'Delete',
                      Icons.delete,
                      Colors.redAccent,
                      () {
                        Navigator.of(context).pop();
                        _showDeleteConfirmation(context, entry.id);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(value, style: AppStyles.bodyStyle),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Delete Entry', style: AppStyles.headingStyle),
        content: Text(
          'Are you sure you want to delete this entry?',
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
              await controller.deleteLedgerEntry(id);
              Navigator.of(context).pop();
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

  Widget _buildDateField(
    BuildContext context,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: AppColors.background,
                      onSurface: AppColors.textPrimary,
                    ),
                    dialogBackgroundColor: AppColors.background,
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background.withOpacity(0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 12),
                Text(formatDate(selectedDate), style: AppStyles.bodyStyle),
                Spacer(),
                Icon(Icons.arrow_drop_down, color: AppColors.neutral),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedType = 'debit';
    String? descriptionError;
    String? amountError;

    return Center(
      child: Container(
        padding: EdgeInsets.all(32),
        constraints: BoxConstraints(maxWidth: 600),
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
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 64,
                  color: AppColors.primary.withOpacity(0.6),
                ),
                SizedBox(height: 16),
                Text(
                  'No Ledger Entries Yet',
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start tracking your financial transactions by adding your first entry below.',
                  style: AppStyles.bodyStyle.copyWith(
                    color: AppColors.neutral,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                _buildFormField(
                  'Description',
                  Icons.description,
                  descriptionController,
                  'Enter transaction description',
                  errorText: descriptionError,
                ),
                SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => _buildTypeDropdown(
                    context,
                    selectedType,
                    (type) => setState(() => selectedType = type),
                  ),
                ),
                SizedBox(height: 16),
                _buildFormField(
                  'Amount',
                  Icons.attach_money,
                  amountController,
                  '0.00',
                  keyboardType: TextInputType.number,
                  errorText: amountError,
                ),
                SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setState) => _buildDateField(
                    context,
                    selectedDate,
                    (date) => setState(() => selectedDate = date),
                  ),
                ),
                SizedBox(height: 24),
                _buildPremiumButton(
                  'Add First Entry',
                  Icons.add,
                  AppColors.primary,
                  () async {
                    // Validation
                    String? descError;
                    String? amtError;
                    if (descriptionController.text.trim().isEmpty) {
                      descError = 'Description is required';
                    }
                    double? amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      amtError = 'Please enter a valid amount greater than 0';
                    }
                    if (descError != null || amtError != null) {
                      setState(() {
                        descriptionError = descError;
                        amountError = amtError;
                      });
                      return;
                    }
                    double debit = selectedType == 'debit' ? amount! : 0;
                    double credit = selectedType == 'credit' ? amount! : 0;
                    final entry = LedgerEntry(
                      id: DateTime.now().millisecondsSinceEpoch,
                      description: descriptionController.text,
                      debit: debit,
                      credit: credit,
                      date: selectedDate,
                    );
                    await controller.addLedgerEntry(entry);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTypeDropdown(
    BuildContext context,
    String selectedType,
    Function(String) onTypeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => SimpleDialog(
                backgroundColor: AppColors.background,
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      onTypeChanged('debit');
                      Navigator.pop(context);
                    },
                    child: Text('Debit', style: AppStyles.bodyStyle),
                  ),
                  SimpleDialogOption(
                    onPressed: () {
                      onTypeChanged('credit');
                      Navigator.pop(context);
                    },
                    child: Text('Credit', style: AppStyles.bodyStyle),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background.withOpacity(0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  selectedType[0].toUpperCase() + selectedType.substring(1),
                  style: AppStyles.bodyStyle,
                ),
                Spacer(),
                Icon(Icons.arrow_drop_down, color: AppColors.neutral),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
