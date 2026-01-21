import 'package:get/get.dart';
import '../models/dr_ledger_entry_model.dart';
import '../services/dr_ledger_service.dart';

class DrLedgerController extends GetxController {
  final DrLedgerService _service = DrLedgerService();

  var drLedgerEntries = <DrLedgerEntry>[].obs;
  var filteredEntries = <DrLedgerEntry>[].obs;
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();
  var selectedDoctorId = Rxn<int>();
  var isFiltered = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDrLedger();
  }

  void loadDrLedger() async {
    drLedgerEntries.value = (await _service.getDrLedgerEntries())
      ..sort((a, b) => a.date.compareTo(b.date));
    filteredEntries.value = drLedgerEntries;
  }

  Future<void> addDrLedgerEntry(DrLedgerEntry entry) async {
    await _service.addDrLedgerEntry(entry);
    drLedgerEntries.add(entry);
    drLedgerEntries.sort((a, b) => a.date.compareTo(b.date));
    if (!isFiltered.value) {
      filteredEntries.value = drLedgerEntries;
    }
  }

  Future<void> updateDrLedgerEntry(DrLedgerEntry entry) async {
    await _service.updateDrLedgerEntry(entry);
    int index = drLedgerEntries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      drLedgerEntries[index] = entry;
      drLedgerEntries.sort((a, b) => a.date.compareTo(b.date));
      if (!isFiltered.value) {
        filteredEntries.value = drLedgerEntries;
      } else {
        // Re-apply filter
        applyDateFilter();
      }
    }
  }

  Future<void> deleteDrLedgerEntry(int id) async {
    await _service.deleteDrLedgerEntry(id);
    drLedgerEntries.removeWhere((e) => e.id == id);
    // Also remove from filtered entries if it exists there
    filteredEntries.removeWhere((e) => e.id == id);
    if (!isFiltered.value) {
      filteredEntries.value = drLedgerEntries;
    }
  }

  void applyDateFilter() {
    filteredEntries.value = drLedgerEntries.where((entry) {
      bool matchesDoctor =
          selectedDoctorId.value == null ||
          entry.doctorId == selectedDoctorId.value;

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

      return matchesDoctor && matchesFromDate && matchesToDate;
    }).toList();

    isFiltered.value =
        selectedDoctorId.value != null ||
        fromDate.value != null ||
        toDate.value != null;
  }

  void clearFilter() {
    fromDate.value = null;
    toDate.value = null;
    selectedDoctorId.value = null;
    filteredEntries.value = drLedgerEntries;
    isFiltered.value = false;
  }
}
