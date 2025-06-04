// lib/pages/home.dart
import 'package:flutter/material.dart';
import 'dashboard.dart'; // Nanti kita akan membuat file dashboard.dart

class HomePage extends StatelessWidget { // Ganti nama class jadi WelcomeScreen jika Anda mau, tapi kita biarkan HomePage dulu
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/wake_up_man.png', // Ganti dengan nama file gambar Anda
              height: 350, // Sesuaikan tinggi gambar sesuai keinginan
              width: 500,  // Sesuaikan lebar gambar
              fit: BoxFit.contain, // Pastikan gambar pas
            ),
            const SizedBox(height: 0), // Beri sedikit spasi antara gambar dan teks

            const Text(
              'BangunYuk',
              style: TextStyle(
                fontSize: 45, // Lebih besar lagi
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: 2.5,
              ),
            ),
            const Text(
              'Motivasi Setiap Pagi Anda', // Tagline yang lebih motivational
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 80),

            ElevatedButton(
              onPressed: () {
                // Setelah ditekan, navigasi ke Dashboard Utama
                Navigator.pushReplacement( // Gunakan pushReplacement agar tidak bisa kembali ke halaman ini
                  context,
                  MaterialPageRoute(builder: (_) => const MainDashboardPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), // Lebih membulat
                ),
                elevation: 10, // Shadow lebih menonjol
                shadowColor: Colors.black45,
              ),
              child: const Text(
                'Mulai Sekarang', // Teks yang lebih memotivasi
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}