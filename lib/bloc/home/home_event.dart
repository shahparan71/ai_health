import 'package:equatable/equatable.dart';
import '../../models/health_record.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeData extends HomeEvent {
  const LoadHomeData();
}

class RefreshHomeData extends HomeEvent {
  const RefreshHomeData();
}

class LoadTodayTotal extends HomeEvent {
  final HealthType type;

  const LoadTodayTotal(this.type);

  @override
  List<Object?> get props => [type];
}

/// Emitted when the step sensor reports a new "steps today" value.
class StepsUpdated extends HomeEvent {
  final int stepsToday;

  const StepsUpdated(this.stepsToday);

  @override
  List<Object?> get props => [stepsToday];
}

