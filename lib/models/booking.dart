import 'destination.dart';

class Booking {
  final String id;
  final Destination destination;
  final DateTime date;
  final String schedule;
  final String fullName;
  final String phoneNumber;
  final int pax;
  final int totalPrice;
  String status;
  final String pickupAddress;
  final String transportType;
  final String transportName;
  final int transportPrice;
  final String seatNumber;
  final String ticketNumber;
  final String boardingTime;
  final String arrivalTime;

  Booking({
    required this.id,
    required this.destination,
    required this.date,
    required this.schedule,
    required this.fullName,
    required this.phoneNumber,
    required this.pax,
    required this.totalPrice,
    this.status = 'Pending',
    this.pickupAddress = '',
    this.transportType = 'Datang Sendiri',
    this.transportName = '',
    this.transportPrice = 0,
    this.seatNumber = '',
    this.ticketNumber = '',
    this.boardingTime = '',
    this.arrivalTime = '',
  });
}
