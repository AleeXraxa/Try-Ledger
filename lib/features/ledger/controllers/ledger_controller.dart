import 'package:get/get.dart';
import '../models/ledger_entry_model.dart';
import '../services/ledger_service.dart';

class LedgerController extends GetxController {
  final LedgerService _service = LedgerService();

  var ledgerEntries = <LedgerEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLedger();
  }

  void loadLedger() async {
    ledgerEntries.value = await _service.getLedgerEntries();
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
  }
}
