import 'dart:io';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../../../utils/helpers.dart';
import '../../../constants/app_colors.dart';
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
    ledgerController.ledgerEntries.forEach((entry) {
      print(
        'Entry: ${entry.id}, companyId: ${entry.companyId}, date: ${entry.date}, description: ${entry.description}',
      );
    });

    // Filter entries for the company and date range
    List<LedgerEntry> reportEntries = ledgerController.ledgerEntries.where((
      entry,
    ) {
      bool matchesCompany = entry.companyId == companyId;
      bool matchesDate =
          entry.date.isAtSameMomentAs(fromDate) ||
          entry.date.isAfter(fromDate) &&
              entry.date.isBefore(toDate.add(Duration(days: 1)));
      print(
        'Entry ${entry.id}: matchesCompany=$matchesCompany, matchesDate=$matchesDate, date=${entry.date}, fromDate=$fromDate, toDate=$toDate',
      );
      return matchesCompany && matchesDate;
    }).toList();

    print('Filtered report entries: ${reportEntries.length}');
    reportEntries.forEach((entry) {
      print('Report entry: ${entry.id}, ${entry.description}');
    });

    // Calculate opening balance for this company
    double openingBalance = 0.0;
    for (var entry in ledgerController.ledgerEntries.where(
      (e) => e.companyId == companyId,
    )) {
      if (entry.date.isBefore(fromDate)) {
        openingBalance += entry.debit - entry.credit;
        print(
          'Adding to opening balance: ${entry.debit - entry.credit}, new balance: $openingBalance',
        );
      } else {
        break;
      }
    }
    print('Final opening balance: $openingBalance');

    // Calculate opening date for PDF
    String openingDate = '';
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

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'Wintop Pharma',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text(
                  'Ledger',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),
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
                    'Period: From ${formatDate(fromDate)} To ${formatDate(toDate)}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
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
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Date',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Reference No',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Rate',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Debit',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Credit',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Balance',
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (openingBalance != 0 || reportEntries.isNotEmpty)
                    pw.TableRow(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            openingDate,
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            'Opening Balance',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            formatCurrency(openingBalance),
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    ),
                  ...reportEntries.map((entry) {
                    openingBalance += entry.debit - entry.credit;
                    print(
                      'Adding entry to table: ${entry.description}, balance: $openingBalance',
                    );
                    return pw.TableRow(
                      children: [
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            formatDate(entry.date),
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            entry.referenceNo ?? '',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            entry.description,
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            entry.qty != null ? entry.qty.toString() : '',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            entry.rate != null
                                ? formatCurrency(entry.rate!)
                                : '',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            entry.debit > 0 ? formatCurrency(entry.debit) : '',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            entry.credit > 0
                                ? formatCurrency(entry.credit)
                                : '',
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            formatCurrency(openingBalance),
                            style: pw.TextStyle(fontSize: 8),
                          ),
                        ),
                      ],
                    );
                  }),
                  // Totals row
                  pw.TableRow(
                    children: [
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'TOTALS',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text('', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          reportEntries.fold<double>(
                                    0,
                                    (sum, entry) => sum + entry.debit,
                                  ) >
                                  0
                              ? formatCurrency(
                                  reportEntries.fold<double>(
                                    0,
                                    (sum, entry) => sum + entry.debit,
                                  ),
                                )
                              : '',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          reportEntries.fold<double>(
                                    0,
                                    (sum, entry) => sum + entry.credit,
                                  ) >
                                  0
                              ? formatCurrency(
                                  reportEntries.fold<double>(
                                    0,
                                    (sum, entry) => sum + entry.credit,
                                  ),
                                )
                              : '',
                          style: pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Closing Balance: ${formatCurrency(openingBalance)}',
                          style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  padding: pw.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Text(
                    'Generated on ${formatDate(DateTime.now())}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/ledger_report.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    await OpenFile.open(file.path);
  }
}
