import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_card.dart';
import '../models/invoice_model.dart';

class InvoiceDetailsDialog extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsDialog({Key? key, required this.invoice})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
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
          borderRadius: BorderRadius.circular(0),
          boxShadow: [],
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
                Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
                SizedBox(width: 12),
                Text(
                  'Invoice Details',
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
              flex: 1,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailField(
                            'Invoice Reference',
                            invoice.reference,
                            Icons.receipt,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDetailField(
                            'Invoice Date',
                            formatDate(invoice.date),
                            Icons.calendar_today,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildDetailField(
                      'Total Amount',
                      formatCurrency(invoice.total),
                      Icons.attach_money,
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Items',
                    style: AppStyles.headingStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16),
                  Expanded(child: _buildItemsTable()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value, IconData icon) {
    return CustomCard(
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppStyles.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: AppStyles.bodyStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    if (invoice.items.isEmpty) {
      return Center(
        child: Text('No items in this invoice.', style: AppStyles.bodyStyle),
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
                      'Batch',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Expiry',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Qty',
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
                      'Value',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                rows: invoice.items.asMap().entries.map((entry) {
                  int index = entry.key;
                  var item = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(
                        Text(
                          (index + 1).toString(),
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(Text(item['name'], style: AppStyles.bodyStyle)),
                      DataCell(Text(item['batch'], style: AppStyles.bodyStyle)),
                      DataCell(
                        Text(
                          item['expiry'] != null
                              ? formatDate(DateTime.parse(item['expiry']))
                              : '',
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(
                        Text(
                          item['qty'].toString(),
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(
                        Text(
                          formatCurrency(item['price']),
                          style: AppStyles.bodyStyle,
                        ),
                      ),
                      DataCell(
                        Text(
                          formatCurrency(item['value']),
                          style: AppStyles.bodyStyle,
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
}
