// lib/models/alarm.dart
import 'package:flutter/material.dart';

class Alarm {
  String id;
  TimeOfDay time;
  bool isActive;
  String label;
  List<int> repeatDays;
  String? soundAssetPath;
  bool vibrate;
  String characterType; // 'default_tts' atau 'david_goggins'

  Alarm({
    String? id,
    required this.time,
    this.isActive = true,
    this.label = 'Alarm',
    this.repeatDays = const [],
    this.soundAssetPath,
    this.vibrate = true,
    this.characterType = 'default_tts',
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      time: TimeOfDay(hour: json['hour'] as int, minute: json['minute'] as int),
      isActive: json['isActive'] as bool,
      label: json['label'] as String,
      repeatDays: (json['repeatDays'] as List?)?.map((e) => e as int).toList() ?? [],
      soundAssetPath: json['soundAssetPath'] as String?,
      vibrate: json['vibrate'] as bool,
      characterType: json['characterType'] as String? ?? 'default_tts',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hour': time.hour,
      'minute': time.minute,
      'isActive': isActive,
      'label': label,
      'repeatDays': repeatDays,
      'soundAssetPath': soundAssetPath,
      'vibrate': vibrate,
      'characterType': characterType,
    };
  }
}