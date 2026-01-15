import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../../utils/screen_utils.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../utils/database_helper.dart';

class BackupView extends StatelessWidget {
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
                      'Backup & Restore',
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Secure your data with automated backups',
                  style: AppStyles.bodyStyle.copyWith(color: AppColors.neutral),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildBackupCard(
                        'Create Backup',
                        'Save your current data to a secure backup file',
                        Icons.backup,
                        AppColors.primary,
                        () async {
                          await _createBackup(context);
                        },
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildBackupCard(
                        'Restore Backup',
                        'Restore your data from a previous backup',
                        Icons.restore,
                        AppColors.accent,
                        () async {
                          await _restoreBackup(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.background.withOpacity(0.5),
                    AppColors.background.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
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
                        width: 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Backup History',
                        style: AppStyles.bodyStyle.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No backup history yet',
                            style: AppStyles.headingStyle.copyWith(
                              fontSize: 18,
                              color: AppColors.neutral,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Create your first backup to see history here',
                            style: AppStyles.bodyStyle.copyWith(
                              color: AppColors.neutral,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCard(
    String title,
    String description,
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
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHovered
                    ? [color.withOpacity(0.1), color.withOpacity(0.05)]
                    : [
                        AppColors.background.withOpacity(0.8),
                        AppColors.background.withOpacity(0.6),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHovered
                    ? color.withOpacity(0.3)
                    : AppColors.neutral.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.neutral.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: AppStyles.bodyStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: AppStyles.bodyStyle.copyWith(
                    color: AppColors.neutral,
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

  Future<void> _createBackup(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.background,
          content: Row(
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(width: 16),
              Text('Creating backup...', style: AppStyles.bodyStyle),
            ],
          ),
        ),
      );

      // Export all data
      final dbHelper = DatabaseHelper();
      final backupData = await dbHelper.exportAllData();

      // Hide loading dialog
      Navigator.of(context).pop();

      // Ask user for save location
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Backup File',
        fileName:
            'tryledger_backup_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (outputFile != null) {
        // Save the backup file
        final file = File(outputFile);
        await file.writeAsString(jsonEncode(backupData));

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup created successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      // Hide loading dialog if still showing
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _restoreBackup(BuildContext context) async {
    // Ask user to select backup file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      dialogTitle: 'Select Backup File to Restore',
    );

    if (result == null || result.files.isEmpty) {
      return; // User cancelled
    }

    String filePath = result.files.first.path!;
    File backupFile = File(filePath);

    // Read and parse backup file
    String backupContent;
    try {
      backupContent = await backupFile.readAsString();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to read backup file: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> backupData;
    try {
      backupData = jsonDecode(backupContent);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid backup file format'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate backup data structure
    if (!backupData.containsKey('data') ||
        !backupData['data'].containsKey('ledger_entries') ||
        !backupData['data'].containsKey('products') ||
        !backupData['data'].containsKey('invoices')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid backup file structure'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        title: Text(
          'Restore Backup',
          style: AppStyles.headingStyle.copyWith(fontSize: 20),
        ),
        content: Text(
          'This will replace all current data with the backup data. This action cannot be undone. Are you sure you want to continue?',
          style: AppStyles.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: AppStyles.bodyStyle.copyWith(
                color: AppColors.neutral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
            ),
            child: Text(
              'Restore',
              style: AppStyles.bodyStyle.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) {
      return; // User cancelled
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        content: Row(
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(width: 16),
            Text('Restoring backup...', style: AppStyles.bodyStyle),
          ],
        ),
      ),
    );

    try {
      // Import the backup data
      final dbHelper = DatabaseHelper();
      await dbHelper.importAllData(backupData);

      // Hide loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Backup restored successfully! Please restart the app to see changes.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      // Hide loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to restore backup: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
