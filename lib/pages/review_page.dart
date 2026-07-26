import 'package:flutter/material.dart';
import '../data/tour_store.dart';
import '../models/destination.dart';
import '../models/review.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TourStore _store = TourStore();
  final _formKey = GlobalKey<FormState>();

  Destination? selectedDestination;
  double selectedRating = 5.0;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (_store.destinationsList.isNotEmpty) {
      selectedDestination = _store.destinationsList[0];
    }

    // Prefill reviewer name if user is logged in
    final currentUser = _store.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _submitReview() {
    if (!_formKey.currentState!.validate()) return;
    if (selectedDestination == null) return;

    final newReview = Review(
      id: "RV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
      destinationName: selectedDestination!.name,
      userName: _nameController.text,
      rating: selectedRating,
      comment: _commentController.text,
      date: DateTime.now(),
    );

    // Save to store
    _store.addReview(newReview);

    // Reset Form Fields
    _commentController.clear();
    _nameController.clear();
    setState(() {
      selectedRating = 5.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text("Ulasan Anda berhasil dikirim!"),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildStarSelector() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = starValue;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              starValue <= selectedRating ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final allReviews = _store.reviewsList;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Ulasan & Review",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: const Color(0xFF0F766E),
            centerTitle: true,
          ),
          body: Container(
            color: Colors.grey.shade50,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Form Tulis Ulasan
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.rate_review, color: Color(0xFF0F766E)),
                              SizedBox(width: 8),
                              Text(
                                "Tulis Ulasan Perjalanan",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Pilih Destinasi Wisata
                          const Text(
                            "Destinasi Wisata",
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
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: const BorderSide(
                                  color: Color(0xFF0F766E),
                                  width: 2,
                                ),
                              ),
                            ),
                            items: _store.destinationsList.map((dest) {
                              return DropdownMenuItem<Destination>(
                                value: dest,
                                child: Text(dest.name),
                              );
                            }).toList(),
                            onChanged: (Destination? newValue) {
                              setState(() {
                                selectedDestination = newValue;
                              });
                            },
                          ),
                          const SizedBox(height: 16),

                          // Nama Pengulas
                          const Text(
                            "Nama Anda",
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
                                return "Nama wajib diisi!";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Contoh: Budi Santoso",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
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

                          // Rating Bintang Selector
                          const Center(
                            child: Text(
                              "Berikan Rating Bintang Anda",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(child: _buildStarSelector()),
                          const SizedBox(height: 16),

                          // Komentar Ulasan
                          const Text(
                            "Tulis Ulasan Anda",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _commentController,
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Isi komentar ulasan wajib ditulis!";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText:
                                  "Bagikan pengalaman liburan menyenangkan Anda di sini...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
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
                          const SizedBox(height: 20),

                          // Tombol Submit
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _submitReview,
                              child: const Text(
                                "Kirim Ulasan Wisata",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Feed Ulasan Pengguna Lain
                  const Text(
                    "Umpan Balik Pengunjung",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (allReviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text("Belum ada ulasan liburan.")),
                    )
                  else
                    // List Ulasan Global
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allReviews.length,
                      itemBuilder: (context, index) {
                        final review = allReviews[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Ulasan untuk: ${review.destinationName}",
                                        style: const TextStyle(
                                          color: Color(0xFF0F766E),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        review.rating.toString(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text(
                                review.comment,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade700,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Dikirim pada: ${review.date.day}/${review.date.month}/${review.date.year}",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
