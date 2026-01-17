import 'package:get/get.dart';
import '../models/ledger_entry_model.dart';
import '../services/ledger_service.dart';
import '../../company/controllers/company_controller.dart';

class LedgerController extends GetxController {
  final LedgerService _service = LedgerService();

  var ledgerEntries = <LedgerEntry>[].obs;
  var filteredEntries = <LedgerEntry>[].obs;
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();
  var isFiltered = false.obs;
  var selectedCompanyId = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadLedger();
  }

  void loadLedger() async {
    ledgerEntries.value = (await _service.getLedgerEntries())
      ..sort((a, b) => a.date.compareTo(b.date));
    applyFilters();
  }

  void selectCompany(int? companyId) {
    selectedCompanyId.value = companyId;
    applyFilters();
  }

  void applyFilters() {
    List<LedgerEntry> entries = ledgerEntries;

    // Filter by company
    if (selectedCompanyId.value != null) {
      entries = entries
          .where((entry) => entry.companyId == selectedCompanyId.value)
          .toList();
    }

    // Apply date filter
    if (fromDate.value == null && toDate.value == null) {
      filteredEntries.value = entries;
      isFiltered.value = false;
      return;
    }

    filteredEntries.value = entries.where((entry) {
      bool matchesFromDate =
          fromDate.value == null ||
          entry.date.isAtSameMomentAs(fromDate.value!) ||
          entry.date.isAfter(fromDate.value!);

      bool matchesToDate =
          toDate.value == null ||
          entry.date.isAtSameMomentAs(toDate.value!) ||
          entry.date.isBefore(
            toDate.value!.add(Duration(days: 1)),
          ); // Include the end date

      return matchesFromDate && matchesToDate;
    }).toList();

    isFiltered.value = true;
  }

  Future<void> addLedgerEntry(LedgerEntry entry) async {
    await _service.addLedgerEntry(entry);
    ledgerEntries.add(entry);
  }

  Future<void> updateLedgerEntry(LedgerEntry entry) async {
    await _service.updateLedgerEntry(entry);
    int index = ledgerEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      ledgerEntries[index] = entry;
    }
  }

  Future<void> deleteLedgerEntry(int id) async {
    await _service.deleteLedgerEntry(id);
    ledgerEntries.removeWhere((e) => e.id == id);
    // Also remove from filtered entries if it exists there
    filteredEntries.removeWhere((e) => e.id == id);
  }

  void applyDateFilter() {
    applyFilters();
  }

  void clearFilter() {
    fromDate.value = null;
    toDate.value = null;
    applyFilters();
  }
}
