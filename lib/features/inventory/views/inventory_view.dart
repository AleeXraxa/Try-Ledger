import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_card.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../controllers/inventory_controller.dart';
import '../models/invoice_model.dart';
import '../../company/controllers/company_controller.dart';
import 'add_product_dialog.dart';
import 'purchase_dialog.dart';
import 'invoice_details_dialog.dart';
import 'view_all_products_dialog.dart';

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
                    Icon(
                      Icons.receipt_long,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Purchase Invoices',
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
                      'View All Products',
                      Icons.view_list,
                      AppColors.accent,
                      () {
                        showDialog(
                          context: context,
                          builder: (context) => ViewAllProductsDialog(),
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
                  'Manage your purchase invoices',
                  style: AppStyles.bodyStyle.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Obx(() {
            int totalInvoices = controller.filteredInvoices.length;
            double totalAmount = controller.filteredInvoices.fold(
              0.0,
              (sum, invoice) => sum + invoice.total,
            );
            return Row(
              children: [
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Total Invoices',
                          style: AppStyles.bodyStyle.copyWith(
                            color: AppColors.neutral,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          totalInvoices.toString(),
                          style: AppStyles.headingStyle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Total Amount',
                          style: AppStyles.bodyStyle.copyWith(
                            color: AppColors.neutral,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          formatCurrency(totalAmount),
                          style: AppStyles.headingStyle.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
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
                      'Filter Invoices',
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
                        true, // isFromDate
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePicker(
                        'To Date',
                        Icons.calendar_today,
                        false, // isFromDate
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(child: _buildCompanyDropdown()),
                    SizedBox(width: 16),
                    _buildPremiumButton(
                      'Apply Filter',
                      Icons.filter_list,
                      AppColors.primary,
                      () {
                        controller.applyDateFilter();
                      },
                    ),
                    SizedBox(width: 12),
                    Obx(
                      () => controller.isFiltered.value
                          ? _buildPremiumButton(
                              'Clear Filter',
                              Icons.clear,
                              Colors.grey,
                              () {
                                controller.clearFilter();
                              },
                            )
                          : SizedBox.shrink(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(child: Obx(() => _buildInvoicesTable())),
        ],
      ),
    );
  }

  Widget _buildInvoicesTable() {
    final companyController = Get.find<CompanyController>();
    if (controller.filteredInvoices.isEmpty) {
      return Center(
        child: Text('No invoices found.', style: AppStyles.bodyStyle),
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
                      'Invoice Reference',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Company Name',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Invoice Date',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amount',
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
                rows: controller.filteredInvoices.asMap().entries.map((entry) {
                  int index = entry.key;
                  var invoice = entry.value;
                  final company = companyController.companies.firstWhereOrNull(
                    (c) => c.id == invoice.companyId,
                  );
                  final companyName = company?.name ?? 'N/A';
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          (index + 1).toString(),
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(
                        Text(invoice.reference, style: AppStyles.bodyStyle),
                      ),
                      DataCell(Text(companyName, style: AppStyles.bodyStyle)),
                      DataCell(
                        Text(
                          formatDate(invoice.date),
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(
                        Text(
                          formatCurrency(invoice.total),
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
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.visibility_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => showDialog(
                                  context: context,
                                  builder: (context) =>
                                      InvoiceDetailsDialog(invoice: invoice),
                                ),
                                tooltip: 'View',
                                iconSize: 20,
                                padding: EdgeInsets.all(8),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.download_outlined,
                                  color: Colors.green,
                                ),
                                onPressed: () =>
                                    controller.downloadInvoice(invoice),
                                tooltip: 'Download',
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
                                onPressed: () => _deleteInvoice(context, index),
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

  Widget _buildDatePicker(String label, IconData icon, bool isFromDate) {
    return Obx(() {
      DateTime? selectedDate = isFromDate
          ? controller.fromDate.value
          : controller.toDate.value;
      String displayText = selectedDate != null
          ? formatDate(selectedDate)
          : 'Select Date';

      return StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          return InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
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
                if (isFromDate) {
                  controller.fromDate.value = picked;
                } else {
                  controller.toDate.value = picked;
                }
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
                          displayText,
                          style: AppStyles.bodyStyle.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.neutral,
                    size: 20,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildCompanyDropdown() {
    return Obx(() {
      return DropdownButtonFormField<int?>(
        value: controller.selectedCompanyId.value,
        hint: Text('Select Company'),
        isExpanded: true,
        items: [
          DropdownMenuItem<int?>(value: null, child: Text('All Companies')),
          ...Get.find<CompanyController>().companies
              .where((company) => company.isActive)
              .map((company) {
                return DropdownMenuItem<int?>(
                  value: company.id,
                  child: Text(company.name),
                );
              }),
        ],
        onChanged: (value) {
          controller.selectedCompanyId.value = value;
          controller.applyDateFilter();
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.business, color: AppColors.primary),
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
        ),
      );
    });
  }

  void _deleteInvoice(BuildContext context, int index) {
    Invoice invoice = controller.filteredInvoices[index];
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        child: SizedBox(
          width: 400,
          child: Container(
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.delete_forever, color: Colors.red, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Delete Invoice',
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Are you sure you want to delete this invoice? This action cannot be undone.',
                  style: AppStyles.bodyStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
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
                      child: ElevatedButton(
                        onPressed: () {
                          controller.deleteInvoice(invoice.id);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Delete',
                          style: AppStyles.bodyStyle.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
