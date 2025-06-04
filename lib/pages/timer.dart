// lib/pages/timer.dart
import 'dart:async';
import 'package:flutter/cupertino.dart'; // Untuk CupertinoPicker
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  Duration initialDuration = const Duration();
  Duration remaining = const Duration();
  Timer? countdownTimer;
  bool isRunning = false;

  int selectedHours = 0;
  int selectedMinutes = 0;
  int selectedSeconds = 0;

  @override
  void dispose() {
    countdownTimer?.cancel(); // Pastikan timer dibatalkan saat widget dibuang
    super.dispose();
  }

  void startTimer() {
    if (isRunning) return;

    // Set duration when Start is pressed
    setState(() {
      initialDuration = Duration(
        hours: selectedHours,
        minutes: selectedMinutes,
        seconds: selectedSeconds,
      );
      remaining = initialDuration;
      isRunning = true;
    });

    if (remaining.inSeconds == 0) return; // Jangan mulai jika durasi 0

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inSeconds <= 1) { // Periksa <=1 agar detik terakhir terlihat
        timer.cancel();
        setState(() {
          isRunning = false;
          remaining = Duration.zero;
        });
        _showTimerCompletionDialog(); // Tampilkan dialog saat timer selesai
      } else {
        setState(() {
          remaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void pauseTimer() {
    countdownTimer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    countdownTimer?.cancel();
    setState(() {
      isRunning = false;
      remaining = Duration.zero;
      selectedHours = 0; // Reset picker values
      selectedMinutes = 0;
      selectedSeconds = 0;
    });
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(duration.inHours)}:"
        "${twoDigits(duration.inMinutes.remainder(60))}:"
        "${twoDigits(duration.inSeconds.remainder(60))}";
  }

  // Dialog yang muncul saat timer selesai
void _showTimerCompletionDialog() {
  // Buat instance AudioPlayer lokal jika tidak dideklarasikan di kelas
  // Atau gunakan instance yang sudah ada di kelas (_TimerPageState)
  final localAudioPlayer = AudioPlayer(); // Buat instance baru untuk playback ini

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Timer Selesai!'),
      content: const Text('Waktu Anda telah habis. Ayo lakukan hal berikutnya!'),
      actions: [
        TextButton(
          onPressed: () {
            localAudioPlayer.stop(); // Hentikan suara jika pengguna mengetuk OK
            Navigator.pop(context);
          },
          child: const Text('OK', style: TextStyle(color: Colors.black87)),
        ),
      ],
    ),
  ).then((_) {
    // Setelah dialog ditutup (baik dengan tombol OK atau ketukan luar),
    // pastikan audioPlayer di-dispose agar tidak ada kebocoran memori.
    localAudioPlayer.dispose();
  });

  // 🎵 TAMBAHKAN KODE PEMUTAR SUARA INI
  localAudioPlayer.play(AssetSource('sounds/timer_sound.mp3')); // 👇 Sesuaikan nama file Anda

}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( // 👇 AppBar yang konsisten
        title: const Text('Timer'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(flex: 2), // Spasi lebih banyak di atas
            Text(
              formatTime(remaining),
              style: TextStyle(
                fontSize: 70, // Lebih besar
                fontWeight: FontWeight.w900, // Sangat tebal
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            // Tampilkan picker jika timer tidak berjalan dan waktu 0
            if (!isRunning && remaining == Duration.zero)
              Column(
                children: [
                  SizedBox(
                    height: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildPicker('Jam', 0, 23, (val) {
                          setState(() {
                            selectedHours = val;
                          });
                        }),
                        buildPicker('Menit', 0, 59, (val) {
                          setState(() {
                            selectedMinutes = val;
                          });
                        }),
                        buildPicker('Detik', 0, 59, (val) {
                          setState(() {
                            selectedSeconds = val;
                          });
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30), // Spasi lebih besar
                ],
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton( // 👇 Gunakan widget tombol kustom
                  label: isRunning ? 'Jeda' : 'Mulai',
                  onPressed: isRunning ? pauseTimer : startTimer,
                  isPrimary: true,
                ),
                const SizedBox(width: 15),
                _buildActionButton( // 👇 Gunakan widget tombol kustom
                  label: 'Reset',
                  onPressed: resetTimer,
                  isPrimary: false,
                ),
              ],
            ),
            const Spacer(flex: 3), // Spasi lebih banyak di bawah
          ],
        ),
      ),
    );
  }

  // 👇 Widget pembantu untuk tombol aksi (Mulai/Jeda/Reset)
  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? Colors.black87 : Colors.grey[300], // Warna berbeda
        foregroundColor: isPrimary ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        shadowColor: Colors.black26,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
        ),
      ),
    );
  }


  // 👇 Widget buildPicker dengan styling yang disempurnakan
  Widget buildPicker(String label, int min, int max, ValueChanged<int> onChanged) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(
          width: 80,
          height: 100, // Tinggi picker
          child: CupertinoPicker(
            scrollController: FixedExtentScrollController(initialItem: 0),
            itemExtent: 32, // Tinggi setiap item
            onSelectedItemChanged: onChanged,
            selectionOverlay: CupertinoPickerDefaultSelectionOverlay( // Overlay pilihan
              background: Colors.black87.withOpacity(0.1),
            ),
            children: List.generate(
              max - min + 1,
              (index) => Center(
                child: Text(
                  '${min + index}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}