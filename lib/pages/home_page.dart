import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/banner_slider.dart';
import '../data/tour_store.dart';
import '../widgets/destination_card.dart';
import 'login_page.dart';
import '../models/destination.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TourStore _store = TourStore();
  final ImagePicker _imagePicker = ImagePicker();
  String searchQuery = "";
  String selectedCategory = "Semua";

  final List<String> categories = ["Semua", "Pantai", "Gunung", "Petualangan"];

  ImageProvider _avatarProvider(String avatarPath) {
    if (avatarPath.toLowerCase().startsWith('http')) {
      return NetworkImage(avatarPath);
    }
    return FileImage(File(avatarPath));
  }

  Future<void> _pickAvatarImage(
    StateSetter setModalState,
    String currentAvatar,
    List<String> avatarOptions,
    int avatarIndex,
    void Function(String, int) onUpdate,
  ) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Batal'),
              onTap: () => Navigator.pop(context, null),
            ),
          ],
        );
      },
    );

    if (source == null) return;
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked != null) {
      onUpdate(picked.path, -1);
      setModalState(() {});
    }
  }

  void _showProfileSheet() {
    final user = _store.currentUser;
    if (user == null) return;

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    final avatarOptions = [
      "https://i.pravatar.cc/150?img=65",
      "https://i.pravatar.cc/150?img=66",
      "https://i.pravatar.cc/150?img=67",
    ];
    int avatarIndex = avatarOptions.indexOf(user.avatarUrl);
    if (avatarIndex == -1) avatarIndex = 0;
    String currentAvatar = user.avatarUrl;
    bool editMode = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  InkWell(
                    onTap: editMode
                        ? () async {
                            await _pickAvatarImage(
                              setModalState,
                              currentAvatar,
                              avatarOptions,
                              avatarIndex,
                              (newAvatar, newIndex) {
                                currentAvatar = newAvatar;
                                avatarIndex = newIndex;
                              },
                            );
                          }
                        : null,
                    borderRadius: BorderRadius.circular(60),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: const Color(0xFFE6F4F1),
                      backgroundImage: _avatarProvider(currentAvatar),
                      child: editMode
                          ? Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF0F766E),
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 16,
                                  color: Color(0xFF0F766E),
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  editMode
                      ? const Text(
                          "Ketuk foto untuk mengganti",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 12),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          enabled: editMode,
                          decoration: InputDecoration(
                            labelText: "Nama",
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xFF0F766E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nama wajib diisi";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: emailController,
                          enabled: editMode,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(
                              Icons.email,
                              color: Color(0xFF0F766E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email wajib diisi";
                            }
                            if (!RegExp(
                              r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                            ).hasMatch(value.trim())) {
                              return "Email tidak valid";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: phoneController,
                          enabled: editMode,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: "Nomor Telepon",
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xFF0F766E),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nomor telepon wajib diisi";
                            }
                            final trimmed = value.trim();
                            if (!RegExp(r"^\d{12}$").hasMatch(trimmed)) {
                              return "Nomor telepon harus 12 digit";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      if (!editMode) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFEF4444)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              _store.logout();
                              Navigator.pop(context);
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            },
                            child: const Text("Logout"),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF0F766E),
                                side: const BorderSide(
                                  color: Color(0xFF0F766E),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Tutup"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: editMode
                                    ? const Color(0xFF0F766E)
                                    : Colors.white,
                                foregroundColor: editMode
                                    ? Colors.white
                                    : const Color(0xFF0F766E),
                                side: const BorderSide(
                                  color: Color(0xFF0F766E),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              onPressed: () {
                                if (!editMode) {
                                  setModalState(() {
                                    editMode = true;
                                  });
                                  return;
                                }
                                if (!formKey.currentState!.validate()) return;
                                _store.updateCurrentUser(
                                  name: nameController.text.trim(),
                                  email: emailController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  avatarUrl: currentAvatar,
                                );
                                Navigator.pop(context);
                              },
                              child: Text(
                                editMode ? "Simpan Profil" : "Edit Profil",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        // Filter destinations based on search query and category tab
        List<Destination> filteredDestinations = _store.destinationsList.where((
          dest,
        ) {
          final matchesSearch =
              dest.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
              dest.location.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesCategory =
              selectedCategory == "Semua" || dest.category == selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        // High-rating recommendations for the horizontal scroll section
        List<Destination> recommendedDestinations = _store.destinationsList
            .where((dest) => dest.rating >= 4.9)
            .toList();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Halo ${_store.currentUser?.name.split(' ')[0] ?? 'Traveler'},",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              "Mau Liburan Ke Mana?",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        // Interactive User Profile Avatar
                        InkWell(
                          onTap: _showProfileSheet,
                          borderRadius: BorderRadius.circular(25),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF0F766E),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: const Color(0xFFE2E8F0),
                              backgroundImage: NetworkImage(
                                _store.currentUser?.avatarUrl ??
                                    "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100&auto=format&fit=crop&q=80",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: "Cari destinasi atau lokasi...",
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF0F766E),
                          ),
                          suffixIcon: Icon(
                            Icons.tune,
                            color: Color(0xFF0F766E),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Auto Slider Banner Promo
                    const BannerSlider(),
                    const SizedBox(height: 24),

                    // Kategori Chips Horizontal
                    const Text(
                      "Kategori Wisata",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(
                                cat,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFF0F766E),
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.grey.shade200,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    selectedCategory = cat;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Horizontal Recommendations (only shown if search query is empty and 'All' category is selected)
                    if (searchQuery.isEmpty && selectedCategory == "Semua") ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Rekomendasi Utama",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Lihat Semua",
                              style: TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 320,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendedDestinations.length,
                          itemBuilder: (context, index) {
                            final dest = recommendedDestinations[index];
                            return Container(
                              width: 220,
                              margin: const EdgeInsets.only(
                                right: 14,
                                bottom: 8,
                              ),
                              child: DestinationCard(destination: dest),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Semua Destinasi Grid / List
                    Text(
                      selectedCategory == "Semua"
                          ? "Semua Destinasi"
                          : "Destinasi $selectedCategory",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (filteredDestinations.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 50,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Destinasi tidak ditemukan",
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      // List Destinasi Vertikal
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredDestinations.length,
                        itemBuilder: (context, index) {
                          return DestinationCard(
                            destination: filteredDestinations[index],
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
