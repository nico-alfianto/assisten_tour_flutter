import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../helpers/boarding_helper.dart';

class BoardingPassSheet extends StatelessWidget {
  final Booking booking;

  const BoardingPassSheet({super.key, required this.booking});

  String _getDepartureLocation() {
    if (booking.pickupAddress.isNotEmpty) {
      final parts = booking.pickupAddress.split(',');
      return parts[0].trim();
    }
    return 'Jakarta';
  }

  String _getDepartureCode() {
    if (booking.pickupAddress.isNotEmpty) return 'JKT';
    return 'CGK';
  }

  String _getDestinationCode() {
    final name = booking.destination.name;
    if (name == 'Pantai Kuta') return 'DPS';
    if (name == 'Gunung Bromo') return 'MLG';
    if (name == 'Labuan Bajo') return 'LBJ';
    if (name == 'Raja Ampat') return 'RJA';
    if (name == 'Danau Toba') return 'TOB';
    if (name == 'Candi Borobudur') return 'BOR';
    if (name == 'Nusa Penida') return 'NPD';
    if (name == 'Tana Toraja') return 'TRJ';
    return 'DST';
  }

  @override
  Widget build(BuildContext context) {
    final displaySeat = booking.seatNumber.isNotEmpty
        ? booking.seatNumber
        : generateSeatNumber(booking.transportName);
    final displayTicket = booking.ticketNumber.isNotEmpty
        ? booking.ticketNumber
        : generateTicketNumber();
    final displayBoarding = booking.boardingTime.isNotEmpty
        ? booking.boardingTime
        : calculateBoardingTime(booking.schedule);
    final displayArrival = booking.arrivalTime.isNotEmpty
        ? booking.arrivalTime
        : calculateArrivalTime(booking.transportType, booking.schedule);
    final departureLoc = _getDepartureLocation();
    final departureCode = _getDepartureCode();
    final destCode = _getDestinationCode();
    final transportIcon = getTransportIcon(
      booking.transportName,
      booking.transportType,
    );
    final transportLabel = getTransportTypeLabel(
      booking.transportType,
      booking.transportName,
    );
    final isUsingTransport = booking.transportType != 'Datang Sendiri';
    final isConfirmed = booking.status == 'Lunas';

    final qrSize = MediaQuery.of(context).size.width * 0.3;
    final qrMaxSize = 120.0;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Gradient Section
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.airplane_ticket,
                                color: Colors.white,
                                size: 22,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "ASSISTENT TOUR",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              booking.id,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "KEBERANGKATAN",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  departureCode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  departureLoc,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Icon(
                                transportIcon,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                booking.transportName.isNotEmpty
                                    ? booking.transportName
                                    : 'Mandiri',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  "DESTINASI",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  destCode,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  booking.destination.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              'PASSENGER',
                              booking.fullName,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField('SEAT', displaySeat),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField(
                              'TRANSPORT',
                              booking.transportName.isNotEmpty
                                  ? booking.transportName
                                  : 'Datang Sendiri',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField('TYPE', transportLabel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildField('TICKET NO', displayTicket),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildField(
                              'PARTICIPANTS',
                              '${booking.pax} Person',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dashed Cut Line
                _buildDashedLine(),
                const SizedBox(height: 16),

                // Pickup Information
                if (booking.pickupAddress.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PICKUP LOCATION',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFF0F766E),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                booking.pickupAddress,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDashedLine(),
                  const SizedBox(height: 16),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PICKUP',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(
                              Icons.directions_walk,
                              size: 16,
                              color: Color(0xFF0F766E),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Datang Mandiri',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDashedLine(),
                  const SizedBox(height: 16),
                ],

                // Times Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          'BOARDING',
                          displayBoarding,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(
                        child: _buildField(
                          'DEPARTURE',
                          booking.schedule.replaceAll(' ', '.'),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.grey.shade200,
                      ),
                      Expanded(
                        child: _buildField('ARRIVAL', displayArrival),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashedLine(),
                const SizedBox(height: 16),

                // Status Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'STATUS',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isConfirmed
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isConfirmed
                                ? Colors.green.shade200
                                : Colors.orange.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isConfirmed
                                  ? Icons.check_circle
                                  : Icons.access_time,
                              size: 14,
                              color:
                                  isConfirmed ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConfirmed ? 'CONFIRMED' : 'PENDING',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color:
                                    isConfirmed ? Colors.green : Colors.orange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashedLine(),
                const SizedBox(height: 16),

                // Two QR Codes Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQrCode(
                          qrData: generateBoardingQrData(booking),
                          label: isUsingTransport
                              ? 'SCAN SAAT BOARDING'
                              : 'SELF CHECK-IN',
                          icon: Icons.qr_code,
                          size: qrSize > qrMaxSize ? qrMaxSize : qrSize,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQrCode(
                          qrData: generateEntryQrData(booking),
                          label: 'SCAN SAAT\nMASUK DESTINASI',
                          icon: Icons.qr_code_2,
                          size: qrSize > qrMaxSize ? qrMaxSize : qrSize,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),
          IconButton(
            icon: const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white,
              child: Icon(Icons.close, color: Colors.black87, size: 24),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Row(
      children: [
        Container(
          width: 15,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Flex(
                direction: Axis.horizontal,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: List.generate(
                  (constraints.constrainWidth() / 10).floor(),
                  (index) => SizedBox(
                    width: 5,
                    height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          width: 15,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrCode({
    required String qrData,
    required String label,
    required IconData icon,
    required double size,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Image.network(
            'https://api.qrserver.com/v1/create-qr-code/?size=${size.toInt()}x${size.toInt()}&data=$qrData',
            width: size,
            height: size,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: size,
                height: size,
                color: Colors.grey.shade100,
                child: Icon(icon, size: size * 0.6, color: Colors.black87),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: size,
                height: size,
                color: Colors.grey.shade100,
                child: Icon(icon, size: size * 0.6, color: Colors.black87),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 0.5,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
