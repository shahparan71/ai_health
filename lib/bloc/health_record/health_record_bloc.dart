import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/health_data_service.dart';
import 'health_record_event.dart';
import 'health_record_state.dart';

class HealthRecordBloc extends Bloc<HealthRecordEvent, HealthRecordState> {
  final HealthDataService _dataService;

  HealthRecordBloc(this._dataService) : super(HealthRecordInitial()) {
    on<AddHealthRecord>(_onAddHealthRecord);
    on<UpdateHealthRecord>(_onUpdateHealthRecord);
    on<DeleteHealthRecord>(_onDeleteHealthRecord);
    on<LoadHealthRecords>(_onLoadHealthRecords);
  }

  Future<void> _onAddHealthRecord(
    AddHealthRecord event,
    Emitter<HealthRecordState> emit,
  ) async {
    try {
      emit(HealthRecordLoading());
      await _dataService.addRecord(event.record);
      emit(HealthRecordSuccess('${event.record.type.name} record added!'));
    } catch (e) {
      emit(HealthRecordError('Failed to add record: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateHealthRecord(
    UpdateHealthRecord event,
    Emitter<HealthRecordState> emit,
  ) async {
    try {
      emit(HealthRecordLoading());
      await _dataService.updateRecord(event.record);
      emit(HealthRecordSuccess('Record updated successfully!'));
    } catch (e) {
      emit(HealthRecordError('Failed to update record: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteHealthRecord(
    DeleteHealthRecord event,
    Emitter<HealthRecordState> emit,
  ) async {
    try {
      emit(HealthRecordLoading());
      await _dataService.deleteRecord(event.id);
      emit(HealthRecordSuccess('Record deleted successfully!'));
    } catch (e) {
      emit(HealthRecordError('Failed to delete record: ${e.toString()}'));
    }
  }

  Future<void> _onLoadHealthRecords(
    LoadHealthRecords event,
    Emitter<HealthRecordState> emit,
  ) async {
    try {
      emit(HealthRecordLoading());
      final records = await _dataService.getAllRecords();
      emit(HealthRecordLoaded(records));
    } catch (e) {
      emit(HealthRecordError('Failed to load records: ${e.toString()}'));
    }
  }
}
