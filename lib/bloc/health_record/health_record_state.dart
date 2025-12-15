import 'package:equatable/equatable.dart';
import '../../models/health_record.dart';

abstract class HealthRecordState extends Equatable {
  const HealthRecordState();

  @override
  List<Object?> get props => [];
}

class HealthRecordInitial extends HealthRecordState {}

class HealthRecordLoading extends HealthRecordState {}

class HealthRecordLoaded extends HealthRecordState {
  final List<HealthRecord> records;

  const HealthRecordLoaded(this.records);

  @override
  List<Object?> get props => [records];
}

class HealthRecordSuccess extends HealthRecordState {
  final String message;

  const HealthRecordSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class HealthRecordError extends HealthRecordState {
  final String message;

  const HealthRecordError(this.message);

  @override
  List<Object?> get props => [message];
}

