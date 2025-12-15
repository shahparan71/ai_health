import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../models/health_record.dart';
import '../bloc/history/history_bloc.dart';
import '../bloc/history/history_event.dart';
import '../bloc/history/history_state.dart';
import '../bloc/health_record/health_record_bloc.dart';
import '../bloc/health_record/health_record_event.dart';
import '../bloc/health_record/health_record_state.dart';
import '../widgets/record_list_item.dart';
import '../injection/injection_container.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading && state is! HistoryLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is HistoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HistoryBloc>().add(const LoadHistoryRecords());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is HistoryLoaded) {
            return Column(
              children: [
                _buildFilterChips(context, state.selectedFilter),
                Expanded(
                  child: state.filteredRecords.isEmpty
                      ? _buildEmptyState(context)
                      : _buildRecordsList(context, state),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, HealthType? selectedFilter) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              selected: selectedFilter == null,
              label: const Text('All'),
              onSelected: (selected) {
                context.read<HistoryBloc>().add(const FilterHistoryRecords(null));
              },
            ),
            const SizedBox(width: 8),
            ...HealthType.values.map((type) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  selected: selectedFilter == type,
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(type.icon, size: 16),
                      const SizedBox(width: 4),
                      Text(type.displayName),
                    ],
                  ),
                  onSelected: (selected) {
                    context.read<HistoryBloc>().add(
                          FilterHistoryRecords(selected ? type : null),
                        );
                  },
                  selectedColor: type.color.withOpacity(0.2),
                  checkmarkColor: type.color,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No records found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your health to see history here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsList(BuildContext context, HistoryLoaded state) {
    final grouped = _groupRecords(state.filteredRecords);
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('EEEE, MMMM d, yyyy').parse(a);
        final dateB = DateFormat('EEEE, MMMM d, yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return BlocProvider(
      create: (_) => getIt<HealthRecordBloc>(),
        child: BlocListener<HealthRecordBloc, HealthRecordState>(
        listener: (context, recordState) {
          if (recordState is HealthRecordSuccess) {
            context.read<HistoryBloc>().add(const RefreshHistoryRecords());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(recordState.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (recordState is HealthRecordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(recordState.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<HistoryBloc>().add(const RefreshHistoryRecords());
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              final date = sortedDates[index];
              final records = grouped[date]!;
              records.sort((a, b) => b.date.compareTo(a.date));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 8, top: index > 0 ? 16 : 0),
                    child: Text(
                      date,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                    ),
                  ),
                  ...records.map((record) {
                    return RecordListItem(
                      record: record,
                      onDelete: () {
                        context.read<HealthRecordBloc>().add(
                              DeleteHealthRecord(record.id),
                            );
                      },
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Map<String, List<HealthRecord>> _groupRecords(List<HealthRecord> records) {
    final grouped = <String, List<HealthRecord>>{};
    final displayFormat = DateFormat('EEEE, MMMM d, yyyy');

    for (final record in records) {
      final displayKey = displayFormat.format(record.date);

      if (!grouped.containsKey(displayKey)) {
        grouped[displayKey] = [];
      }
      grouped[displayKey]!.add(record);
    }

    return grouped;
  }
}
