import '../../dr_ledger/models/doctor_model.dart';
import '../../../utils/database_helper.dart';

class DoctorService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Doctor>> getDoctors() async {
    return await _dbHelper.getDoctors();
  }

  Future<void> addDoctor(Doctor doctor) async {
    await _dbHelper.insertDoctor(doctor);
  }

  Future<void> updateDoctor(Doctor doctor) async {
    await _dbHelper.updateDoctor(doctor);
  }

  Future<void> deleteDoctor(int id) async {
    await _dbHelper.deleteDoctor(id);
  }
}
