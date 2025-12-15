import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/health_data_service.dart';
import '../../models/health_record.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HealthDataService _dataService;

  HistoryBloc(this._dataService) : super(HistoryInitial()) {
    on<LoadHistoryRecords>(_onLoadHistoryRecords);
    on<FilterHistoryRecords>(_onFilterHistoryRecords);
    on<RefreshHistoryRecords>(_onRefreshHistoryRecords);
  }

  Future<void> _onLoadHistoryRecords(
    LoadHistoryRecords event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    await _loadRecords(emit, null);
  }

  Future<void> _onFilterHistoryRecords(
    FilterHistoryRecords event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoaded) {
      final currentState = state as HistoryLoaded;
      final filtered = event.filterType == null
          ? currentState.allRecords
          : currentState.allRecords.where((r) => r.type == event.filterType).toList();
      
      emit(currentState.copyWith(
        selectedFilter: event.filterType,
        filteredRecords: filtered,
      ));
    } else {
      await _loadRecords(emit, event.filterType);
    }
  }

  Future<void> _onRefreshHistoryRecords(
    RefreshHistoryRecords event,
    Emitter<HistoryState> emit,
  ) async {
    final currentFilter = state is HistoryLoaded
        ? (state as HistoryLoaded).selectedFilter
        : null;
    await _loadRecords(emit, currentFilter);
  }

  Future<void> _loadRecords(
    Emitter<HistoryState> emit,
    HealthType? filterType,
  ) async {
    try {
      final records = await _dataService.getAllRecords();
      records.sort((a, b) => b.date.compareTo(a.date));

      final filtered = filterType == null
          ? records
          : records.where((r) => r.type == filterType).toList();

      emit(HistoryLoaded(
        allRecords: records,
        selectedFilter: filterType,
        filteredRecords: filtered,
      ));
    } catch (e) {
      emit(HistoryError('Failed to load history: ${e.toString()}'));
    }
  }
}

