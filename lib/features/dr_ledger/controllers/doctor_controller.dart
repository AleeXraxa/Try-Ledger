import 'package:get/get.dart';
import '../models/doctor_model.dart';
import '../services/doctor_service.dart';

class DoctorController extends GetxController {
  final DoctorService _service = DoctorService();

  var doctors = <Doctor>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
  }

  void loadDoctors() async {
    doctors.value = await _service.getDoctors();
  }

  Future<void> addDoctor(Doctor doctor) async {
    await _service.addDoctor(doctor);
    doctors.add(doctor);
  }

  Future<void> updateDoctor(Doctor doctor) async {
    await _service.updateDoctor(doctor);
    int index = doctors.indexWhere((d) => d.id == doctor.id);
    if (index != -1) {
      doctors[index] = doctor;
    }
  }

  Future<void> deleteDoctor(int id) async {
    await _service.deleteDoctor(id);
    doctors.removeWhere((d) => d.id == id);
  }
}
