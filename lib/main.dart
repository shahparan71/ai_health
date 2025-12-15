import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'injection/injection_container.dart';
import 'bloc/health_record/health_record_bloc.dart';
import 'bloc/home/home_bloc.dart';
import 'bloc/home/home_event.dart';
import 'bloc/history/history_bloc.dart';
import 'bloc/history/history_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const HealthTrackerApp());
}

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const LoadHomeData()),
        ),
        BlocProvider(
          create: (_) => getIt<HistoryBloc>()..add(const LoadHistoryRecords()),
        ),
      ],
      child: MaterialApp(
        title: 'Health Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF4CAF50),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

