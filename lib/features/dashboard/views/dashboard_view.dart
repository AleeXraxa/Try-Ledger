import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../widgets/custom_card.dart';
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

              // Overview Section
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sales Trend',
                            style: AppStyles.headingStyle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: Obx(
                              () => LineChart(
                                LineChartData(
                                  gridData: FlGridData(show: false),
                                  titlesData: FlTitlesData(show: false),
                                  borderData: FlBorderData(show: false),
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: controller.salesData
                                          .asMap()
                                          .entries
                                          .map(
                                            (e) => FlSpot(
                                              e.key.toDouble(),
                                              e.value,
                                            ),
                                          )
                                          .toList(),
                                      isCurved: true,
                                      color: AppColors.accent,
                                      barWidth: 3,
                                      belowBarData: BarAreaData(show: false),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: CustomCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ledger Summary',
                            style: AppStyles.headingStyle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 16),
                          Obx(
                            () => Column(
                              children: [
                                _buildLedgerRow(
                                  'Opening Balance',
                                  controller.openingBalance.value,
                                ),
                                _buildLedgerRow(
                                  'Total Debit',
                                  controller.totalDebit.value,
                                ),
                                _buildLedgerRow(
                                  'Total Credit',
                                  controller.totalCredit.value,
                                ),
                                Divider(),
                                _buildLedgerRow(
                                  'Closing Balance',
                                  controller.closingBalance.value,
                                  isBold: true,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Recent Activity
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recent Activity',
                      style: AppStyles.headingStyle.copyWith(fontSize: 18),
                    ),
                    SizedBox(height: 16),
                    Obx(
                      () => ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: controller.recentTransactions.length,
                        itemBuilder: (context, index) {
                          LedgerEntry entry =
                              controller.recentTransactions[index];
                          return ListTile(
                            leading: Icon(
                              entry.debit > 0
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              color: entry.debit > 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(entry.description),
                            subtitle: Text(formatDate(entry.date)),
                            trailing: Text(
                              entry.debit > 0
                                  ? '+${formatCurrency(entry.debit)}'
                                  : '-${formatCurrency(entry.credit)}',
                              style: TextStyle(
                                color: entry.debit > 0
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () =>
                                layoutController.selectIndex(3), // Ledger
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Stock Alerts
              Obx(
                () => controller.lowStockProducts.isNotEmpty
                    ? CustomCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stock Alerts',
                              style: AppStyles.headingStyle.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: controller.lowStockProducts.length,
                              itemBuilder: (context, index) {
                                Product product =
                                    controller.lowStockProducts[index];
                                return ListTile(
                                  title: Text(product.name),
                                  subtitle: Text('Stock: ${product.stock}'),
                                  trailing: Icon(
                                    Icons.warning,
                                    color: Colors.orange,
                                  ),
                                  onTap: () => layoutController.selectIndex(
                                    1,
                                  ), // Inventory
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
    return Obx(
      () => CustomCard(
        child: Column(
          children: [
            Text(
              title,
              style: AppStyles.bodyStyle.copyWith(color: AppColors.neutral),
            ),
            SizedBox(height: 8),
            Text(
              formatCurrency(value.value),
              style: AppStyles.headingStyle.copyWith(
                fontSize: 28,
                color: AppColors.primary,
              ),
            ),
            if (subtitle.isNotEmpty) Text(subtitle, style: AppStyles.bodyStyle),
          ],
        ),
      ),
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
}
