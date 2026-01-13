// Helper functions for the app

String formatCurrency(double amount) {
  return 'Rs. ${amount.toStringAsFixed(2)}';
}

String formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}

// Other utility functions
