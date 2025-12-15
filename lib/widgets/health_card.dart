import 'package:flutter/material.dart';
import '../models/health_record.dart';

class HealthCard extends StatelessWidget {
  final HealthType healthType;
  final double todayTotal;
  final VoidCallback onTap;

  const HealthCard({
    super.key,
    required this.healthType,
    required this.todayTotal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = todayTotal > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: healthType.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  healthType.icon,
                  color: healthType.color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      healthType.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasData
                          ? '${_formatValue(todayTotal)} ${healthType.defaultUnit}'
                          : 'No data today',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: hasData
                                ? healthType.color
                                : Colors.grey[600],
                            fontWeight: hasData
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }
}
