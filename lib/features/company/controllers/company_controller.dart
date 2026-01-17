import 'package:get/get.dart';
import '../models/company_model.dart';
import '../services/company_service.dart';

class CompanyController extends GetxController {
  final CompanyService _service = CompanyService();

  var companies = <Company>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCompanies();
  }

  void loadCompanies() async {
    companies.value = await _service.getCompanies();
  }

  Future<void> addCompany(Company company) async {
    await _service.addCompany(company);
    companies.add(company);
  }

  Future<void> updateCompany(Company company) async {
    await _service.updateCompany(company);
    int index = companies.indexWhere((c) => c.id == company.id);
    if (index != -1) {
      companies[index] = company;
    }
  }

  Future<void> deleteCompany(int id) async {
    await _service.deleteCompany(id);
    companies.removeWhere((c) => c.id == id);
  }
}
