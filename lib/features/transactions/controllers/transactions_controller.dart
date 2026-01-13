import 'package:get/get.dart';
import '../models/transaction_model.dart';
import '../services/transactions_service.dart';

class TransactionsController extends GetxController {
  final TransactionsService _service = TransactionsService();

  var transactions = <Transaction>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  void loadTransactions() async {
    transactions.value = await _service.getTransactions();
  }

  void addTransaction(Transaction transaction) async {
    await _service.addTransaction(transaction);
    loadTransactions();
  }
}
