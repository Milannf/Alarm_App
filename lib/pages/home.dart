// lib/pages/home.dart
import 'package:flutter/material.dart';
import 'menu.dart'; // Jangan lupa import ini

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Latar belakang putih bersih
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau Ilustrasi (Opsional)
            // Anda bisa menambahkan gambar di sini, contoh:
            // Image.asset('assets/icons/alarm_icon.png', height: 100, width: 100),
            // const SizedBox(height: 30),

            // Nama Aplikasi yang Lebih Menarik
            const Text(
              'BangunYuk',
              style: TextStyle(
                fontSize: 48, // Ukuran lebih besar
                fontWeight: FontWeight.w800, // Lebih tebal
                color: Colors.black87,
                letterSpacing: 2.0, // Sedikit spasi huruf
              ),
            ),
            const Text(
              'Alarm Cerdas Anda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 60), // Spasi lebih besar

            // Tombol Utama "Mulai" yang Lebih Menarik
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87, // Warna utama
                foregroundColor: Colors.white, // Warna teks
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18), // Padding lebih besar
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Sudut lebih membulat
                ),
                elevation: 8, // Shadow lebih menonjol
                shadowColor: Colors.black38, // Warna shadow
              ),
              child: const Text(
                'Mulai Aplikasi', // Teks lebih menarik
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}