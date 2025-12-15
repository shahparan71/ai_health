import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/health_record.dart';

class HealthDataService {
  static const String _storageKey = 'health_records';

  Future<List<HealthRecord>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recordsJson = prefs.getString(_storageKey);

    if (recordsJson == null) {
      return [];
    }

    final List<dynamic> recordsList = json.decode(recordsJson);
    return recordsList.map((record) => HealthRecord.fromJson(record as Map<String, dynamic>)).toList();
  }

  Future<List<HealthRecord>> getRecordsByType(HealthType type) async {
    final allRecords = await getAllRecords();
    return allRecords.where((record) => record.type == type).toList();
  }

  Future<List<HealthRecord>> getTodayRecords() async {
    final allRecords = await getAllRecords();
    final today = DateTime.now();
    return allRecords.where((record) {
      return record.date.year == today.year && record.date.month == today.month && record.date.day == today.day;
    }).toList();
  }

  Future<HealthRecord?> getLatestRecord(HealthType type) async {
    final records = await getRecordsByType(type);
    if (records.isEmpty) return null;

    records.sort((a, b) => b.date.compareTo(a.date));
    return records.first;
  }


  Future<double> getTodayTotal(HealthType type) async {
    final todayRecords = await getTodayRecords();
    final typeRecords = todayRecords.where((r) => r.type == type);

    double total = 0.0;
    for (final record in typeRecords) {
      total += record.value;
    }

    return total;
  }


  Future<void> addRecord(HealthRecord record) async {
    final allRecords = await getAllRecords();
    allRecords.add(record);
    await _saveRecords(allRecords);
  }

  Future<void> updateRecord(HealthRecord updatedRecord) async {
    final allRecords = await getAllRecords();
    final index = allRecords.indexWhere((r) => r.id == updatedRecord.id);
    if (index != -1) {
      allRecords[index] = updatedRecord;
      await _saveRecords(allRecords);
    }
  }

  Future<void> deleteRecord(String id) async {
    final allRecords = await getAllRecords();
    allRecords.removeWhere((r) => r.id == id);
    await _saveRecords(allRecords);
  }

  Future<void> _saveRecords(List<HealthRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordsJson = json.encode(
      records.map((record) => record.toJson()).toList(),
    );
    await prefs.setString(_storageKey, recordsJson);
  }

  Future<List<HealthRecord>> getRecordsForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allRecords = await getAllRecords();
    return allRecords.where((record) {
      return record.date.isAfter(startDate.subtract(const Duration(days: 1))) && record.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Returns a map of daily totals for a given [type] for the last [days] days (inclusive of today).
  Future<Map<DateTime, double>> getDailyTotals({
    required HealthType type,
    int days = 7,
    DateTime? endDate,
  }) async {
    final allRecords = await getAllRecords();
    final DateTime end = endDate ?? DateTime.now();
    final DateTime start = end.subtract(Duration(days: days - 1));

    final Map<DateTime, double> totals = {};

    for (final record in allRecords) {
      final isWithinRange = record.date.isAfter(start.subtract(const Duration(days: 1))) &&
          record.date.isBefore(end.add(const Duration(days: 1)));

      if (isWithinRange && record.type == type) {
        final dayKey = DateTime(record.date.year, record.date.month, record.date.day);
        totals[dayKey] = (totals[dayKey] ?? 0) + record.value;
      }
    }

    // Ensure we have an entry for every day in range (defaulting to zero).
    for (int i = 0; i < days; i++) {
      final day = DateTime(start.year, start.month, start.day).add(Duration(days: i));
      totals.putIfAbsent(day, () => 0);
    }

    return totals;
  }
}
