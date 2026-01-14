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
                      'Current Balance',
                      controller.currentBalance,
                      'Dr',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildKPICard(
                      'Total Sales',
                      controller.totalSales,
                      'This Month',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildKPICard(
                      'Payments Received',
                      controller.totalPayments,
                      '',
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildKPICard(
                      'Stock Value',
                      controller.stockValue,
                      '',
                    ),
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
                            () => layoutController.selectIndex(1),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            'Add New Product',
                            Icons.add_box,
                            () => layoutController.selectIndex(2),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            'Add Invoice',
                            Icons.receipt,
                            () => layoutController.selectIndex(3),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickActionButton(
                            'Expenses',
                            Icons.money_off,
                            () => layoutController.selectIndex(3),
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

              // Stock Alerts
              Obx(
                () => controller.lowStockProducts.isNotEmpty
                    ? Container(
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
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Stock Alerts',
                                  style: AppStyles.headingStyle.copyWith(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            ...List.generate(
                              controller.lowStockProducts.length,
                              (index) {
                                Product product =
                                    controller.lowStockProducts[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom:
                                        index <
                                            controller.lowStockProducts.length -
                                                1
                                        ? 16
                                        : 0,
                                  ),
                                  child: _buildPremiumStockAlertRow(
                                    product,
                                    layoutController,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, Rx<double> value, String subtitle) {
    IconData getIcon(String title) {
      switch (title) {
        case 'Current Balance':
          return Icons.account_balance_wallet;
        case 'Total Sales':
          return Icons.trending_up;
        case 'Payments Received':
          return Icons.payment;
        case 'Stock Value':
          return Icons.inventory;
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
            height: 180, // Fixed height for consistency
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
                SizedBox(height: 16),
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
          onTap: () => layoutController.selectIndex(3), // Ledger
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
}
