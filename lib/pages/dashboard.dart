// lib/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu
import 'dart:async'; // Untuk Timer
import 'alarm.dart';
import 'timer.dart';
import 'stopwatch.dart'; // Kita akan buat ini nanti jika belum ada


class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  int _selectedIndex = 0; // Indeks untuk Bottom Navigation Bar

  // Daftar halaman yang akan ditampilkan di Bottom Navigation Bar
  final List<Widget> _pages = [
    const ClockDashboardTab(), // Tab untuk Tampilan Jam (layar paling kiri)
    const AlarmPage(),        // Tab untuk Alarm
    const TimerPage(),        // Tab untuk Timer
    // const StopwatchPage(), // Tambahkan ini jika StopwatchPage sudah ada
  ];

  // Fungsi yang dipanggil saat item Bottom Navigation Bar diketuk
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      // 👇 PERBAIKI BOTTOM NAVIGATION BAR DI SINI
      bottomNavigationBar: Container( // Membungkus BottomNavigationBar dalam Container
        margin: const EdgeInsets.only(bottom: 10, left: 15, right: 15), // Memberi sedikit margin dari bawah dan samping
        decoration: BoxDecoration(
          color: Colors.white, // Warna latar belakang navbar
          borderRadius: BorderRadius.circular(25), // Sudut membulat di seluruh Container
          boxShadow: [
            BoxShadow(
              color: Colors.black38.withOpacity(0.15), // Warna shadow yang lebih halus
              blurRadius: 15, // Efek blur shadow
              spreadRadius: 2, // Sebaran shadow
              offset: Offset(0, 10), // Posisi shadow (di bawah)
            ),
          ],
        ),
        child: ClipRRect( // Clip untuk memastikan sudut membulat diterapkan pada BottomNavigationBar itu sendiri
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.watch_later_outlined), // Ikon Jam
                label: 'Jam',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.alarm), // Ikon Alarm
                label: 'Alarm',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer), // Ikon Timer
                label: 'Timer',
              ),
              // Tambahkan ini jika StopwatchPage sudah ada dan diinginkan
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.timer_10), // Ikon Stopwatch
              //   label: 'Stopwatch',
              // ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.black87, // Warna ikon/teks terpilih
            unselectedItemColor: Colors.grey[600], // Warna ikon/teks tidak terpilih (sedikit lebih gelap)
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed, // Item tetap di tempatnya saat diketuk
            backgroundColor: Colors.white, // Latar belakang navbar itu sendiri
            elevation: 0, // Hapus elevation bawaan karena sudah di handle oleh Container
            selectedFontSize: 14, // Ukuran font item terpilih
            unselectedFontSize: 12, // Ukuran font item tidak terpilih
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600), // Gaya teks terpilih
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500), // Gaya teks tidak terpilih
            // Optional: Tambahkan sedikit padding di sekitar item jika diinginkan
            // iconSize: 26,
          ),
        ),
      ),
    );
  }
}


// Widget untuk Tampilan Jam di Dashboard (layar paling kiri inspirasi)
class ClockDashboardTab extends StatefulWidget {
  const ClockDashboardTab({super.key});

  @override
  State<ClockDashboardTab> createState() => _ClockDashboardTabState();
}

class _ClockDashboardTabState extends State<ClockDashboardTab> {
  late DateTime _currentTime;
  late String _currentDate;
  late String _greeting;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
      _currentDate = DateFormat('EEEE, dd MMMM yyyy').format(_currentTime);
      _greeting = _getGreeting(_currentTime.hour);
    });
  }

  String _getGreeting(int hour) {
    if (hour >= 5 && hour < 12) {
      return 'Selamat Pagi';
    } else if (hour >= 12 && hour < 17) {
      return 'Selamat Siang';
    } else if (hour >= 17 && hour < 20) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Lokasi dan Tanggal (seperti inspirasi)
        Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.location_on_outlined, size: 20, color: Color.fromARGB(255, 46, 45, 45)),
                  SizedBox(width: 5),
                  Text('Indonesia', style: TextStyle(fontSize: 16, color:Color.fromARGB(255, 46, 45, 45))),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                _currentDate,
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
        
        // Tampilan Jam Besar (seperti inspirasi)
              // 👇 PERBAIKI TAMPILAN JAM BESAR DI SINI
        Stack( // Gunakan Stack untuk menumpuk lingkaran
          alignment: Alignment.center, // Pusatkan semua children di dalam Stack
          children: [
            // Lingkaran Border / Background yang Lebih Besar
            Container(
              width: 280, // Sedikit lebih besar dari jam utama (250)
              height: 280, // Sedikit lebih besar dari jam utama (250)
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 148, 145, 145), // Warna abu-abu muda untuk border
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38.withOpacity(0.2), // Shadow lebih halus
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
            ),
            // Lingkaran Jam Utama (yang sudah ada)
            Container(
              width: 250, // Lebar jam utama
              height: 250, // Tinggi jam utama
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87, // Warna hitam untuk jam utama
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  DateFormat('hh:mm').format(_currentTime), // Format jam
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        // 👆
        Text(
          DateFormat('a').format(_currentTime).toUpperCase(), // AM/PM
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 40),

        // Sapaan dan Icon (seperti inspirasi)
        Text(
          _greeting,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        // Icon di sini bisa disesuaikan dengan waktu/sapaan
        Icon(
          _greeting.contains('Pagi') ? Icons.wb_sunny_outlined : 
          _greeting.contains('Siang') ? Icons.brightness_high_outlined : 
          _greeting.contains('Sore') ? Icons.wb_twilight :
          Icons.nightlight_round,
          size: 60,
          color: Colors.amber, // Warna ikon matahari/bulan
        ),
      ],
    );
  }
}