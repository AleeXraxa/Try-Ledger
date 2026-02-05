import 'dart:io';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../utils/helpers.dart';
import '../../../constants/app_styles.dart';
import '../controllers/ledger_controller.dart';
import '../../company/controllers/company_controller.dart';
import '../models/ledger_entry_model.dart';

class LedgerReportService {
  static Future<void> generateLedgerReport(
    DateTime fromDate,
    DateTime toDate,
    int companyId,
  ) async {
    final ledgerController = Get.find<LedgerController>();
    final companyController = Get.find<CompanyController>();

    // Get company name
    final company = companyController.companies.firstWhereOrNull(
      (c) => c.id == companyId,
    );
    final companyName = company?.name ?? 'Unknown Company';

    // Debug: Print all ledger entries
    print('All ledger entries: ${ledgerController.ledgerEntries.length}');

    // Normalize range to full days (ignore time-of-day in comparisons)
    final rangeStart = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final rangeEndExclusive =
        DateTime(toDate.year, toDate.month, toDate.day).add(Duration(days: 1));

    // Filter entries for the company and date range
    List<LedgerEntry> reportEntries = ledgerController.ledgerEntries.where((
      entry,
    ) {
      if (entry.companyId != companyId) {
        return false;
      }
      final localDate = entry.date.toLocal();
      final entryDate = DateTime(
        localDate.year,
        localDate.month,
        localDate.day,
      );
      return !entryDate.isBefore(rangeStart) &&
          entryDate.isBefore(rangeEndExclusive);
    }).toList();

    // Sort entries by date to keep pagination and balances stable
    reportEntries.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return a.id.compareTo(b.id);
    });

    print('Filtered report entries: ${reportEntries.length}');

    // Calculate opening balance for this company
    double openingBalance = ledgerController.ledgerEntries
        .where((e) => e.companyId == companyId)
        .where((e) => e.date.toLocal().isBefore(rangeStart))
        .fold<double>(0, (sum, e) => sum + e.debit - e.credit);
    print('Final opening balance: $openingBalance');

    // Calculate opening date for PDF
    String openingDate = formatDate(rangeStart.subtract(Duration(days: 1)));
    if (ledgerController.isFiltered.value &&
        ledgerController.fromDate.value != null) {
      openingDate = formatDate(
        ledgerController.fromDate.value!.subtract(Duration(days: 1)),
      );
    } else if (reportEntries.isNotEmpty) {
      openingDate = formatDate(
        reportEntries.first.date.subtract(Duration(days: 1)),
      );
    }

    // Create PDF
    final pdf = pw.Document();

    // Prepare output file early (needed for empty-report path too)
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ledger_report.pdf');

    pw.Widget buildHeader(pw.Context context) {
      return pw.Container(
        padding: pw.EdgeInsets.only(bottom: 8),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
          ),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Wintop Pharma',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                pw.Text(
                  'Company: $companyName',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Spacer(),
                pw.Text(
                  'Date: ${formatDate(fromDate)} to ${formatDate(toDate)}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    pw.Widget buildFooter(pw.Context context) {
      return pw.Container(
        padding: pw.EdgeInsets.only(top: 6),
        decoration: pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfColors.grey300, width: 1),
          ),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              'Generated on ${formatDate(DateTime.now())}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.Spacer(),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      );
    }

    // Generate PDF pages
    bool hasOpeningBalance = openingBalance != 0 || reportEntries.isNotEmpty;
    if (reportEntries.isEmpty && !hasOpeningBalance) {
      // Add at least one page with header if no entries exist
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                buildHeader(context),
                pw.SizedBox(height: 16),
                pw.Center(
                  child: pw.Text(
                    'No ledger entries found for the selected period',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red900,
                    ),
                  ),
                ),
                pw.Spacer(),
                buildFooter(context),
              ],
            );
          },
        ),
      );
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
      return;
    }
    final tableRows = <pw.TableRow>[];
    final cellStyle = pw.TextStyle(fontSize: 8);
    final headerStyle =
        pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);

    tableRows.add(
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey100),
        children: [
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Date', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Reference No', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Description', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Qty', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Rate', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Debit', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Credit', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('Balance', style: headerStyle),
          ),
        ],
      ),
    );

    double runningBalance = openingBalance;
    if (hasOpeningBalance) {
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(openingDate, style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('', style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                'Opening Balance',
                style: headerStyle,
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('', style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('', style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('', style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text('', style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                formatCurrency(runningBalance),
                style: cellStyle,
              ),
            ),
          ],
        ),
      );
    }

    for (final entry in reportEntries) {
      runningBalance += entry.debit - entry.credit;
      tableRows.add(
        pw.TableRow(
          children: [
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(formatDate(entry.date), style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(entry.referenceNo ?? '', style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(entry.description, style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child:
                  pw.Text(entry.qty != null ? entry.qty.toString() : '', style: cellStyle),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                entry.rate != null ? formatCurrency(entry.rate!) : '',
                style: cellStyle,
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                entry.debit > 0 ? formatCurrency(entry.debit) : '',
                style: cellStyle,
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(
                entry.credit > 0 ? formatCurrency(entry.credit) : '',
                style: cellStyle,
              ),
            ),
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              child: pw.Text(formatCurrency(runningBalance), style: cellStyle),
            ),
          ],
        ),
      );
    }

    tableRows.add(
      pw.TableRow(
        children: [
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('', style: cellStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('', style: cellStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('TOTALS', style: headerStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('', style: cellStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text('', style: cellStyle),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text(
              reportEntries.fold<double>(0, (sum, entry) => sum + entry.debit) >
                      0
                  ? formatCurrency(
                      reportEntries.fold<double>(
                        0,
                        (sum, entry) => sum + entry.debit,
                      ),
                    )
                  : '',
              style: cellStyle,
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text(
              reportEntries.fold<double>(0, (sum, entry) => sum + entry.credit) >
                      0
                  ? formatCurrency(
                      reportEntries.fold<double>(
                        0,
                        (sum, entry) => sum + entry.credit,
                      ),
                    )
                  : '',
              style: cellStyle,
            ),
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(6),
            child: pw.Text(
              'Closing Balance: ${formatCurrency(runningBalance)}',
              style: headerStyle,
            ),
          ),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        header: buildHeader,
        footer: buildFooter,
        build: (pw.Context context) {
          return [
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: pw.FlexColumnWidth(1.5), // Date
                1: pw.FlexColumnWidth(1.5), // Reference
                2: pw.FlexColumnWidth(3), // Description
                3: pw.FlexColumnWidth(1), // Qty
                4: pw.FlexColumnWidth(1.5), // Rate
                5: pw.FlexColumnWidth(1.5), // Debit
                6: pw.FlexColumnWidth(1.5), // Credit
                7: pw.FlexColumnWidth(2), // Balance
              },
              children: tableRows,
            ),
          ];
        },
      ),
    );

    // Save PDF
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    await OpenFile.open(file.path);
  }
}
