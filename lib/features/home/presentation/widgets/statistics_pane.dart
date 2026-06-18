import 'package:dexdo/features/tasks/presentation/providers/task_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatisticsPane extends StatelessWidget {
  const StatisticsPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Metric Cards Row
            const _MetricsRow(),
            const SizedBox(height: 32),

            // Velocity Chart
            const _SectionLabel(text: 'COMPLETION VELOCITY (LAST 30 DAYS)'),
            const SizedBox(height: 16),
            const _VelocityChart(),
            const SizedBox(height: 32),

            // Category Distribution
            const _SectionLabel(text: 'CATEGORY BALANCE'),
            const SizedBox(height: 16),
            const _CategoryDistributionChart(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _MetricsRow extends ConsumerWidget {
  const _MetricsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(taskProvider.select((s) => s.statistics));

    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Habit Strength',
            value: '${(stats.habitStrength * 100).toInt()}%',
            icon: Icons.bolt_rounded,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricCard(
            label: 'Completion',
            value: '${(stats.completionRate * 100).toInt()}%',
            icon: Icons.check_circle_rounded,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _VelocityChart extends ConsumerWidget {
  const _VelocityChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spots = ref.watch(taskProvider.select((s) => s.statistics.completionVelocitySpots));

    return Container(
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: RepaintBoundary(
        child: LineChart(
          LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    if (value % 5 != 0) return const SizedBox.shrink();
                    return SideTitleWidget(
                      meta: meta,
                      child: Text(
                        '${value.toInt()}d',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 4,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (spot) => Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          transformationConfig: const FlTransformationConfig(
            scaleAxis: FlScaleAxis.horizontal,
            minScale: 1.0,
            maxScale: 3.0,
            panEnabled: true,
            scaleEnabled: true,
          ),
        ),
      ),
    );
  }
}

class _CategoryDistributionChart extends ConsumerWidget {
  const _CategoryDistributionChart();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distribution = ref.watch(taskProvider.select((s) => s.statistics.categoryDistribution));
    final catColors = ref.watch(taskProvider.select((s) => s.categoryColors));

    return Container(
      height: 300,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: distribution.isEmpty
          ? const Center(child: Text('No data yet'))
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: RepaintBoundary(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: distribution.entries.map((e) {
                          return PieChartSectionData(
                            color: catColors[e.key] ?? Colors.grey,
                            value: e.value,
                            title: '${(e.value * 100).toInt()}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: distribution.keys.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: catColors[cat] ?? Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                cat,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.5,
        color: Colors.grey,
      ),
    );
  }
}
