import 'package:equatable/equatable.dart';
import '../../models/health_record.dart';

abstract class HealthRecordEvent extends Equatable {
  const HealthRecordEvent();

  @override
  List<Object?> get props => [];
}

class AddHealthRecord extends HealthRecordEvent {
  final HealthRecord record;

  const AddHealthRecord(this.record);

  @override
  List<Object?> get props => [record];
}

class UpdateHealthRecord extends HealthRecordEvent {
  final HealthRecord record;

  const UpdateHealthRecord(this.record);

  @override
  List<Object?> get props => [record];
}

class DeleteHealthRecord extends HealthRecordEvent {
  final String id;

  const DeleteHealthRecord(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadHealthRecords extends HealthRecordEvent {
  const LoadHealthRecords();
}

