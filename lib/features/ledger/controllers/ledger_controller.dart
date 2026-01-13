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
}
