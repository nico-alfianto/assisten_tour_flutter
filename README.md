# 🌴 Assistant Tour - Web Version

Versi web responsif dari aplikasi Flutter **Assistant Tour**.

Aplikasi booking tour & travel Indonesia yang dibangun menggunakan **HTML5, CSS3, dan Vanilla JavaScript**. Seluruh fitur berjalan langsung di browser tanpa backend, dengan penyimpanan data menggunakan **LocalStorage** sehingga tetap dapat digunakan secara offline.

## 🔗 Demo & Repository

- 🌐 **Live Demo:** https://nico-alfianto.github.io/assisten-tour-flutter-demo/home.html
- 📱 **Repository Flutter (Original):** https://github.com/nico-alfianto/assisten_tour_flutter

---

## ✨ Fitur

Konversi fitur **1:1** dari versi Flutter.

- 🔐 **Autentikasi**
  - Login
  - Register
  - Penyimpanan akun menggunakan LocalStorage

- 🏝️ **Home**
  - Banner slider otomatis
  - Pencarian destinasi
  - Rekomendasi destinasi dengan rating tertinggi

- 📍 **Detail Destinasi**
  - Informasi lengkap destinasi
  - Harga paket
  - Pilihan jadwal
  - Daftar ulasan

- 🎫 **Booking**
  - Pilih tanggal keberangkatan
  - Pilih jenis transportasi
  - Tentukan jumlah peserta
  - Boarding Pass dibuat otomatis

- 📅 **Jadwal Saya**
  - Daftar seluruh booking
  - Status pembayaran (Lunas / Belum Bayar)
  - QR Boarding Pass

- 💳 **Pembayaran**
  - Tab **Belum Bayar**
  - Tab **Sudah Bayar**
  - Metode pembayaran:
    - Transfer Bank
    - E-Wallet
    - Virtual Account (VA)

- ⭐ **Ulasan**
  - Melihat seluruh review
  - Menambahkan review baru

- 👤 **Profil**
  - Edit nama
  - Edit email
  - Edit nomor HP
  - Ganti password
  - Upload foto profil
  - Statistik pengguna

---

## 🔑 Akun Demo

Gunakan akun berikut untuk mencoba aplikasi.

**Email**
```text
budi@gmail.com
```

**Password**
```text
password123
```

---

## 🚀 Deploy ke GitHub Pages

1. Fork atau clone repository ini.
2. Masuk ke **Settings → Pages**.
3. Pada **Source**, pilih:
   - **Deploy from a branch**
   - Branch **main**
   - Folder **/root**
4. Klik **Save**.
5. Tunggu sekitar 1–2 menit hingga proses deployment selesai.
6. Buka aplikasi melalui:

```text
https://username.github.io/assisten-tour-flutter-demo/home.html
```

---

## 🛠️ Tech Stack

- HTML5
- CSS3
- Vanilla JavaScript (ES6)
- LocalStorage

Tanpa framework, tanpa proses build, dan tanpa backend.

Cukup clone atau download, lalu buka file HTML di browser.

---

## 📂 Struktur Folder

```text
.
├── index.html          # Welcome Screen
├── login.html          # Login & Register
├── home.html           # Home + Search + Rekomendasi
├── detail.html         # Detail Destinasi
├── booking.html        # Form Booking
├── schedule.html       # Jadwal & Boarding Pass
├── payment.html        # Pusat Pembayaran
├── review.html         # Halaman Review
├── profile.html        # Profil & Edit Data
├── style.css           # Seluruh styling
├── script.js           # Data, Logic, dan TourStore
└── assets/             # Banner, ikon, dan gambar destinasi
```

---

## 📱 Responsive

- ✅ Mobile First
- ✅ Responsive untuk Android & iPhone
- ✅ Tampilan menyerupai aplikasi mobile
- ✅ Berjalan di seluruh browser modern

---

## ❤️ Kredit

Dibuat sebagai versi web dari proyek Flutter:

**Repository Flutter:** https://github.com/nico-alfianto/assisten_tour_flutter

Terima kasih kepada proyek asli yang menjadi referensi utama dalam pengembangan versi web ini.
