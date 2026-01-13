import '../models/dashboard_model.dart';

class DashboardService {
  // Dummy service for SQLite operations
  Future<DashboardModel> getDashboardData() async {
    // Simulate database query
    await Future.delayed(Duration(seconds: 1));
    return DashboardModel(totalStock: 100, totalSales: 5000.0, profit: 1200.0);
  }

  // Other CRUD methods can be added here
}
