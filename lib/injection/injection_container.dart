import 'package:get_it/get_it.dart';

import '../bloc/health_record/health_record_bloc.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/history/history_bloc.dart';
import '../services/health_data_service.dart';
import '../services/step_counter_service.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // Services
  getIt.registerLazySingleton<HealthDataService>(() => HealthDataService());
  getIt.registerLazySingleton<StepCounterService>(() => StepCounterService()..start());

  // Blocs
  getIt.registerFactory<HealthRecordBloc>(
    () => HealthRecordBloc(getIt<HealthDataService>()),
  );
  
  getIt.registerFactory<HomeBloc>(() => HomeBloc(getIt<HealthDataService>(), getIt<StepCounterService>()));
  
  getIt.registerFactory<HistoryBloc>(
    () => HistoryBloc(getIt<HealthDataService>()),
  );
}

