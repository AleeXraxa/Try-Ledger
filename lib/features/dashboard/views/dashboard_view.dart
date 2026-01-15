import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../controllers/layout_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../ledger/models/ledger_entry_model.dart';
import '../../inventory/models/product_model.dart';
import '../../inventory/models/invoice_model.dart';
import '../../ledger/controllers/ledger_controller.dart';
import '../../inventory/views/add_product_dialog.dart';
import '../../inventory/views/purchase_dialog.dart';
import '../../inventory/views/invoice_details_dialog.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final LayoutController layoutController = Get.put(LayoutController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              // KPI Cards
              Row(
                children: [
                  Expanded(
                    child: _buildKPICard(
                      'Balance',
                      controller.closingBalance,
                      '',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildKPICard('Debit', controller.totalDebit, ''),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildKPICard('Credit', controller.totalCredit, ''),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Quick Actions
              Container(
                padding: EdgeInsets.all(24),
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
                          'Quick Actions',
                          style: AppStyles.headingStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickActionButton(
                            'Add Ledger Entry',
                            Icons.add,
                            () => _showAddEntryDialog(context),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            'Add New Product',
                            Icons.add_box,
                            () => showDialog(
                              context: context,
                              builder: (context) => AddProductDialog(),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            'Add Invoice',
                            Icons.receipt,
                            () => showDialog(
                              context: context,
                              builder: (context) => PurchaseDialog(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Overview Section
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
                          'Ledger Summary',
                          style: AppStyles.headingStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Obx(
                      () => Column(
                        children: [
                          _buildPremiumLedgerRow(
                            'Opening Balance',
                            controller.openingBalance.value,
                            icon: Icons.account_balance_wallet,
                          ),
                          SizedBox(height: 16),
                          _buildPremiumLedgerRow(
                            'Total Debit',
                            controller.totalDebit.value,
                            icon: Icons.trending_up,
                            color: Colors.green,
                          ),
                          SizedBox(height: 16),
                          _buildPremiumLedgerRow(
                            'Total Credit',
                            controller.totalCredit.value,
                            icon: Icons.trending_down,
                            color: Colors.red,
                          ),
                          SizedBox(height: 20),
                          Container(
                            height: 1,
                            color: AppColors.neutral.withOpacity(0.2),
                          ),
                          SizedBox(height: 20),
                          _buildPremiumLedgerRow(
                            'Closing Balance',
                            controller.closingBalance.value,
                            icon: Icons.account_balance,
                            isBold: true,
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Recent Activity
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
                          'Recent Activity',
                          style: AppStyles.headingStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Obx(
                      () => controller.recentTransactions.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.history,
                                      size: 48,
                                      color: AppColors.neutral.withOpacity(0.5),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No recent activity',
                                      style: AppStyles.bodyStyle.copyWith(
                                        color: AppColors.neutral,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: List.generate(
                                controller.recentTransactions.length,
                                (index) {
                                  LedgerEntry entry =
                                      controller.recentTransactions[index];
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          index <
                                              controller
                                                      .recentTransactions
                                                      .length -
                                                  1
                                          ? 16
                                          : 0,
                                    ),
                                    child: _buildPremiumActivityRow(
                                      entry,
                                      layoutController,
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, Rx<double> value, String subtitle) {
    IconData getIcon(String title) {
      switch (title) {
        case 'Balance':
          return Icons.account_balance_wallet;
        case 'Debit':
          return Icons.trending_up;
        case 'Credit':
          return Icons.trending_down;
        default:
          return Icons.bar_chart;
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return InkWell(
          onHover: (value) => setState(() => isHovered = value),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            height: 140, // Fixed height for consistency
            padding: EdgeInsets.all(24),
            transform: isHovered
                ? (Matrix4.translationValues(0, -4, 0)..scale(1.02))
                : Matrix4.translationValues(0, 0, 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.background,
                  isHovered
                      ? AppColors.primary.withOpacity(0.05)
                      : AppColors.background.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 40,
                        offset: Offset(0, 20),
                        spreadRadius: 0,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 32,
                        offset: Offset(0, 16),
                        spreadRadius: 0,
                      ),
                    ],
              border: Border.all(
                color: isHovered
                    ? AppColors.primary.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      width: 40,
                      height: 40,
                      transform: isHovered
                          ? Matrix4.diagonal3Values(1.1, 1.1, 1.0)
                          : Matrix4.identity(),
                      decoration: BoxDecoration(
                        color: isHovered
                            ? AppColors.primary.withOpacity(0.2)
                            : AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        getIcon(title),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: AppStyles.bodyStyle.copyWith(
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Obx(
                  () => AnimatedDefaultTextStyle(
                    duration: Duration(milliseconds: 200),
                    style: AppStyles.headingStyle.copyWith(
                      fontSize: 28,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                    child: Text(formatCurrency(value.value)),
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      subtitle,
                      style: AppStyles.bodyStyle.copyWith(
                        color: AppColors.neutral.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
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
            transform: isHovered
                ? (Matrix4.translationValues(0, -2, 0)..scale(1.05))
                : Matrix4.translationValues(0, 0, 0),
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHovered
                    ? [
                        AppColors.primary.withOpacity(0.9),
                        AppColors.primary.withOpacity(0.8),
                      ]
                    : [AppColors.primary, AppColors.primary.withOpacity(0.9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                SizedBox(height: 8),
                Text(
                  title,
                  style: AppStyles.bodyStyle.copyWith(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLedgerRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isBold
                ? AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold)
                : AppStyles.bodyStyle,
          ),
          Text(
            formatCurrency(amount),
            style: isBold
                ? AppStyles.bodyStyle.copyWith(fontWeight: FontWeight.bold)
                : AppStyles.bodyStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLedgerRow(
    String label,
    double amount, {
    required IconData icon,
    Color? color,
    bool isBold = false,
    bool isPrimary = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color ?? AppColors.primary, size: 20),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: AppStyles.bodyStyle.copyWith(
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
              color: isPrimary ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          formatCurrency(amount),
          style: AppStyles.headingStyle.copyWith(
            fontSize: 18,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isPrimary ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumActivityRow(
    LedgerEntry entry,
    LayoutController layoutController,
  ) {
    bool isDebit = entry.debit > 0;
    Color amountColor = isDebit ? Colors.green : Colors.red;
    IconData icon = isDebit ? Icons.arrow_upward : Icons.arrow_downward;
    String amountText = isDebit
        ? '+${formatCurrency(entry.debit)}'
        : '-${formatCurrency(entry.credit)}';

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return InkWell(
          onTap: () => _showLedgerEntryDetails(context, entry),
          onHover: (value) => setState(() => isHovered = value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            transform: isHovered
                ? (Matrix4.translationValues(0, -4, 0)..scale(1.02))
                : Matrix4.translationValues(0, 0, 0),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovered
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.neutral.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  transform: isHovered
                      ? Matrix4.diagonal3Values(1.1, 1.1, 1.0)
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? amountColor.withOpacity(0.2)
                        : amountColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: amountColor, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.description,
                        style: AppStyles.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        formatDate(entry.date),
                        style: AppStyles.bodyStyle.copyWith(
                          fontSize: 12,
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                  child: Text(amountText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumStockAlertRow(
    Product product,
    LayoutController layoutController,
  ) {
    Color alertColor = Colors.orange;
    IconData icon = Icons.warning;

    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        return InkWell(
          onTap: () => layoutController.selectIndex(1), // Inventory
          onHover: (value) => setState(() => isHovered = value),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            transform: isHovered
                ? (Matrix4.translationValues(0, -4, 0)..scale(1.02))
                : Matrix4.translationValues(0, 0, 0),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHovered
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.background.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHovered
                    ? AppColors.primary.withOpacity(0.3)
                    : AppColors.neutral.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.15),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 0),
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  width: 40,
                  height: 40,
                  transform: isHovered
                      ? Matrix4.diagonal3Values(1.1, 1.1, 1.0)
                      : Matrix4.identity(),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? alertColor.withOpacity(0.2)
                        : alertColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: alertColor, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppStyles.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Stock: ${product.stock}',
                        style: AppStyles.bodyStyle.copyWith(
                          fontSize: 12,
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedDefaultTextStyle(
                  duration: Duration(milliseconds: 200),
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: alertColor,
                  ),
                  child: Text('Low'),
                ),
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
                      final ledgerController = Get.find<LedgerController>();
                      if (entry == null) {
                        await ledgerController.addLedgerEntry(updatedEntry);
                      } else {
                        await ledgerController.updateLedgerEntry(updatedEntry);
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

  void _showLedgerEntryDetails(BuildContext context, LedgerEntry entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 400,
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
}
