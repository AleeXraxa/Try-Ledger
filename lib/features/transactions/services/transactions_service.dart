import '../models/transaction_model.dart';

class TransactionsService {
  Future<List<Transaction>> getTransactions() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      Transaction(id: 1, type: 'sale', amount: 100.0, date: DateTime.now()),
      Transaction(
        id: 2,
        type: 'purchase',
        amount: 50.0,
        date: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  }

  Future<void> addTransaction(Transaction transaction) async {
    await Future.delayed(Duration(milliseconds: 500));
  }
}
