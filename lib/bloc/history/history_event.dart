import 'package:equatable/equatable.dart';
import '../../models/health_record.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadHistoryRecords extends HistoryEvent {
  const LoadHistoryRecords();
}

class FilterHistoryRecords extends HistoryEvent {
  final HealthType? filterType;

  const FilterHistoryRecords(this.filterType);

  @override
  List<Object?> get props => [filterType];
}

class RefreshHistoryRecords extends HistoryEvent {
  const RefreshHistoryRecords();
}

