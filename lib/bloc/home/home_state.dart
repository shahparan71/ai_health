import 'package:equatable/equatable.dart';

import '../../models/health_record.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class StepSummary extends Equatable {
  final double todaySteps;
  final double weeklySteps;
  final double dailyAverage;
  final int activeDays;
  final double goal;

  const StepSummary({required this.todaySteps, required this.weeklySteps, required this.dailyAverage, required this.activeDays, required this.goal});

  StepSummary copyWith({double? todaySteps, double? weeklySteps, double? dailyAverage, int? activeDays, double? goal}) {
    return StepSummary(
      todaySteps: todaySteps ?? this.todaySteps,
      weeklySteps: weeklySteps ?? this.weeklySteps,
      dailyAverage: dailyAverage ?? this.dailyAverage,
      activeDays: activeDays ?? this.activeDays,
      goal: goal ?? this.goal,
    );
  }

  @override
  List<Object?> get props => [todaySteps, weeklySteps, dailyAverage, activeDays, goal];
}

class HomeLoaded extends HomeState {
  final List<HealthRecord> todayRecords;
  final Map<HealthType, double> todayTotals;
  final StepSummary stepSummary;

  const HomeLoaded({required this.todayRecords, required this.todayTotals, required this.stepSummary});

  @override
  List<Object?> get props => [todayRecords, todayTotals, stepSummary];

  HomeLoaded copyWith({List<HealthRecord>? todayRecords, Map<HealthType, double>? todayTotals, StepSummary? stepSummary}) {
    return HomeLoaded(todayRecords: todayRecords ?? this.todayRecords, todayTotals: todayTotals ?? this.todayTotals, stepSummary: stepSummary ?? this.stepSummary);
  }
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
