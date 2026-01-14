import '../models/transaction_model.dart';
import 'package:tryledger/utils/database_helper.dart';

class TransactionsService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Transaction>> getTransactions() async {
    return await _dbHelper.getTransactions();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _dbHelper.insertTransaction(transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
  }
}
