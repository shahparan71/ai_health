import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/health_record.dart';
import '../../services/health_data_service.dart';
import '../../services/step_counter_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HealthDataService _dataService;
  final StepCounterService _stepCounterService;
  StreamSubscription<int>? _stepSubscription;

  HomeBloc(this._dataService, this._stepCounterService) : super(HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
    on<LoadTodayTotal>(_onLoadTodayTotal);
    on<StepsUpdated>(_onStepsUpdated);

    // Start listening to automatic step updates.
    _stepSubscription = _stepCounterService.stepsTodayStream.listen((steps) {
      add(StepsUpdated(steps));
    });
  }

  Future<void> _onLoadHomeData(LoadHomeData event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshHomeData(RefreshHomeData event, Emitter<HomeState> emit) async {
    await _loadData(emit);
  }

  Future<void> _onLoadTodayTotal(LoadTodayTotal event, Emitter<HomeState> emit) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      try {
        final total = await _dataService.getTodayTotal(event.type);
        final updatedTotals = Map<HealthType, double>.from(currentState.todayTotals);
        updatedTotals[event.type] = total;

        if (event.type == HealthType.steps) {
          final stepSummary = await _buildStepSummary(updatedTotals);
          emit(currentState.copyWith(todayTotals: updatedTotals, stepSummary: stepSummary));
        } else {
          emit(currentState.copyWith(todayTotals: updatedTotals));
        }
      } catch (e) {
        emit(HomeError('Failed to load ${event.type.displayName}: ${e.toString()}'));
      }
    }
  }

  Future<void> _onStepsUpdated(StepsUpdated event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;
    final updatedTotals = Map<HealthType, double>.from(currentState.todayTotals);
    updatedTotals[HealthType.steps] = event.stepsToday.toDouble();

    final stepSummary = await _buildStepSummary(updatedTotals);
    emit(currentState.copyWith(todayTotals: updatedTotals, stepSummary: stepSummary));
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      final todayRecords = await _dataService.getTodayRecords();
      final todayTotals = <HealthType, double>{};

      for (final type in HealthType.values) {
        final total = await _dataService.getTodayTotal(type);
        todayTotals[type] = total;
      }

      final stepSummary = await _buildStepSummary(todayTotals);

      emit(HomeLoaded(todayRecords: todayRecords, todayTotals: todayTotals, stepSummary: stepSummary));
    } catch (e) {
      emit(HomeError('Failed to load home data: ${e.toString()}'));
    }
  }

  Future<StepSummary> _buildStepSummary(Map<HealthType, double> todayTotals) async {
    const double defaultGoal = 10000;

    final stepTotalsByDay = await _dataService.getDailyTotals(type: HealthType.steps, days: 7);
    final double weeklySteps = stepTotalsByDay.values.fold(0.0, (sum, value) => sum + value);
    final int activeDays = stepTotalsByDay.values.where((value) => value > 0).length;
    final double dailyAverage = stepTotalsByDay.isEmpty ? 0.0 : weeklySteps / stepTotalsByDay.length;

    return StepSummary(
      todaySteps: todayTotals[HealthType.steps] ?? 0.0,
      weeklySteps: weeklySteps,
      dailyAverage: dailyAverage,
      activeDays: activeDays,
      goal: defaultGoal,
    );
  }

  @override
  Future<void> close() async {
    await _stepSubscription?.cancel();
    return super.close();
  }
}
