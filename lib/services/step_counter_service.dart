import 'dart:async';

import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple wrapper around the device step counter sensor.
///
/// Exposes a stream of "steps today" values calculated from the raw sensor.
class StepCounterService {
  static const String _prefBaseDateKey = 'step_base_date';
  static const String _prefBaseStepsKey = 'step_base_steps';

  final StreamController<int> _stepsTodayController = StreamController<int>.broadcast();
  StreamSubscription<StepCount>? _stepSub;

  Stream<int> get stepsTodayStream => _stepsTodayController.stream;

  /// Start listening to the step counter sensor.
  Future<void> start() async {
    if (_stepSub != null) return;

    _stepSub = Pedometer.stepCountStream.listen(
      _onStepData,
      onError: _onStepError,
      cancelOnError: false,
    );
  }

  Future<void> _onStepData(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month}-${now.day}';

    final storedDate = prefs.getString(_prefBaseDateKey);
    int baseSteps = prefs.getInt(_prefBaseStepsKey) ?? event.steps;

    // If the stored date is from a previous day, reset the base to current sensor value.
    if (storedDate != todayKey) {
      baseSteps = event.steps;
      await prefs.setString(_prefBaseDateKey, todayKey);
      await prefs.setInt(_prefBaseStepsKey, baseSteps);
    }

    int stepsToday = event.steps - baseSteps;
    if (stepsToday < 0) {
      // Sensor was reset; treat this as new baseline.
      stepsToday = 0;
      await prefs.setInt(_prefBaseStepsKey, event.steps);
    }

    _stepsTodayController.add(stepsToday);
  }

  void _onStepError(Object error) {
    // For now we silently ignore errors; UI will just show 0 / manual data.
  }

  Future<void> dispose() async {
    await _stepSub?.cancel();
    await _stepsTodayController.close();
    _stepSub = null;
  }
}


