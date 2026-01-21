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
import '../../ledger/controllers/ledger_controller.dart';
import '../../inventory/views/add_product_dialog.dart';
import '../../inventory/views/purchase_dialog.dart';
import '../../dr_ledger/views/add_doctor_dialog.dart';
import '../../dr_ledger/views/add_dr_entry_dialog.dart';
import '../../dr_ledger/models/doctor_model.dart';

class DashboardView extends StatelessWidget {
  final DashboardController controller = Get.put(DashboardController());
  final LayoutController layoutController = Get.put(LayoutController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(ScreenUtils.setWidth(16)),
        child: AnimationLimiter(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AnimationConfiguration.toStaggeredList(
              duration: const Duration(milliseconds: 375),
              childAnimationBuilder: (widget) => SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(child: widget),
              ),
              children: [
                // Welcome Message
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.15),
                        AppColors.primary.withOpacity(0.08),
                        AppColors.accent.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.05),
                        blurRadius: 40,
                        offset: Offset(0, 16),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 6,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.accent],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.waving_hand,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          SizedBox(width: 16),
                          Text(
                            'Welcome back',
                            style: AppStyles.headingStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Waseem Ali Abbasi',
                        style: AppStyles.headingStyle.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ready to manage your business today?',
                        style: AppStyles.bodyStyle.copyWith(
                          fontSize: 16,
                          color: AppColors.neutral,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Doctor Performance Section
                Obx(() {
                  return Container(
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
                              'Doctor Performance',
                              style: AppStyles.headingStyle.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 24),
                        if (controller.bestDoctor.value != null ||
                            controller.worstDoctor.value != null)
                          Row(
                            children: [
                              if (controller.bestDoctor.value != null)
                                _buildDoctorCard(
                                  'Top Performer',
                                  controller.bestDoctor.value!,
                                  controller.bestDoctorBusinessValue.value,
                                  controller.bestDoctorSales.value,
                                  controller.bestDoctorClosingBalance.value,
                                  Colors.green,
                                )
                              else
                                _buildEmptyCard('Top Performer'),
                              SizedBox(width: 16),
                              if (controller.worstDoctor.value != null)
                                _buildDoctorCard(
                                  'Worst Performer',
                                  controller.worstDoctor.value!,
                                  controller.worstDoctorBusinessValue.value,
                                  controller.worstDoctorSales.value,
                                  controller.worstDoctorClosingBalance.value,
                                  Colors.red,
                                )
                              else
                                _buildEmptyCard('Worst Performer'),
                            ],
                          )
                        else
                          Center(
                            child: Text(
                              'No doctor performance data available',
                              style: AppStyles.bodyStyle.copyWith(
                                color: AppColors.neutral,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 24),
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
                      GridView.count(
                        childAspectRatio: 3,
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildQuickActionButton(
                            'Company',
                            Icons.business,
                            () => layoutController.selectIndex(1),
                          ),
                          _buildQuickActionButton(
                            'Add Company Ledger Entry',
                            Icons.add,
                            () => layoutController.selectIndex(2),
                          ),
                          _buildQuickActionButton(
                            'Add Product',
                            Icons.add_box,
                            () => showDialog(
                              context: context,
                              builder: (context) => AddProductDialog(),
                            ),
                          ),
                          _buildQuickActionButton(
                            'Add Invoice',
                            Icons.receipt,
                            () => showDialog(
                              context: context,
                              builder: (context) => PurchaseDialog(),
                            ),
                          ),
                          _buildQuickActionButton(
                            'Add Doctor',
                            Icons.local_hospital,
                            () => showDialog(
                              context: context,
                              builder: (context) => AddDoctorDialog(),
                            ),
                          ),
                          _buildQuickActionButton(
                            'Add Doctor Ledger Entry',
                            Icons.account_balance,
                            () => showDialog(
                              context: context,
                              builder: (context) => AddDrEntryDialog(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            padding: EdgeInsets.all(20),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                SizedBox(height: 12),
                Text(
                  title,
                  style: AppStyles.bodyStyle.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDoctorCard(
    String title,
    Doctor doctor,
    double businessValue,
    double sales,
    double closingBalance,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: color, size: 20),
                SizedBox(width: 8),
                Text(
                  title,
                  style: AppStyles.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              doctor.name,
              style: AppStyles.headingStyle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Actual Business Value: Rs. ${businessValue.toStringAsFixed(2)}',
              style: AppStyles.bodyStyle.copyWith(
                fontSize: 12,
                color: AppColors.neutral,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Sales: Rs. ${sales.toStringAsFixed(2)}',
              style: AppStyles.bodyStyle.copyWith(
                fontSize: 12,
                color: AppColors.neutral,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Closing Balance: Rs. ${closingBalance.toStringAsFixed(2)}',
              style: AppStyles.bodyStyle.copyWith(
                fontSize: 12,
                color: AppColors.neutral,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String title) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, color: Colors.grey, size: 24),
            SizedBox(height: 8),
            Text(
              title,
              style: AppStyles.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'No data',
              style: AppStyles.bodyStyle.copyWith(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
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
                    ],
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      errorText: descriptionError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.background.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Amount (Rs.)',
                      errorText: amountError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.background.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.background.withOpacity(0.5),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'debit',
                              child: Text('Debit'),
                            ),
                            DropdownMenuItem(
                              value: 'credit',
                              child: Text('Credit'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => selectedType = value!);
                          },
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101),
                            );
                            if (picked != null && picked != selectedDate) {
                              setState(() => selectedDate = picked);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: AppColors.background.withOpacity(0.5),
                            ),
                            child: Text(formatDate(selectedDate)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () async {
                          // Validate inputs
                          setState(() {
                            descriptionError =
                                descriptionController.text.isEmpty
                                ? 'Description is required'
                                : null;
                            amountError = amountController.text.isEmpty
                                ? 'Amount is required'
                                : null;
                          });

                          if (descriptionError != null || amountError != null) {
                            return;
                          }

                          final double amount = double.parse(
                            amountController.text,
                          );
                          final updatedEntry = LedgerEntry(
                            id:
                                entry?.id ??
                                DateTime.now().millisecondsSinceEpoch,
                            description: descriptionController.text,
                            debit: selectedType == 'debit' ? amount : 0.0,
                            credit: selectedType == 'credit' ? amount : 0.0,
                            date: selectedDate,
                          );

                          final ledgerController = Get.find<LedgerController>();
                          if (entry == null) {
                            await ledgerController.addLedgerEntry(updatedEntry);
                          } else {
                            await ledgerController.updateLedgerEntry(
                              updatedEntry,
                            );
                          }

                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                entry == null
                                    ? 'Ledger entry added successfully!'
                                    : 'Ledger entry updated successfully!',
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          entry == null ? 'Add Entry' : 'Update Entry',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
