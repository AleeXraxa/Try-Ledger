import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../controllers/dr_ledger_controller.dart';
import '../controllers/doctor_controller.dart';
import '../models/dr_ledger_entry_model.dart';

class AddDrEntryDialog extends StatefulWidget {
  @override
  _AddDrEntryDialogState createState() => _AddDrEntryDialogState();
}

class _AddDrEntryDialogState extends State<AddDrEntryDialog> {
  final DrLedgerController controller = Get.find<DrLedgerController>();
  final DoctorController doctorController = Get.find<DoctorController>();

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String selectedType = 'Advance Payment';
  int? selectedDoctorId;
  String? descriptionError;
  String? amountError;
  String? doctorError;
  double? calculatedBusinessValue;

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _calculateBusinessValue() {
    if (selectedType == 'Advance Payment') {
      double? amount = double.tryParse(amountController.text);
      if (amount != null && amount > 0) {
        calculatedBusinessValue = amount * 100 / 30;
      } else {
        calculatedBusinessValue = null;
      }
    } else {
      calculatedBusinessValue = null;
    }
    setState(() {});
  }

  void _submitForm() {
    // Validation
    String? descError;
    String? amtError;
    String? docError;

    if (descriptionController.text.trim().isEmpty) {
      descError = 'Description is required';
    }
    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      amtError = 'Please enter a valid amount greater than 0';
    }
    if (selectedDoctorId == null) {
      docError = 'Please select a doctor';
    }

    if (descError != null || amtError != null || docError != null) {
      setState(() {
        descriptionError = descError;
        amountError = amtError;
        doctorError = docError;
      });
      return;
    }

    print('Dr Ledger Entry: Type=${selectedType}, Amount=${amount}');
    final entry = DrLedgerEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      description: descriptionController.text.trim(),
      debit: selectedType == 'Advance Payment' ? amount! : 0,
      credit: selectedType == 'Sales' ? amount! : 0,
      date: selectedDate,
      doctorId: selectedDoctorId,
    );

    controller
        .addDrLedgerEntry(entry)
        .then((_) {
          controller.applyDateFilter(); // Refresh filtered entries
          Navigator.of(context).pop();
          _showSuccessDialog(context, 'Dr Entry has been added successfully.');
        })
        .catchError((e) {
          // Handle error
        });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                  'Add Dr Entry',
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
            _buildTypeDropdown(),
            SizedBox(height: 16),
            _buildFormField(
              'Amount',
              Icons.attach_money,
              amountController,
              '0.00',
              keyboardType: TextInputType.number,
              errorText: amountError,
              onChanged: (value) => _calculateBusinessValue(),
            ),
            if (calculatedBusinessValue != null) ...[
              SizedBox(height: 8),
              Text(
                'Calculated Business Value: ${calculatedBusinessValue!.toStringAsFixed(2)}',
                style: AppStyles.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
            SizedBox(height: 16),
            _buildDoctorDropdown(errorText: doctorError),
            SizedBox(height: 16),
            _buildDateField(),
            SizedBox(height: 24),
            _buildPremiumButton(
              'Add Dr Entry',
              Icons.add,
              AppColors.primary,
              _submitForm,
            ),
          ],
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
    Function(String)? onChanged,
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
          onChanged: onChanged,
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

  Widget _buildTypeDropdown() {
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
        DropdownButtonFormField<String>(
          value: selectedType,
          items: [
            DropdownMenuItem(
              value: 'Advance Payment',
              child: Text('Advance Payment'),
            ),
            DropdownMenuItem(value: 'Sales', child: Text('Sales')),
          ],
          onChanged: (value) {
            setState(() {
              selectedType = value!;
              _calculateBusinessValue();
            });
          },
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.category, color: AppColors.primary),
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
        ),
      ],
    );
  }

  Widget _buildDoctorDropdown({String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Doctor',
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Obx(() {
          return DropdownButtonFormField<int?>(
            value: selectedDoctorId,
            hint: Text('Select Doctor'),
            items: doctorController.doctors
                .where((doctor) => doctor.isActive)
                .map((doctor) {
                  return DropdownMenuItem<int?>(
                    value: doctor.id,
                    child: Text(doctor.name),
                  );
                })
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedDoctorId = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neutral.withOpacity(0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.neutral.withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.background.withOpacity(0.5),
              errorText: errorText,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateField() {
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
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null) {
              setState(() {
                selectedDate = picked;
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.neutral.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.background.withOpacity(0.5),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                SizedBox(width: 12),
                Text(
                  '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: AppStyles.bodyStyle,
                ),
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 12),
            Text(
              'Success!',
              style: AppStyles.headingStyle.copyWith(
                color: Colors.green.shade800,
              ),
            ),
          ],
        ),
        content: Text(message, style: AppStyles.bodyStyle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppStyles.bodyStyle.copyWith(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
