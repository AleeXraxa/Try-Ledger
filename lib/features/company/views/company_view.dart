import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/screen_utils.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/saas_table.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../controllers/company_controller.dart';
import '../models/company_model.dart';

class CompanyView extends StatelessWidget {
  final CompanyController controller = Get.put(CompanyController());

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
                      'Company Information',
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    _buildPremiumButton(
                      'Add Company',
                      Icons.add,
                      AppColors.primary,
                      () {
                        _showAddCompanyDialog(context);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Manage company details',
                  style: AppStyles.bodyStyle.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Obx(() {
              if (controller.companies.isEmpty) {
                return _buildEmptyState(context);
              }
              return SaaSTable(
                title: '',
                subtitle: null,
                columns: ['Name', 'Type', 'Phone'],
                columnTypes: ['text', 'text', 'text'],
                rows: controller.companies.map((company) {
                  return {
                    'Name': company.name,
                    'Type': company.type,
                    'Phone': company.phone,
                  };
                }).toList(),
                onAddPressed: () {
                  // Add company
                },
                onFilterPressed: () {
                  // Filter
                },
                onExportPressed: () {
                  // Export
                },
                onRowTap: (index) {
                  if (index >= 0 && index < controller.companies.length) {
                    _showCompanyDetailsDialog(
                      context,
                      controller.companies[index],
                    );
                  }
                },
                onActionPressed: (index, action) {
                  if (action == 'edit') {
                    if (index >= 0 && index < controller.companies.length) {
                      _showAddCompanyDialog(
                        context,
                        controller.companies[index],
                      );
                    }
                  } else if (action == 'delete') {
                    if (index >= 0 && index < controller.companies.length) {
                      _showDeleteConfirmation(
                        context,
                        controller.companies[index].id,
                      );
                    }
                  }
                },
                isLoading: false,
              );
            }),
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

  Widget _buildCompanyCard(BuildContext context, Company company) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.background, AppColors.background.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  company.name,
                  style: AppStyles.headingStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showAddCompanyDialog(context, company);
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(context, company.id);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildDetailRow('Type', company.type),
          SizedBox(height: 8),
          _buildDetailRow('Address', company.address),
          SizedBox(height: 8),
          _buildDetailRow('Phone', company.phone),
          SizedBox(height: 8),
          _buildDetailRow('Email', company.email),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppStyles.bodyStyle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        Expanded(child: Text(value, style: AppStyles.bodyStyle)),
      ],
    );
  }

  void _showCompanyDetailsDialog(BuildContext context, Company company) {
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
                    'Company Details',
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
              _buildDetailRow('Name', company.name),
              SizedBox(height: 16),
              _buildDetailRow('Type', company.type),
              SizedBox(height: 16),
              _buildDetailRow('Address', company.address),
              SizedBox(height: 16),
              _buildDetailRow('Phone', company.phone),
              SizedBox(height: 16),
              _buildDetailRow('Email', company.email),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildPremiumButton(
                      'Edit',
                      Icons.edit,
                      AppColors.accent,
                      () {
                        Navigator.of(context).pop();
                        _showAddCompanyDialog(context, company);
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
                        _showDeleteConfirmation(context, company.id);
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

  void _showAddCompanyDialog(BuildContext context, [Company? company]) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController typeController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    String? nameError;

    if (company != null) {
      nameController.text = company.name;
      typeController.text = company.type;
      addressController.text = company.address;
      phoneController.text = company.phone;
      emailController.text = company.email;
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
                        company == null ? 'Add Company' : 'Edit Company',
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
                    'Company Name',
                    Icons.business,
                    nameController,
                    'Enter company name',
                    errorText: nameError,
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    'Company Type',
                    Icons.category,
                    typeController,
                    'Enter company type',
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    'Company Address',
                    Icons.location_on,
                    addressController,
                    'Enter company address',
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    'Company Email',
                    Icons.email,
                    emailController,
                    'Enter company email',
                  ),
                  SizedBox(height: 16),
                  _buildFormField(
                    'Company Phone',
                    Icons.phone,
                    phoneController,
                    'Enter company phone',
                  ),
                  SizedBox(height: 24),
                  _buildPremiumButton(
                    company == null ? 'Add Company' : 'Update Company',
                    Icons.save,
                    AppColors.primary,
                    () async {
                      // Validation
                      String? nError;
                      if (nameController.text.trim().isEmpty) {
                        nError = 'Company Name is required';
                      }
                      if (nError != null) {
                        setState(() {
                          nameError = nError;
                        });
                        return;
                      }
                      // Add company logic
                      final newCompany = Company(
                        id:
                            company?.id ??
                            DateTime.now().millisecondsSinceEpoch,
                        name: nameController.text,
                        type: typeController.text,
                        address: addressController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                      );
                      if (company == null) {
                        await controller.addCompany(newCompany);
                      } else {
                        await controller.updateCompany(newCompany);
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

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text('Delete Company', style: AppStyles.headingStyle),
        content: Text(
          'Are you sure you want to delete this company?',
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
              await controller.deleteCompany(id);
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

  Widget _buildEmptyState(BuildContext context) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business,
              size: 64,
              color: AppColors.primary.withOpacity(0.6),
            ),
            SizedBox(height: 16),
            Text(
              'No Companies Yet',
              style: AppStyles.headingStyle.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add your first company using the button above.',
              style: AppStyles.bodyStyle.copyWith(
                color: AppColors.neutral,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
