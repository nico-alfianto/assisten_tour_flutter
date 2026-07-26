import 'dart:math';
import 'package:flutter/material.dart';
import '../models/booking.dart';

IconData getTransportIcon(String transportName, String transportType) {
  if (transportType == 'Datang Sendiri') return Icons.directions_walk;
  switch (transportName) {
    case 'Bus Pariwisata':
      return Icons.directions_bus;
    case 'Travel':
      return Icons.airport_shuttle;
    case 'Kereta Api':
      return Icons.train;
    case 'Garuda Indonesia':
    case 'Citilink':
    case 'Lion Air':
      return Icons.flight;
    case 'Kapal Ferry':
      return Icons.directions_boat;
    case 'Kapal Cepat':
      return Icons.sailing;
    default:
      return Icons.directions_walk;
  }
}

String getTransportTypeLabel(String transportType, String transportName) {
  if (transportType == 'Datang Sendiri') return 'Mandiri';
  switch (transportType) {
    case 'Jalur Darat':
      return 'Darat';
    case 'Jalur Udara':
      return 'Udara';
    case 'Jalur Laut':
      return 'Laut';
    default:
      return '-';
  }
}

String generateSeatNumber(String transportName) {
  final random = Random();
  switch (transportName) {
    case 'Bus Pariwisata':
      return 'A${(random.nextInt(30) + 1).toString().padLeft(2, '0')}';
    case 'Travel':
      return 'B${(random.nextInt(20) + 1).toString().padLeft(2, '0')}';
    case 'Kereta Api':
      return 'C${(random.nextInt(40) + 1).toString().padLeft(2, '0')}';
    case 'Garuda Indonesia':
      return '${random.nextInt(50) + 1}A';
    case 'Citilink':
      return '${random.nextInt(50) + 1}B';
    case 'Lion Air':
      return '${random.nextInt(50) + 1}C';
    case 'Kapal Ferry':
      return 'D${(random.nextInt(30) + 1).toString().padLeft(2, '0')}';
    case 'Kapal Cepat':
      return 'E${(random.nextInt(20) + 1).toString().padLeft(2, '0')}';
    default:
      return '-';
  }
}

String generateTicketNumber() {
  final now = DateTime.now();
  final millis = now.millisecondsSinceEpoch;
  final seq = millis.toString().substring(millis.toString().length - 6);
  return 'AT-${now.year}-$seq';
}

String calculateBoardingTime(String schedule) {
  try {
    final parts = schedule.split(' ');
    final time = parts[0].split(':');
    int hour = int.parse(time[0]);
    int minute = int.parse(time[1]);
    minute -= 30;
    if (minute < 0) {
      minute += 60;
      hour -= 1;
    }
    return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '-';
  }
}

String calculateArrivalTime(String transportType, String schedule) {
  try {
    final parts = schedule.split(' ');
    final time = parts[0].split(':');
    int hour = int.parse(time[0]);
    int minute = int.parse(time[1]);
    int addHours;
    switch (transportType) {
      case 'Jalur Darat':
        addHours = 4;
        break;
      case 'Jalur Udara':
        addHours = 2;
        break;
      case 'Jalur Laut':
        addHours = 6;
        break;
      default:
        addHours = 3;
    }
    hour += addHours;
    return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '-';
  }
}

String generateBoardingQrData(Booking booking) {
  return 'BP|${booking.id}|${booking.fullName}|${booking.transportName}|${booking.seatNumber}|${booking.destination.name}|${booking.date.toIso8601String()}';
}

String generateEntryQrData(Booking booking) {
  return 'ET|${booking.id}|${booking.destination.name}|${booking.pax}|${booking.date.toIso8601String()}';
}
