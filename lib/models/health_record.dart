import 'package:flutter/material.dart';

class HealthRecord {
  final String id;
  final DateTime date;
  final HealthType type;
  final double value;
  final String? unit;
  final String? notes;

  HealthRecord({required this.id, required this.date, required this.type, required this.value, this.unit, this.notes});

  Map<String, dynamic> toJson() {
    return {'id': id, 'date': date.toIso8601String(), 'type': type.toString().split('.').last, 'value': value, 'unit': unit, 'notes': notes};
  }

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      type: HealthType.values.firstWhere((e) => e.toString().split('.').last == json['type']),
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

enum HealthType { steps, weight, water, sleep, heartRate }

extension HealthTypeExtension on HealthType {
  String get displayName {
    switch (this) {
      case HealthType.steps:
        return 'Steps';
      case HealthType.weight:
        return 'Weight';
      case HealthType.water:
        return 'Water';
      case HealthType.sleep:
        return 'Sleep';
      case HealthType.heartRate:
        return 'Heart Rate';
    }
  }

  String get defaultUnit {
    switch (this) {
      case HealthType.steps:
        return 'steps';
      case HealthType.weight:
        return 'kg';
      case HealthType.water:
        return 'ml';
      case HealthType.sleep:
        return 'hours';
      case HealthType.heartRate:
        return 'bpm';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthType.steps:
        return Icons.directions_walk;
      case HealthType.weight:
        return Icons.monitor_weight;
      case HealthType.water:
        return Icons.water_drop;
      case HealthType.sleep:
        return Icons.bedtime;
      case HealthType.heartRate:
        return Icons.favorite;
    }
  }

  Color get color {
    switch (this) {
      case HealthType.steps:
        return const Color(0xFF2196F3);
      case HealthType.weight:
        return const Color(0xFF9C27B0);
      case HealthType.water:
        return const Color(0xFF00BCD4);
      case HealthType.sleep:
        return const Color(0xFF673AB7);
      case HealthType.heartRate:
        return const Color(0xFFF44336);
    }
  }
}
