// lib/main.dart
import 'package:alarmapp/pages/home.dart'; // Ini akan mengimpor HomePage Anda
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart'; // <--- TAMBAHKAN INI
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert'; // Untuk jsonDecode
import 'package:alarmapp/models/alarm.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> playAlarmSoundAndMessageGlobal(String alarmId) async {
  // Inisialisasi plugin yang dibutuhkan di background (karena ini fungsi top-level)
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Penting jika ada penggunaan TZDateTime di sini

  // Inisialisasi AudioPlayer dan FlutterTts secara lokal di sini
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterTts flutterTts = FlutterTts();

  // Atur bahasa default jika diperlukan
  await flutterTts.setLanguage("en-US"); // Atau "id-ID"

  // Muat data alarm dari SharedPreferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? alarmsJsonString = prefs.getString('alarms');

  if (alarmsJsonString != null) {
    final List<dynamic> jsonList = jsonDecode(alarmsJsonString);
    final List<Alarm> alarms = jsonList.map((json) => Alarm.fromJson(json)).toList();
    
    // Cari alarm yang sesuai dengan ID
    final Alarm? alarmToPlay = alarms.firstWhere((alarm) => alarm.id == alarmId, orElse: () => null!);

    if (alarmToPlay != null) {
      print('Playing alarm sound for: ${alarmToPlay.label}');
      if (alarmToPlay.characterType == 'david_goggins') {
        await audioPlayer.play(AssetSource('sounds/david_goggins.mp3'));
        await Future.delayed(const Duration(seconds: 1)); // Jeda lebih lama untuk David Goggins
      }
      await flutterTts.speak(alarmToPlay.label);
    } else {
      print('Alarm with ID $alarmId not found in SharedPreferences.');
    }
  } else {
    print('No alarms found in SharedPreferences.');
  }

  // Penting: Pastikan untuk membuang resources setelah selesai
  await audioPlayer.dispose();
  await flutterTts.stop(); // Hentikan TTS jika masih berbicara
  // flutterTts.dispose(); // FlutterTts tidak memiliki metode dispose di versi lama.
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Tangani ketukan notifikasi dari background/killed state di sini.
  // Anda bisa menambahkan logika seperti navigasi ke halaman tertentu,
  // membuka aplikasi, atau memproses data dari payload.
  print('Background notification tapped: ${notificationResponse.payload}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  tz.initializeTimeZones();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // Callback ini dipanggil saat pengguna mengetuk notifikasi ketika aplikasi sedang berjalan.
      print('Notification tapped: ${notificationResponse.payload}');
      if (notificationResponse.payload != null) {
        playAlarmSoundAndMessageGlobal(notificationResponse.payload!);
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  if (defaultTargetPlatform == TargetPlatform.android) {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'alarm_app_id', // ID yang sama dengan di AndroidNotificationDetails
        'Alarm App Channel', // Nama channel
        description: 'Channel for alarm notifications', // Deskripsi
        importance: Importance.max, // Pentingnya notifikasi
      );
      await androidImplementation.createNotificationChannel(channel);
    }
  }  
  


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BangunYuk Alarm',
      theme: ThemeData(
        fontFamily: 'Poppins',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(), // Ini akan memuat halaman utama aplikasi Anda
      debugShowCheckedModeBanner: false,
    );
  }
}