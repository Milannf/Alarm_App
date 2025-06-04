// lib/pages/alarm.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm.dart';
import '../main.dart';
import 'package:timezone/timezone.dart' as tz;
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


  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }


  @override
  void dispose() {
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

  Future<void>  _scheduleAlarmNotification(Alarm alarm) async {
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
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,  // Mode ini tidak memerlukan izin exact alarm
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: alarm.id,
    );
    print('Alarm scheduled with ID: ${alarm.id.hashCode}');
  } catch (e) {
    print('Failed to schedule alarm: $e'); // Ini akan terpanggil jika ada error
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
                      setState(() {
                        selectedCharacterType = value;
                      });
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
                      setState(() {
                        selectedCharacterType = value;
                      });
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

  void _toggleAlarm(Alarm alarm, bool newValue) {
    setState(() {
      alarm.isActive = newValue;
    });
    _saveAlarms();
    if (newValue) {
      _scheduleAlarmNotification(alarm);
    } else {
      _cancelAlarmNotification(alarm.id);
    }
  }

  void _deleteAlarm(String alarmId) {
    setState(() {
      alarms.removeWhere((alarm) => alarm.id == alarmId);
    });
    _saveAlarms();
    _cancelAlarmNotification(alarmId);
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
      body: SafeArea(
        child: Stack(
          children: [
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

            Padding(
              padding: const EdgeInsets.only(
                  top: 80, left: 16, right: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Alarms',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (alarms.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text(
                          'No alarms set yet.\nTap "Add" to create one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: alarms.length,
                        itemBuilder: (context, index) {
                          final alarm = alarms[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        alarm.time.format(context),
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: alarm.isActive
                                              ? Colors.black87
                                              : Colors.grey,
                                        ),
                                      ),
                                      Switch(
                                        value: alarm.isActive,
                                        onChanged: (newValue) {
                                          _toggleAlarm(alarm, newValue);
                                        },
                                        activeColor: Colors.black87,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        alarm.label,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: alarm.isActive
                                              ? Colors.black54
                                              : Colors.grey[400],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${alarm.characterType == 'david_goggins' ? 'David Goggins' : 'Default TTS'})',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _editMessage(alarm),
                                        style: _buttonStyle(),
                                        child: const Text('Edit Message'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                              title: const Text('Delete Alarm?'),
                                              content: const Text(
                                                  'Are you sure you want to delete this alarm?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    _deleteAlarm(alarm.id);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        style: _deleteButtonStyle(),
                                        child: const Text('Delete'),
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
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.black12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _footerButton(
                      label: 'Add',
                      onPressed: _addAlarm,
                    ),
                    _footerButton(
                      label: 'Test Notif Now',
                      onPressed: () async {
                        const AndroidNotificationDetails androidPlatformChannelSpecifics =
                            AndroidNotificationDetails(
                          'alarm_app_id', // ID yang sama dengan channel utama
                          'Alarm App Channel',
                          channelDescription: 'Channel for alarm notifications',
                          importance: Importance.max,
                          priority: Priority.high,
                          ticker: 'ticker',
                          // sound: RawResourceAndroidNotificationSound('alarm_sound'), // Opsional
                        );
                        const DarwinNotificationDetails darwinPlatformChannelSpecifics =
                            DarwinNotificationDetails();
                        const NotificationDetails platformChannelSpecifics = NotificationDetails(
                          android: androidPlatformChannelSpecifics,
                          iOS: darwinPlatformChannelSpecifics,
                        );

                        await flutterLocalNotificationsPlugin.show(
                          0, // ID notifikasi unik
                          'Notifikasi Tes Alarm',
                          'Ini adalah notifikasi tes instan!',
                          platformChannelSpecifics,
                          payload: 'test_payload',
                        );
                        print('Instant notification sent.');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Styles
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