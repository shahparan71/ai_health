import 'package:equatable/equatable.dart';
import '../../models/health_record.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<HealthRecord> allRecords;
  final HealthType? selectedFilter;
  final List<HealthRecord> filteredRecords;

  const HistoryLoaded({
    required this.allRecords,
    this.selectedFilter,
    required this.filteredRecords,
  });

  @override
  List<Object?> get props => [allRecords, selectedFilter, filteredRecords];

  HistoryLoaded copyWith({
    List<HealthRecord>? allRecords,
    HealthType? selectedFilter,
    List<HealthRecord>? filteredRecords,
  }) {
    return HistoryLoaded(
      allRecords: allRecords ?? this.allRecords,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      filteredRecords: filteredRecords ?? this.filteredRecords,
    );
  }
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

