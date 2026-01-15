import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/helpers.dart';
import '../../../utils/database_helper.dart';
import '../controllers/inventory_controller.dart';
import '../models/product_model.dart';
import '../models/invoice_model.dart';

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('/', '');
    if (text.length > 8) text = text.substring(0, 8);
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 2 || i == 4) formatted += '/';
      formatted += text[i];
    }
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class PurchaseDialog extends StatefulWidget {
  @override
  _PurchaseDialogState createState() => _PurchaseDialogState();
}

class _PurchaseDialogState extends State<PurchaseDialog> {
  final InventoryController controller = Get.find<InventoryController>();

  final TextEditingController _invoiceRefController = TextEditingController();
  final TextEditingController _invoiceDateController = TextEditingController();
  Product? selectedProduct;
  final TextEditingController _batchController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _dpController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  List<Map<String, dynamic>> selectedItems = [];

  String? invoiceRefError;
  String? invoiceDateError;
  String? productError;
  String? qtyError;
  String? batchError;
  String? expiryError;
  String? dpError;

  double get total =>
      (double.tryParse(_dpController.text) ?? 0) *
      (double.tryParse(_qtyController.text) ?? 0);

  @override
  void dispose() {
    _invoiceRefController.dispose();
    _invoiceDateController.dispose();
    _batchController.dispose();
    _expiryDateController.dispose();
    _dpController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {}
    return null;
  }

  bool _isValidExpiry(DateTime date) {
    DateTime now = DateTime.now();
    DateTime oneMonthFromNow = now.add(Duration(days: 30));
    return date.isBefore(now) || date.isAfter(oneMonthFromNow);
  }

  void _addItem() {
    setState(() {
      productError = null;
      qtyError = null;
      dpError = null;
      expiryError = null;
    });

    // Validation
    if (selectedProduct == null) {
      setState(() => productError = 'Product is required');
      return;
    }
    int? qty = int.tryParse(_qtyController.text);
    if (qty == null || qty <= 0) {
      setState(() => qtyError = 'Quantity must be a positive number');
      return;
    }
    double? dp = double.tryParse(_dpController.text);
    if (dp == null || dp <= 0) {
      setState(() => dpError = 'DP must be a positive number');
      return;
    }
    // Optional validations
    String batch = _batchController.text.trim();
    DateTime? expiry;
    if (_expiryDateController.text.isNotEmpty) {
      expiry = _parseDate(_expiryDateController.text);
      if (expiry != null && !_isValidExpiry(expiry)) {
        setState(
          () => expiryError =
              'Expiry must be in the past or more than 30 days in the future',
        );
        return;
      }
    }
    // Check for duplicate
    bool isDuplicate = selectedItems.any(
      (item) =>
          item['name'] == selectedProduct!.name &&
          item['price'] == dp &&
          item['batch'] == batch &&
          item['expiry'] == expiry,
    );
    if (isDuplicate) {
      setState(
        () => productError =
            'This product with the same details is already added.',
      );
      return;
    }
    // Add to list
    setState(() {
      selectedItems.add({
        'name': selectedProduct!.name,
        'batch': batch,
        'expiry': expiry?.toIso8601String(),
        'qty': qty,
        'price': dp,
        'value': total,
      });
      // Clear fields
      selectedProduct = null;
      _batchController.clear();
      _expiryDateController.clear();
      _dpController.clear();
      _qtyController.clear();
      // Clear errors
      productError = null;
      qtyError = null;
      dpError = null;
      expiryError = null;
    });
  }

