import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../models/user.dart';
import 'destination_data.dart';

class TourStore extends ChangeNotifier {
  // Singleton pattern
  static final TourStore _instance = TourStore._internal();
  factory TourStore() => _instance;
  TourStore._internal() {
    // Load initial mock reviews
    _initializeReviews();
    // Initialize mock user
    _users.add(
      User(
        name: "Budi Santoso",
        email: "budi@gmail.com",
        phone: "081234567890",
        password: "password123",
        avatarUrl: "https://i.pravatar.cc/150?img=65",
      ),
    );
  }

  // State lists
  final List<Destination> _destinations = List.from(destinations);
  final List<Booking> _bookings = [];
  final List<Review> _reviews = [];

  // Auth state
  User? _currentUser;
  final List<User> _users = [];

  // Getters
  List<Destination> get destinationsList => _destinations;
  List<Booking> get bookingsList => _bookings;
  List<Review> get reviewsList => _reviews;
  User? get currentUser => _currentUser;
  List<User> get usersList => _users;

  // Auth Actions
  bool login(String email, String password) {
    final index = _users.indexWhere(
      (u) =>
          u.email.toLowerCase() == email.trim().toLowerCase() &&
          u.password == password,
    );
    if (index != -1) {
      _currentUser = _users[index];
      notifyListeners();
      return true;
    }
    return false;
  }

  void register(User user) {
    // Check if email already exists, if so replace or ignore for simplicity
    final index = _users.indexWhere(
      (u) => u.email.toLowerCase() == user.email.trim().toLowerCase(),
    );
    if (index != -1) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void updateCurrentUser({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) {
    if (_currentUser == null) return;
    final oldEmail = _currentUser!.email;
    final updatedUser = User(
      name: name ?? _currentUser!.name,
      email: email ?? _currentUser!.email,
      phone: phone ?? _currentUser!.phone,
      password: _currentUser!.password,
      avatarUrl: avatarUrl ?? _currentUser!.avatarUrl,
    );
    _currentUser = updatedUser;
    final index = _users.indexWhere(
      (u) => u.email.toLowerCase() == oldEmail.toLowerCase(),
    );
    if (index != -1) {
      _users[index] = updatedUser;
    }
    notifyListeners();
  }

  // Initial mock reviews
  void _initializeReviews() {
    _reviews.addAll([
      Review(
        id: "r1",
        destinationName: "Pantai Kuta",
        userName: "Budi Santoso",
        rating: 5.0,
        comment:
            "Kunjungan yang sangat luar biasa! Sunset di Pantai Kuta selalu berkesan. Pelayanan tour guide sangat ramah.",
        date: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Review(
        id: "r2",
        destinationName: "Gunung Bromo",
        userName: "Siti Rahma",
        rating: 5.0,
        comment:
            "Dingin sekali tapi pemandangannya luar biasa! Naik Jeep keliling pasir berbisik sangat seru.",
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: "r3",
        destinationName: "Labuan Bajo",
        userName: "Rian Wijaya",
        rating: 4.8,
        comment:
            "Pulau Padar sangat ikonik! Walaupun lelah mendaki tangga, pemandangan dari atas membayar semuanya. Highly recommended!",
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Review(
        id: "r4",
        destinationName: "Raja Ampat",
        userName: "Dewi Lestari",
        rating: 5.0,
        comment:
            "Surga dunia yang sesungguhnya! Air laut jernih seperti kaca, terumbu karang berwarna-warni. Pengalaman snorkeling terbaik seumur hidup saya.",
        date: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Review(
        id: "r5",
        destinationName: "Danau Toba",
        userName: "Agus Prabowo",
        rating: 4.7,
        comment:
            "Danau yang sangat luas dan indah. Pulau Samosir punya budaya Batak yang kaya. Udara sejuk dan makanan lokal sangat enak!",
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      Review(
        id: "r6",
        destinationName: "Candi Borobudur",
        userName: "Maya Putri",
        rating: 4.9,
        comment:
            "Sunrise di Borobudur adalah momen magis yang tak terlupakan. Relief candinya sangat detail dan penuh sejarah. Wajib dikunjungi!",
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Review(
        id: "r7",
        destinationName: "Nusa Penida",
        userName: "Farhan Malik",
        rating: 4.9,
        comment:
            "Kelingking Beach luar biasa indah! Tebingnya sangat dramatis. Angel's Billabong juga sangat keren. Foto-fotonya pasti instagramable!",
        date: DateTime.now().subtract(const Duration(days: 6)),
      ),
      Review(
        id: "r8",
        destinationName: "Tana Toraja",
        userName: "Ratna Sari",
        rating: 4.6,
        comment:
            "Budaya Toraja sangat unik dan menarik. Rumah Tongkonan indah sekali. Pemandangan sawah terasering bikin hati tenang. Pengalaman budaya yang luar biasa.",
        date: DateTime.now().subtract(const Duration(days: 10)),
      ),
    ]);
  }

  // Actions
  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void confirmPayment(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      _bookings[index].status = 'Lunas';
      notifyListeners();
    }
  }

  void addReview(Review review) {
    _reviews.insert(0, review); // Add at the beginning of the list

    // Dynamically update destination rating and reviews count
    final destIndex = _destinations.indexWhere(
      (d) => d.name == review.destinationName,
    );
    if (destIndex != -1) {
      final dest = _destinations[destIndex];
      final newCount = dest.reviewsCount + 1;
      final newRating =
          ((dest.rating * dest.reviewsCount) + review.rating) / newCount;

      // Replace with updated destination
      _destinations[destIndex] = Destination(
        name: dest.name,
        location: dest.location,
        image: dest.image,
        description: dest.description,
        price: dest.price,
        category: dest.category,
        rating: double.parse(newRating.toStringAsFixed(1)),
        reviewsCount: newCount,
        schedules: dest.schedules,
      );
    }
    notifyListeners();
  }
}
