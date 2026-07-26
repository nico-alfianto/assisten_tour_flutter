import 'dart:math';
import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/booking.dart';
import '../data/tour_store.dart';
import '../helpers/boarding_helper.dart';
import 'main_page.dart';

const Map<String, int> transportPrices = {
  "Bus Pariwisata": 250000,
  "Travel": 300000,
  "Kereta Api": 400000,
  "Garuda Indonesia": 1500000,
  "Citilink": 1200000,
  "Lion Air": 1000000,
  "Kapal Ferry": 350000,
  "Kapal Cepat": 500000,
};

const Map<String, List<String>> transportOptions = {
  "Jalur Darat": ["Bus Pariwisata", "Travel", "Kereta Api"],
  "Jalur Udara": ["Garuda Indonesia", "Citilink", "Lion Air"],
  "Jalur Laut": ["Kapal Ferry", "Kapal Cepat"],
};

const Map<String, String> transportDropdownLabels = {
  "Jalur Darat": "Pilih Kendaraan",
  "Jalur Udara": "Maskapai",
  "Jalur Laut": "Transportasi Laut",
};

class BookingPage extends StatefulWidget {
  final Destination? preselectedDestination;
  final String? preselectedSchedule;

  const BookingPage({
    super.key,
    this.preselectedDestination,
    this.preselectedSchedule,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final TourStore _store = TourStore();

  Destination? selectedDestination;
  String? selectedSchedule;
  DateTime? selectedDate;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  int paxCount = 1;
  int uniqueCode = 0;

  String _selectedTransportType = 'Datang Sendiri';
  String? _selectedTransportName;
  int _transportPrice = 0;

  @override
  void initState() {
    super.initState();
    // Set initial values if provided from details screen
    if (widget.preselectedDestination != null) {
      selectedDestination = _store.destinationsList.firstWhere(
        (d) => d.name == widget.preselectedDestination!.name,
        orElse: () => _store.destinationsList[0],
      );
    } else if (_store.destinationsList.isNotEmpty) {
      selectedDestination = _store.destinationsList[0];
    }

    if (widget.preselectedSchedule != null) {
      selectedSchedule = widget.preselectedSchedule;
    } else if (selectedDestination != null &&
        selectedDestination!.schedules.isNotEmpty) {
      selectedSchedule = selectedDestination!.schedules[0];
    }

    // Generate random unique code (100 - 999) for Indonesian bank transfer billing
    uniqueCode = Random().nextInt(899) + 100;

    // Prefill name and phone if user is logged in
    final currentUser = _store.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _phoneController.text = currentUser.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String _formatRupiah(int number) {
    String str = number.toString();
    String res = "";
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      res = str[i] + res;
      count++;
      if (count % 3 == 0 && i != 0) {
        res = ".$res";
      }
    }
    return "Rp $res";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0F766E), // header bg color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black87, // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _submitBooking() {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih tanggal pemberangkatan!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final isUsingTransport = _selectedTransportType != 'Datang Sendiri';
    if (isUsingTransport) {
      if (_addressController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Alamat penjemputan wajib diisi jika menggunakan transportasi!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_selectedTransportName == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Silakan pilih jenis transportasi!"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final ticketPrice = selectedDestination!.price;
    final totalTicketPrice = ticketPrice * paxCount;
    final totalTransportPrice = _transportPrice * paxCount;
    final finalPrice = totalTicketPrice + totalTransportPrice + uniqueCode;

    // Create booking object
    final newBooking = Booking(
      id: "BK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      destination: selectedDestination!,
      date: selectedDate!,
      schedule: selectedSchedule ?? "Default",
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      pax: paxCount,
      totalPrice: finalPrice,
      status: 'Pending',
      pickupAddress: _addressController.text.trim(),
      transportType: _selectedTransportType,
      transportName: _selectedTransportName ?? '',
      transportPrice: _transportPrice,
      seatNumber: generateSeatNumber(_selectedTransportName ?? ''),
      ticketNumber: generateTicketNumber(),
      boardingTime: calculateBoardingTime(selectedSchedule ?? ''),
      arrivalTime: calculateArrivalTime(
        _selectedTransportType,
        selectedSchedule ?? '',
      ),
    );

    // Save to store
    _store.addBooking(newBooking);

    // Success dialog with direct checkout options
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text(
                "Pemesanan Berhasil!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Tiket Anda untuk ke ${newBooking.destination.name} telah terdaftar. Silakan lakukan pembayaran untuk mengonfirmasi jadwal.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF0F766E)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        // Dismiss modal and pop to main menu
                        Navigator.pop(context); // close bottom sheet
                        // Check if we pushed from detail page
                        if (widget.preselectedDestination != null) {
                          Navigator.pop(
                            context,
                          ); // pop detail page back to Home
                        }
                        // Navigate to Schedule Tab via global state of main navigation
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainPage(
                              initialIndex: 2,
                            ), // index 2 is Schedule Tab
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Lihat Jadwal",
                        style: TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Dismiss modal and pop to payment menu
                        Navigator.pop(context); // close bottom sheet
                        if (widget.preselectedDestination != null) {
                          Navigator.pop(context); // pop detail page
                        }
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainPage(
                              initialIndex: 3,
                            ), // index 3 is Payment Tab
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Bayar Sekarang",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPreselected = widget.preselectedDestination != null;
    final isUsingTransport = _selectedTransportType != 'Datang Sendiri';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pemesanan Tiket",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F766E),
        centerTitle: true,
        leading: hasPreselected
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Destinasi Banner
                if (selectedDestination != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            selectedDestination!.image,
                            width: 90,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedDestination!.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.grey,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    selectedDestination!.location,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatRupiah(selectedDestination!.price),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F766E),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const Text(
                  "Detail Kontak & Pemesanan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 16),

                // Destinasi Selector Dropdown (Locked if Preselected)
                const Text(
                  "Pilih Destinasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Destination>(
                  initialValue: selectedDestination,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.map, color: Color(0xFF0F766E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F766E),
                        width: 2,
                      ),
                    ),
                  ),
                  items: hasPreselected
                      ? [
                          DropdownMenuItem(
                            value: selectedDestination,
                            child: Text(selectedDestination!.name),
                          ),
                        ]
                      : _store.destinationsList.map((dest) {
                          return DropdownMenuItem<Destination>(
                            value: dest,
                            child: Text(dest.name),
                          );
                        }).toList(),
                  onChanged: hasPreselected
                      ? null // Disable if preselected
                      : (Destination? newValue) {
                          setState(() {
                            selectedDestination = newValue;
                            if (selectedDestination != null &&
                                selectedDestination!.schedules.isNotEmpty) {
                              selectedSchedule =
                                  selectedDestination!.schedules[0];
                            }
                          });
                        },
                ),
                const SizedBox(height: 16),

                // Nama Lengkap
                const Text(
                  "Nama Lengkap Perwakilan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nama lengkap wajib diisi!";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Contoh: Budi Santoso",
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xFF0F766E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F766E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // No Handphone
                const Text(
                  "Nomor WhatsApp / Telepon",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Nomor HP wajib diisi!";
                    }
                    final trimmed = value.trim();
                    if (!RegExp(r"^\d{12}$").hasMatch(trimmed)) {
                      return "Nomor HP harus 12 digit";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Contoh: 081234567890",
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color(0xFF0F766E),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F766E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Alamat Penjemputan
                const Text(
                  "Alamat Penjemputan / Lokasi Awal",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Contoh: Jl. Sudirman No. 12, Jakarta",
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.location_on, color: Color(0xFF0F766E)),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(
                        color: Color(0xFF0F766E),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Transportasi Menuju Destinasi
                const Text(
                  "Transportasi Menuju Destinasi",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      _buildTransportOption(
                        'Datang Sendiri',
                        Icons.directions_walk,
                      ),
                      _buildTransportOption(
                        'Jalur Darat',
                        Icons.directions_bus,
                      ),
                      _buildTransportOption(
                        'Jalur Udara',
                        Icons.flight,
                      ),
                      _buildTransportOption(
                        'Jalur Laut',
                        Icons.directions_boat,
                      ),
                    ],
                  ),
                ),

                if (isUsingTransport) ...[
                  const SizedBox(height: 16),
                  const Text(
                    "Detail Transportasi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    transportDropdownLabels[_selectedTransportType]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedTransportName,
                    isExpanded: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        _selectedTransportType == 'Jalur Darat'
                            ? Icons.directions_bus
                            : _selectedTransportType == 'Jalur Udara'
                                ? Icons.flight
                                : Icons.directions_boat,
                        color: const Color(0xFF0F766E),
                      ),
                      hintText:
                          "Pilih ${transportDropdownLabels[_selectedTransportType]!.toLowerCase()}",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(
                          color: Color(0xFF0F766E),
                          width: 2,
                        ),
                      ),
                    ),
                    items: transportOptions[_selectedTransportType]!
                        .map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(
                          "$name - ${_formatRupiah(transportPrices[name]!)} / orang",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedTransportName = newValue;
                        _transportPrice = transportPrices[newValue] ?? 0;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 16),

                // Baris Tanggal & Jadwal
                Row(
                  children: [
                    // Tanggal Keberangkatan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Tanggal",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Color(0xFF0F766E),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      selectedDate == null
                                          ? "Pilih Tanggal"
                                          : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                      style: TextStyle(
                                        color: selectedDate == null
                                            ? Colors.grey.shade600
                                            : Colors.black87,
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Jam Keberangkatan
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Jam Keberangkatan",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: selectedSchedule,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F766E),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: selectedDestination != null
                                ? selectedDestination!.schedules.map((
                                    schedule,
                                  ) {
                                    return DropdownMenuItem<String>(
                                      value: schedule,
                                      child: Text(
                                        schedule,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList()
                                : [],
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSchedule = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Jumlah Peserta (Pax)
                const Text(
                  "Jumlah Peserta (Pax)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Jumlah Pax",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Color(0xFF0F766E),
                            ),
                            onPressed: paxCount > 1
                                ? () {
                                    setState(() {
                                      paxCount--;
                                    });
                                  }
                                : null,
                          ),
                          Text(
                            paxCount.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: Color(0xFF0F766E),
                            ),
                            onPressed: () {
                              setState(() {
                                paxCount++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 40, thickness: 1),

                // Rincian Pembayaran
                const Text(
                  "Rincian Pembayaran",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Tiket
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tiket (${selectedDestination?.name ?? 'TBD'})",
                            style: const TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "${_formatRupiah(selectedDestination?.price ?? 0)} x $paxCount",
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatRupiah(
                              (selectedDestination?.price ?? 0) * paxCount,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),

                      // Transportasi
                      if (_transportPrice > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Transportasi ($_selectedTransportName)",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            Text(
                              "${_formatRupiah(_transportPrice)} x $paxCount",
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              _formatRupiah(_transportPrice * paxCount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Transportasi (Datang Sendiri)",
                              style: TextStyle(color: Colors.black54),
                            ),
                            const Text(
                              "Rp0",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Kode Unik Transaksi",
                            style: TextStyle(color: Colors.black54),
                          ),
                          Text(
                            "+${_formatRupiah(uniqueCode)}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Pembayaran",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            _formatRupiah(
                              ((selectedDestination?.price ?? 0) * paxCount) +
                                  (_transportPrice * paxCount) +
                                  uniqueCode,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF0F766E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 2,
                    ),
                    onPressed: _submitBooking,
                    child: const Text(
                      "Konfirmasi Booking",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransportOption(String type, IconData icon) {
    final isSelected = _selectedTransportType == type;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTransportType = type;
          _selectedTransportName = null;
          _transportPrice = 0;
        });
      },
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: type != 'Jalur Laut' ? 1 : 0,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0F766E) : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                type,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF0F766E) : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF0F766E),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
