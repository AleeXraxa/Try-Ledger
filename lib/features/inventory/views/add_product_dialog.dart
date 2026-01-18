import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_fonts.dart';
import '../controllers/inventory_controller.dart';
import '../models/product_model.dart';
import '../../company/controllers/company_controller.dart';
import '../../company/models/company_model.dart';

class AddProductDialog extends StatefulWidget {
  @override
  _AddProductDialogState createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final InventoryController controller = Get.find<InventoryController>();
  final CompanyController companyController = Get.find<CompanyController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  int? selectedCompanyId;
  String? nameError;
  String? priceError;
  String? companyError;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submitForm() {
    print('Submitting product form');
    // Validation
    String? nError;
    String? pError;
    String? cError;
    if (_nameController.text.trim().isEmpty) {
      nError = 'Product name is required';
    }
    double? price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      pError = 'Please enter a valid price greater than 0';
    }
    if (selectedCompanyId == null) {
      cError = 'Please select a company';
    }
    if (nError != null || pError != null || cError != null) {
      print(
        'Validation failed: nameError=$nError, priceError=$pError, companyError=$cError',
      );
      setState(() {
        nameError = nError;
        priceError = pError;
        companyError = cError;
      });
      return;
    }
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text,
      stock: 0,
      price: price!,
      companyId: selectedCompanyId,
    );
    print('Adding product: ${product.toJson()}');
    controller
        .addProduct(product)
        .then((_) {
          print('Product added successfully');
          Navigator.of(context).pop();
          _showSuccessDialog(context, 'Product has been added successfully.');
        })
        .catchError((e) {
          print('Error adding product: $e');
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
                  'Add Product',
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
              'Product Name',
              Icons.inventory,
              _nameController,
              'Enter product name',
              errorText: nameError,
            ),
            SizedBox(height: 16),
            _buildFormField(
              'Price',
              Icons.attach_money,
              _priceController,
              '0.00',
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              errorText: priceError,
              prefixText: 'PKR ',
            ),
            SizedBox(height: 16),
            _buildCompanyDropdown(errorText: companyError),
            SizedBox(height: 24),
            _buildPremiumButton(
              'Add Product',
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
    String? prefixText,
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
            prefixText: prefixText,
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

  Widget _buildCompanyDropdown({String? errorText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Company *',
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Obx(() {
          return DropdownButtonFormField<int?>(
            value: selectedCompanyId,
            hint: Text('Select Company'),
            items: companyController.companies
                .where((company) => company.isActive)
                .map((company) {
                  return DropdownMenuItem<int?>(
                    value: company.id,
                    child: Text(company.name),
                  );
                })
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedCompanyId = value;
              });
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.business, color: AppColors.primary),
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
