import '../../company/models/company_model.dart';
import 'package:tryledger/utils/database_helper.dart';

class CompanyService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Company>> getCompanies() async {
    return await _dbHelper.getCompanies();
  }

  Future<void> addCompany(Company company) async {
    await _dbHelper.insertCompany(company);
  }

  Future<void> updateCompany(Company company) async {
    await _dbHelper.updateCompany(company);
  }

  Future<void> deleteCompany(int id) async {
    await _dbHelper.deleteCompany(id);
  }
}
