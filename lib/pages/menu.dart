// lib/pages/menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import untuk SVG Icon
import 'alarm.dart';
import 'timer.dart';
import 'last_resort.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // 🔙 Back Button (top-left) - Tetap sama, konsisten
            Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // 📋 Centered Menu Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pilih Fitur', // Judul lebih interaktif
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // 👇 Gunakan MenuCard baru
                  MenuCard(
                    icon: Icons.alarm, // Ikon untuk Alarm
                    label: 'Alarm',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AlarmPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  MenuCard(
                    icon: Icons.timer, // Ikon untuk Timer
                    label: 'Timer',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TimerPage()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  MenuCard(
                    icon: Icons.health_and_safety, // Ikon untuk Last Resort (bisa diubah)
                    label: 'Last Resort',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LastResortPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🎨 Widget MenuCard yang Lebih Menarik (Ditempatkan di bawah MenuPage)
class MenuCard extends StatelessWidget {
  final IconData icon; // Ganti dengan IconData
  final String label;
  final VoidCallback onPressed;

  const MenuCard({
    super.key,
    required this.icon, // Sekarang menerima IconData
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // Shadow yang lebih bagus
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Sudut membulat
      ),
      margin: const EdgeInsets.symmetric(horizontal: 20), // Margin horizontal
      child: InkWell( // Menggunakan InkWell untuk efek ripple saat diketuk
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.black87), // Ikon
              const SizedBox(width: 20),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}