import 'package:ai_health/bloc/history/history_bloc.dart';
import 'package:ai_health/bloc/history/history_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/health_record/health_record_bloc.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
import '../injection/injection_container.dart';
import '../models/health_record.dart';
import '../widgets/health_card.dart';
import 'add_record_screen.dart';
import 'history_screen.dart';
import 'gallery_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Tracker'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GalleryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(create: (_) => getIt<HistoryBloc>()..add(const LoadHistoryRecords()), child: const HistoryScreen()),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading && state is! HomeLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(state.message, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomeBloc>().add(const LoadHomeData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const RefreshHomeData());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateHeader(context),
                  const SizedBox(height: 24),
                  if (state is HomeLoaded) ...[_buildQuickStats(context, state), const SizedBox(height: 24), _buildHealthCards(context, state)],
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(create: (_) => getIt<HealthRecordBloc>(), child: const AddRecordScreen()),
            ),
          ).then((_) {
            context.read<HomeBloc>().add(const RefreshHomeData());
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }

  Widget _buildDateHeader(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Today', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(dateFormat.format(now), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context, HomeLoaded state) {
    final hasData = state.todayRecords.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepSummaryCard(context, state),
        if (!hasData) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.health_and_safety, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No records today', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first health record',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHealthCards(BuildContext context, HomeLoaded state) {
    return Column(
      children: HealthType.values.map((type) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HealthCard(
            healthType: type,
            todayTotal: state.todayTotals[type] ?? 0.0,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (_) => getIt<HealthRecordBloc>(),
                    child: AddRecordScreen(initialType: type),
                  ),
                ),
              ).then((_) {
                context.read<HomeBloc>().add(const RefreshHomeData());
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStepSummaryCard(BuildContext context, HomeLoaded state) {
    final summary = state.stepSummary;
    final numberFormat = NumberFormat.decimalPattern();
    final progress = summary.goal > 0 ? (summary.todaySteps / summary.goal).clamp(0.0, 1.0) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HealthType.steps.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    HealthType.steps.icon,
                    color: HealthType.steps.color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps today',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      numberFormat.format(summary.todaySteps),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: HealthType.steps.color,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: HealthType.steps.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Goal ${numberFormat.format(summary.goal)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: HealthType.steps.color,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              color: HealthType.steps.color,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(height: 8),
            Text(
              '${numberFormat.format(summary.todaySteps)} / ${numberFormat.format(summary.goal)} steps',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStepStat(
                    context,
                    label: 'This week',
                    value: numberFormat.format(summary.weeklySteps),
                    icon: Icons.calendar_view_week,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStepStat(
                    context,
                    label: 'Avg/day',
                    value: numberFormat.format(summary.dailyAverage),
                    icon: Icons.show_chart,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStepStat(
                    context,
                    label: 'Active days',
                    value: '${summary.activeDays}/7',
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
          ),
        ],
      ),
    );
  }
}
