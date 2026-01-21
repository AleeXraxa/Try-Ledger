import '../models/dr_ledger_entry_model.dart';
import 'package:tryledger/utils/database_helper.dart';

class DrLedgerService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<DrLedgerEntry>> getDrLedgerEntries() async {
    return await _dbHelper.getDrLedgerEntries();
  }

  Future<void> addDrLedgerEntry(DrLedgerEntry entry) async {
    await _dbHelper.insertDrLedgerEntry(entry);
  }

  Future<void> updateDrLedgerEntry(DrLedgerEntry entry) async {
    await _dbHelper.updateDrLedgerEntry(entry);
  }

  Future<void> deleteDrLedgerEntry(int id) async {
    await _dbHelper.deleteDrLedgerEntry(id);
  }
}