  Future<void> _submitPurchase() async {
    setState(() {
      invoiceRefError = null;
      invoiceDateError = null;
    });

    if (_invoiceRefController.text.isEmpty) {
      setState(() => invoiceRefError = 'Invoice Reference is required');
      return;
    }
    DateTime? invoiceDate = _parseDate(_invoiceDateController.text);
    if (invoiceDate == null) {
      setState(
        () => invoiceDateError = 'Invalid invoice date format (DD/MM/YYYY)',
      );
      return;
    }
    if (selectedItems.isEmpty) {
      // Show error, perhaps a snackbar or something, but for now return
      return;
    }
    // Calculate total
    double total = selectedItems.fold(
      0.0,
      (sum, item) => sum + (item['value'] as double),
    );
    // Create invoice
    Invoice invoice = Invoice(
      id: 0,
      reference: _invoiceRefController.text,
      date: invoiceDate,
      items: selectedItems,
      total: total,
    );
    // Save to database
    await DatabaseHelper().insertInvoice(invoice);
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Purchase invoice saved successfully!')),
    );
    Navigator.of(context).pop();
  }

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
                Text(
                  'Purchase Invoice',
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
                          child: _buildFormField(
                            'Invoice Reference',
                            Icons.receipt,
                            _invoiceRefController,
                            'Enter invoice reference',
                            errorText: invoiceRefError,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDateTextField(
                            'Invoice Date',
                            _invoiceDateController,
                            errorText: invoiceDateError,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product',
                                style: AppStyles.bodyStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8),
                              Obx(() {
                                return DropdownButtonFormField<Product>(
                                  value: selectedProduct,
                                  items: controller.products.map((product) {
                                    return DropdownMenuItem<Product>(
                                      value: product,
                                      child: Text(product.name),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectedProduct = value;
                                      if (value != null) {
                                        _dpController.text = value.price
                                            .toString();
                                      }
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Select Product',
                                    errorText: productError,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.neutral.withOpacity(
                                          0.2,
                                        ),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.neutral.withOpacity(
                                          0.2,
                                        ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: AppColors.background.withOpacity(
                                      0.5,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            'DP (PKR)',
                            Icons.attach_money,
                            _dpController,
                            '0.00',
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            errorText: dpError,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormField(
                            'Batch',
                            Icons.batch_prediction,
                            _batchController,
                            'Enter batch number',
                            errorText: batchError,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildDateTextField(
                            'Expiry',
                            _expiryDateController,
                            errorText: expiryError,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildFormField(
                            'Qty',
                            Icons.numbers,
                            _qtyController,
                            '0',
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            errorText: qtyError,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    _buildPremiumButton(
                      'Add Item',
                      Icons.add,
                      AppColors.primary,
                      _addItem,
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Items',
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
            SizedBox(height: 24),
            _buildPremiumButton(
              'Submit Purchase',
              Icons.check,
              AppColors.primary,
              _submitPurchase,
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
    Function(String)? onChanged,
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

  Widget _buildDateTextField(
    String label,
    TextEditingController controller, {
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
          keyboardType: TextInputType.number,
          inputFormatters: [DateInputFormatter()],
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
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

  Widget _buildItemsTable() {
    if (selectedItems.isEmpty) {
      return Center(
        child: Text('No items added yet.', style: AppStyles.bodyStyle),
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
                  DataColumn(
                    label: Text(
                      'Actions',
                      style: AppStyles.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                rows: selectedItems.asMap().entries.map((entry) {
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
                                  Icons.edit_outlined,
                                  color: AppColors.primary,
                                ),
                                onPressed: () => _editItem(index),
                                tooltip: 'Edit',
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
                                onPressed: () => _deleteItem(index),
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

  void _editItem(int index) {
    var item = selectedItems[index];
    setState(() {
      selectedProduct = controller.products.firstWhere(
        (p) => p.name == item['name'],
      );
      _batchController.text = item['batch'];
      _expiryDateController.text = item['expiry'] != null
          ? formatDate(DateTime.parse(item['expiry']))
          : '';
      _dpController.text = item['price'].toString();
      _qtyController.text = item['qty'].toString();
      selectedItems.removeAt(index);
    });
  }

  void _deleteItem(int index) {
    setState(() {
      selectedItems.removeAt(index);
    });
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
}
