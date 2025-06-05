// lib/pages/alarm.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../main.dart'; // Untuk flutterLocalNotificationsPlugin
import 'package:timezone/timezone.dart' as tz; // Untuk TZDateTime
import 'message.dart'; // Pastikan ini diimpor

import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';


class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Alarm> alarms = [];
  SharedPreferences? _prefs;
  
  late FlutterTts flutterTts;
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    _initTtsAndAudioPlayer();
    // Tidak ada listener notifikasi di sini lagi.
  }

  void _initTtsAndAudioPlayer() {
    flutterTts = FlutterTts();
    audioPlayer = AudioPlayer();

    flutterTts.setLanguage("en-US"); // Anda bisa ubah ke "id-ID" jika TTS mendukung
    flutterTts.setStartHandler(() {
      print("TTS started");
    });
    flutterTts.setCompletionHandler(() {
      print("TTS completed");
    });
    flutterTts.setErrorHandler((message) {
      print("TTS error: $message");
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadAlarms();
  }

  void _loadAlarms() {
    final String? alarmsJsonString = _prefs!.getString('alarms');
    if (alarmsJsonString != null) {
      final List<dynamic> jsonList = jsonDecode(alarmsJsonString);
      setState(() {
        alarms = jsonList.map((json) => Alarm.fromJson(json)).toList();
      });
    }
  }

  void _saveAlarms() {
    final List<Map<String, dynamic>> jsonList =
        alarms.map((alarm) => alarm.toJson()).toList();
    _prefs!.setString('alarms', jsonEncode(jsonList));
  }
  
  // Fungsi _playAlarmSoundAndMessage lokal telah dihapus karena ada versi global di main.dart


  Future<void> _scheduleAlarmNotification(Alarm alarm) async {
    print('Attempting to schedule alarm for: ${alarm.time.format(context)} with label: ${alarm.label}');
    final DateTime now = DateTime.now();
    DateTime scheduledDate =
        DateTime(now.year, now.month, now.day, alarm.time.hour, alarm.time.minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tz.TZDateTime scheduledTZDateTime =
        tz.TZDateTime.from(scheduledDate, tz.local);

    print('Scheduled TZDateTime: $scheduledTZDateTime');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'alarm_app_id',
      'Alarm App Channel',
      channelDescription: 'Channel for alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails darwinPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: darwinPlatformChannelSpecifics,
    );

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        alarm.id.hashCode,
        'Alarm BangunYuk!',
        alarm.label,
        scheduledTZDateTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Kembali ke mode tepat waktu
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: alarm.id,
      );
      print('Alarm scheduled with ID: ${alarm.id.hashCode}');
    } catch (e) {
      print('Failed to schedule alarm: $e');
    }
  }

  Future<void> _cancelAlarmNotification(String alarmId) async {
    await flutterLocalNotificationsPlugin.cancel(alarmId.hashCode);
  }

  void _addAlarm() async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Alarm Time',
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.black87,
            colorScheme: const ColorScheme.light(primary: Colors.black87),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (newTime != null) {
      String? selectedCharacterType = 'default_tts';
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Pilih Karakter Alarm'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  title: const Text('Suara Default (TTS)'),
                  leading: Radio<String>(
                    value: 'default_tts',
                    groupValue: selectedCharacterType,
                    onChanged: (String? value) {
                      setState(() { selectedCharacterType = value; });
                      Navigator.pop(context, value);
                    },
                  ),
                ),
                ListTile(
                  title: const Text('David Goggins (Audio Pre-recorded)'),
                  leading: Radio<String>(
                    value: 'david_goggins',
                    groupValue: selectedCharacterType,
                    onChanged: (String? value) {
                      setState(() { selectedCharacterType = value; });
                      Navigator.pop(context, value);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ).then((value) {
        if (value != null) {
          selectedCharacterType = value;
        }
      });


      final newAlarm = Alarm(
        time: newTime,
        label: 'Alarm at ${newTime.format(context)}',
        isActive: true,
        characterType: selectedCharacterType!,
      );

      setState(() {
        alarms.add(newAlarm);
      });
      _saveAlarms();
      if (newAlarm.isActive) {
        await _scheduleAlarmNotification(newAlarm);
      }
    }
  }

  void _toggleAlarm(Alarm alarm, bool newValue) async {
    setState(() {
      alarm.isActive = newValue;
    });
    _saveAlarms();
    if (newValue) {
      await _scheduleAlarmNotification(alarm);
    } else {
      await _cancelAlarmNotification(alarm.id);
    }
  }

  void _deleteAlarm(String alarmId) async {
    setState(() {
      alarms.removeWhere((alarm) => alarm.id == alarmId);
    });
    _saveAlarms();
    await _cancelAlarmNotification(alarmId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarm deleted!')),
    );
  }

  void _editMessage(Alarm alarm) async {
    final String? updatedLabel = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MessagePage(initialMessage: alarm.label),
      ),
    );

    if (updatedLabel != null && updatedLabel.isNotEmpty) {
      setState(() {
        alarm.label = updatedLabel;
      });
      _saveAlarms();
      if (alarm.isActive) {
        await _scheduleAlarmNotification(alarm);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Alarm label updated to: $updatedLabel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar( // 👇 Tambahkan AppBar untuk judul halaman
        title: const Text('Alarm Anda'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column( // Mengubah Stack menjadi Column untuk layout yang lebih lurus
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding( // Judul "Current Alarms"
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20), // Padding disesuaikan
              child: Text(
                'Current Alarms',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith( // Menggunakan tema teks
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
            ),
            
            Expanded( // Konten utama (daftar alarm atau pesan kosong)
              child: alarms.isEmpty
                  ? Center( // Desain untuk kondisi kosong yang lebih menarik
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.alarm_add,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Siap memulai hari Anda?',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.black54,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Tambahkan alarm pertama Anda!',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.black45,
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder( // Daftar Alarm
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: alarms.length,
                      itemBuilder: (context, index) {
                        final alarm = alarms[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4, // Shadow lebih dalam
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Sudut lebih membulat
                          ),
                          color: alarm.isActive ? Colors.white : Colors.grey[200], // Warna kartu aktif/non-aktif
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      alarm.time.format(context),
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith( // Ukuran waktu lebih besar
                                            fontWeight: FontWeight.bold,
                                            color: alarm.isActive ? Colors.black87 : Colors.grey[500],
                                          ),
                                    ),
                                    Switch(
                                      value: alarm.isActive,
                                      onChanged: (newValue) {
                                        _toggleAlarm(alarm, newValue);
                                      },
                                      activeColor: Colors.green, // Warna switch aktif
                                      inactiveThumbColor: Colors.grey,
                                      inactiveTrackColor: Colors.grey[300],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded( // Agar label tidak tumpang tindih
                                      child: Text(
                                        alarm.label,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: alarm.isActive ? Colors.black54 : Colors.grey[400],
                                            ),
                                        overflow: TextOverflow.ellipsis, // Jika terlalu panjang
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${alarm.characterType == 'david_goggins' ? 'David Goggins' : 'Default TTS'})',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end, // Tombol ke kanan
                                  children: [
                                    TextButton.icon( // Tombol edit sebagai TextButton
                                      onPressed: () => _editMessage(alarm),
                                      icon: Icon(Icons.edit, color: Colors.blue[700]),
                                      label: Text('Edit', style: TextStyle(color: Colors.blue[700])),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon( // Tombol delete sebagai TextButton
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Alarm?'),
                                            content: const Text(
                                                'Are you sure you want to delete this alarm?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _deleteAlarm(alarm.id);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      label: Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Floating Action Button untuk menambah alarm
            // Ini menggantikan tombol 'Add' di bagian bawah
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton( // 👇 FAB Baru
        onPressed: _addAlarm,
        backgroundColor: Colors.black87,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Posisikan di kanan bawah
    );
  }

  // Styles (ini tidak lagi digunakan secara langsung di build, tapi tetap bisa disimpan)
  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      foregroundColor: Colors.white,
    );
  }

  ButtonStyle _deleteButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      foregroundColor: Colors.white,
    );
  }

  Widget _footerButton({required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        foregroundColor: Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }
}