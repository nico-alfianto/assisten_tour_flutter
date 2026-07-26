class Payment {
  final String id;
  final String bookingId;
  final String paymentMethod;
  final int amount;
  final DateTime paymentDate;
  final String status; // 'Pending' or 'Lunas'

  Payment({
    required this.id,
    required this.bookingId,
    required this.paymentMethod,
    required this.amount,
    required this.paymentDate,
    required this.status,
  });
}
