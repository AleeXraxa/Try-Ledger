import '../../ledger/models/ledger_entry_model.dart';
import 'package:tryledger/utils/database_helper.dart';

class DrLedgerService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<LedgerEntry>> getDrLedgerEntries() async {
    List<LedgerEntry> allEntries = await _dbHelper.getLedgerEntries();
    // Filter for debit entries (debit > 0)
    return allEntries.where((entry) => entry.debit > 0).toList();
  }

  Future<void> addDrLedgerEntry(LedgerEntry entry) async {
    await _dbHelper.insertLedgerEntry(entry);
  }

  Future<void> updateDrLedgerEntry(LedgerEntry entry) async {
    await _dbHelper.updateLedgerEntry(entry);
  }

  Future<void> deleteDrLedgerEntry(int id) async {
    await _dbHelper.deleteLedgerEntry(id);
  }
}
