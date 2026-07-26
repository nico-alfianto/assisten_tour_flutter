import 'package:flutter/material.dart';
import '../data/tour_store.dart';
import '../models/booking.dart';
import '../widgets/boarding_pass_sheet.dart';
import 'main_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final TourStore _store = TourStore();

  int _calculateDaysLeft(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    return difference < 0 ? 0 : difference;
  }

  void _showBoardingPass(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 20),
          color: Colors.transparent,
          child: BoardingPassSheet(booking: booking),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final activeBookings = _store.bookingsList;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Jadwal Pemberangkatan",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            backgroundColor: const Color(0xFF0F766E),
            centerTitle: true,
          ),
          body: Container(
            color: Colors.grey.shade50,
            child: activeBookings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 70, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            "Belum ada jadwal perjalanan",
                            style: TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Tiket perjalanan aktif Anda akan tampil di sini setelah Anda melakukan booking destinasi.",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activeBookings.length,
                    itemBuilder: (context, index) {
                      final booking = activeBookings[index];
                      final isPaid = booking.status == 'Lunas';
                      final daysLeft = _calculateDaysLeft(booking.date);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Highlight Line (Teal if paid, Orange if pending)
                                Container(
                                  width: 6,
                                  color: isPaid ? const Color(0xFF0F766E) : Colors.orange,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header: Booking ID & status badge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              booking.id,
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (isPaid)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  "$daysLeft hari lagi",
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.orange.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  "Belum Lunas",
                                                  style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),

                                        // Body Info: Destination name & Time
                                        Text(
                                          booking.destination.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today, color: Colors.grey, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${booking.date.day}/${booking.date.month}/${booking.date.year}",
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                            const SizedBox(width: 14),
                                            const Icon(Icons.access_time, color: Colors.grey, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              booking.schedule,
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // Passenger information
                                        Row(
                                          children: [
                                            const Icon(Icons.people, color: Colors.grey, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${booking.pax} pax - a.n ${booking.fullName}",
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const Divider(height: 24),

                                        // Footer Action: Boarding pass button or Pay button
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            if (isPaid)
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(0xFF0F766E),
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
                                                onPressed: () => _showBoardingPass(booking),
                                                icon: const Icon(Icons.airplane_ticket_outlined, size: 16),
                                                label: const Text(
                                                  "Boarding Pass",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                              )
                                            else
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.orange,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  elevation: 0,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                ),
                                                onPressed: () {
                                                  // Switch tab to Payment tab (index 3) programmatically
                                                  Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => const MainPage(initialIndex: 3),
                                                    ),
                                                    (route) => false,
                                                  );
                                                },
                                                icon: const Icon(Icons.payment, size: 16),
                                                label: const Text(
                                                  "Bayar Sekarang",
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
