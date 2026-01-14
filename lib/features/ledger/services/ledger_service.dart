import '../models/ledger_entry_model.dart';
import 'package:tryledger/utils/database_helper.dart';

class LedgerService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<LedgerEntry>> getLedgerEntries() async {
    return await _dbHelper.getLedgerEntries();
  }

  Future<void> addLedgerEntry(LedgerEntry entry) async {
    await _dbHelper.insertLedgerEntry(entry);
  }

  Future<void> updateLedgerEntry(LedgerEntry entry) async {
    await _dbHelper.updateLedgerEntry(entry);
  }

  Future<void> deleteLedgerEntry(int id) async {
    await _dbHelper.deleteLedgerEntry(id);
  }
}
