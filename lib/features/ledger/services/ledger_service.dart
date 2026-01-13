import '../models/ledger_entry_model.dart';

class LedgerService {
  Future<List<LedgerEntry>> getLedgerEntries() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      LedgerEntry(
        id: 1,
        description: 'Sale',
        debit: 100.0,
        credit: 0.0,
        date: DateTime.now(),
      ),
      LedgerEntry(
        id: 2,
        description: 'Purchase',
        debit: 0.0,
        credit: 50.0,
        date: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }
}
