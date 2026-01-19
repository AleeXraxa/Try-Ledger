import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../controllers/doctor_controller.dart';
import '../models/doctor_model.dart';

class AddDoctorDialog extends StatefulWidget {
  @override
  _AddDoctorDialogState createState() => _AddDoctorDialogState();
}

class _AddDoctorDialogState extends State<AddDoctorDialog> {
  final DoctorController controller = Get.put(DoctorController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? nameError;
  String? emailError;

  @override
  void dispose() {
    _nameController.dispose();
    _specializationController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validation
    String? nError;

    if (_nameController.text.trim().isEmpty) {
      nError = 'Doctor name is required';
    }

    // Email validation if provided
    String? eError;
    if (_emailController.text.trim().isNotEmpty &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text)) {
      eError = 'Please enter a valid email';
    }

    if (nError != null || eError != null) {
      setState(() {
        nameError = nError;
        emailError = eError;
      });
      return;
    }

    final doctor = Doctor(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      specialization: _specializationController.text.trim().isEmpty
          ? ''
          : _specializationController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? ''
          : _addressController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? ''
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? ''
          : _emailController.text.trim(),
    );

    controller
        .addDoctor(doctor)
        .then((_) {
          Navigator.of(context).pop();
          _showSuccessDialog(context, 'Doctor has been added successfully.');
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
                  'Add Doctor',
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
              'Doctor Name',
              Icons.person,
              _nameController,
              'Enter doctor name',
              errorText: nameError,
            ),
            SizedBox(height: 16),
            _buildFormField(
              'Specialization',
              Icons.medical_services,
              _specializationController,
              'Enter specialization',
            ),
            SizedBox(height: 16),
            _buildFormField(
              'Address',
              Icons.location_on,
              _addressController,
              'Enter address',
            ),
            SizedBox(height: 16),
            _buildFormField(
              'Phone',
              Icons.phone,
              _phoneController,
              'Enter phone number',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            _buildFormField(
              'Email',
              Icons.email,
              _emailController,
              'Enter email address',
              keyboardType: TextInputType.emailAddress,
              errorText: emailError,
            ),
            SizedBox(height: 24),
            _buildPremiumButton(
              'Add Doctor',
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
